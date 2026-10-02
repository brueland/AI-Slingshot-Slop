extends GutTest
# Checkpoint 37 (task 271c): with real frames and real drags, Steady Hand shows the last shot's path while aiming,
# and in flight the last-aim line is gone.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_271c_save.json"
const PULL := Vector2(-84.852814, 84.852814)


func before_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func after_each() -> void:
	before_each()


func _main():
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	return main


func _fly(main, pull: Vector2) -> void:
	main.launch_with_pull(pull)
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)


func _on_screen(main, control: Control, what: String) -> void:
	assert_true(main.get_viewport().get_visible_rect().encloses(control.get_global_rect()), what + " is on screen")



func _drag(main, pull: Vector2) -> void:
	var anchor: Vector2 = main.slingshot.global_position
	main.slingshot.begin_drag(anchor)
	main.slingshot.update_drag(anchor + pull)
	await wait_process_frames(1)
	main.slingshot.release()


func test_steady_with_real_frames() -> void:
	var main = _main()
	await wait_process_frames(2)
	main.start_rogue(7)
	main.rogue.perks.assign(["steady"])
	main._begin_aim()
	await _drag(main, PULL)
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	main.ui_layer.rogue_panel.perk_buttons[0].pressed.emit()
	await wait_process_frames(2)
	assert_eq(main.slingshot.shown_aim_line().size(), 2, "aiming: the last-aim line")
	assert_eq(main.ghost.points, main.rogue.last_path, "and the last shot's path")
	await _drag(main, PULL * 0.8)
	await wait_seconds(0.3)
	assert_eq(main.state_name(), "FLIGHT")
	assert_eq(main.slingshot.shown_aim_line().size(), 0, "in flight: no line sliding across the screen")


func test_progress_log_records_milestone_37() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 36: complete"), "the earlier lines are kept")
	assert_true(text.contains("Milestone 37: complete"), "add the line 'Milestone 37: complete' to docs/PROGRESS.md")
