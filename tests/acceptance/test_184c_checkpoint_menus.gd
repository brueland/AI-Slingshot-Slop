extends GutTest
# Checkpoint 22 (task 184c): the new menus and the course bar work together with real frames: How to play and
# Achievements open and close from the title, and the course bar follows a flight.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_184c_save.json"
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


func test_menus_and_bar_with_real_frames() -> void:
	var main = _main()
	var ui = main.ui_layer
	main.title_panel.help_button.pressed.emit()
	await wait_seconds(0.3)
	assert_true(ui.help_panel.visible)
	ui.help_panel.close_button.pressed.emit()
	main.title_panel.achievements_button.pressed.emit()
	await wait_seconds(0.3)
	assert_true(ui.achievements_panel.list_label.text.begins_with("[ ] Liftoff"), "nothing earned yet")
	ui.achievements_panel.close_button.pressed.emit()
	main.start_game()
	main.launch_with_pull(PULL)
	await wait_seconds(0.8)
	assert_gt(main.hud.course_bar.fraction, 0.0, "the bar follows a real flight")
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	main.continue_to_shop()
	main.leave_shop()
	assert_almost_eq(main.hud.course_bar.best_fraction, CourseBar.fraction_for(main.progress.best_distance), 0.0001)
	main.go_to_title()
	main.title_panel.achievements_button.pressed.emit()
	assert_true(ui.achievements_panel.list_label.text.begins_with("[x] Liftoff"), "the first run earned Liftoff")


func test_new_scripts_follow_the_conventions() -> void:
	var names := {"res://scripts/ui/achievements_panel.gd": "AchievementsPanel", "res://scripts/ui/help_panel.gd": "HelpPanel",
		"res://scripts/ui/course_bar.gd": "CourseBar"}
	for path in names:
		if not ResourceLoader.exists(path):
			fail_test("missing file " + path)
			continue
		var text := FileAccess.get_file_as_string(path)
		assert_true(text.contains("class_name " + names[path]), path)
		assert_false(text.contains("print("), path)
	var main_text := FileAccess.get_file_as_string("res://scripts/game/main.gd")
	assert_lt(main_text.split("\n").size(), 450, "main.gd stays under 450 lines")


func test_progress_log_records_milestone_22() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 22: complete"), "add the line 'Milestone 22: complete' to docs/PROGRESS.md")
