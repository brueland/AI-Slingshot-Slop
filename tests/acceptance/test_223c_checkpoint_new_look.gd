extends GutTest
# Checkpoint 28 (task 223c): the new look works together with real frames: PLAY opens the mode chooser, the buttons
# spring, a classic flight fills the milestone bar, and the results and the shop fit on the screen.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_223c_save.json"
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


func test_new_look_with_real_frames() -> void:
	var main = _main()
	await wait_seconds(0.3)
	var t = main.title_panel
	t.start_button.pressed.emit()
	await wait_seconds(0.2)
	assert_true(t.mode_overlay.visible)
	t.play_button.mouse_entered.emit()
	await wait_seconds(0.2)
	assert_gt(t.play_button.scale.x, 1.03, "springy with real frames")
	t.play_button.pressed.emit()
	await wait_seconds(0.3)
	assert_eq(main.state_name(), "AIM")
	main.launch_with_pull(PULL)
	await wait_seconds(0.5)
	assert_gt(main.hud.goal_bar.value, 0.0, "the milestone bar fills during a real flight")
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	await wait_seconds(0.3)
	_on_screen(main, main.results_panel, "the results")
	main.continue_to_shop()
	await wait_seconds(0.3)
	_on_screen(main, main.shop_panel, "the shop")


func test_new_code_follows_the_conventions() -> void:
	var main_text := FileAccess.get_file_as_string("res://scripts/game/main.gd")
	assert_lt(main_text.split("\n").size(), 450, "main.gd stays under 450 lines")
	for path in ["res://scripts/ui/ui_theme.gd", "res://scripts/ui/title_panel.gd", "res://scripts/ui/hud.gd"]:
		assert_false(FileAccess.get_file_as_string(path).contains("print("), path)


func test_progress_log_records_milestone_28() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 28: complete"), "add the line 'Milestone 28: complete' to docs/PROGRESS.md")
