extends GutTest
# Checkpoint 26 (task 204c): the in-game menus work together with real frames: the Menu button pauses a flight, the
# pause menu's Options change the volume, Resume carries on, and Quit to title goes back to the title screen.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_204c_save.json"
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


func test_menus_with_real_frames() -> void:
	var main = _main()
	main.start_game()
	main.launch_with_pull(PULL)
	await wait_seconds(0.3)
	main.hud.menu_button.pressed.emit()
	var x: float = main.session.sim.position.x
	await wait_seconds(0.3)
	assert_eq(main.session.sim.position.x, x, "the flight stops while paused")
	main.ui_layer.pause_menu.options_button.pressed.emit()
	main.options_panel.sfx_slider.value = 0.25
	assert_almost_eq(float(main.progress.settings["sfx_volume"]), 0.25, 0.0001)
	main.ui_layer.pause_menu.resume_button.pressed.emit()
	await wait_seconds(0.3)
	assert_false(main.options_panel.visible)
	assert_gt(main.session.sim.position.x, x, "the flight goes on")
	main.hud.menu_button.pressed.emit()
	main.ui_layer.pause_menu.quit_button.pressed.emit()
	await wait_seconds(0.2)
	assert_eq(main.state_name(), "TITLE")
	assert_true(main.title_panel.visible)
	assert_false(main.hud.visible)


func test_new_code_follows_the_conventions() -> void:
	var main_text := FileAccess.get_file_as_string("res://scripts/game/main.gd")
	assert_lt(main_text.split("\n").size(), 450, "main.gd stays under 450 lines")
	for path in ["res://scripts/ui/pause_menu.gd", "res://scripts/ui/hud.gd"]:
		assert_false(FileAccess.get_file_as_string(path).contains("print("), path)


func test_progress_log_records_milestone_26() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 26: complete"), "add the line 'Milestone 26: complete' to docs/PROGRESS.md")
