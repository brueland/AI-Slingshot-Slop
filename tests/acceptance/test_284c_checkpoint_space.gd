extends GutTest
# Checkpoint 40 (task 284c): with real frames, a flight high into space shows the things in space, and they are
# gone again back near the ground.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_284c_save.json"
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



func test_space_with_real_frames() -> void:
	var main = _main()
	await wait_process_frames(2)
	main.start_game()
	main.launch_with_pull(PULL)
	await wait_physics_frames(2)
	main.session.sim.position = Vector2(60.0, 280.0)
	main.session.sim.velocity = Vector2(5.0, 1.0)
	await wait_seconds(0.3)
	var space = main.background.space
	assert_true(space.visible, "space things up at 280 m")
	assert_gt(space.height_m, 250.0)
	assert_true(SpaceDecor.showing(space.height_m).has("astronaut"))


func test_progress_log_records_milestone_40() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 39: complete"), "the earlier lines are kept")
	assert_true(text.contains("Milestone 40: complete"), "add the line 'Milestone 40: complete' to docs/PROGRESS.md")
