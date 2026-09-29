extends GutTest
# Task 098: while paused, a small menu under "Paused" offers Resume and Quit to title.

const PATH := "res://scripts/ui/pause_menu.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_098_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func _main():
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	return main


func test_menu_exists() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var main = _main()
	var menu = main.ui_layer.get("pause_menu")
	assert_not_null(menu, "ui_layer.pause_menu")
	if menu == null:
		return
	assert_eq(menu.get_script().resource_path, PATH)
	assert_eq(menu.theme, main.ui_theme)
	assert_false(menu.visible)
	assert_eq(menu.resume_button.text, "Resume")
	assert_eq(menu.quit_button.text, "Quit to title")


func test_pause_resume_and_quit() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var main = _main()
	var menu = main.ui_layer.pause_menu
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	main.advance(1.0 / 60.0)
	main.toggle_pause()
	assert_true(main.is_paused)
	assert_true(main.pause_label.visible)
	assert_true(menu.visible, "the menu shows while paused")
	await wait_process_frames(3)
	var screen: Rect2 = main.get_viewport().get_visible_rect()
	assert_true(screen.encloses(menu.get_global_rect()), "on screen")
	assert_false(menu.get_global_rect().intersects(main.pause_label.get_global_rect()), "below the Paused text")
	menu.resume_button.pressed.emit()
	assert_false(main.is_paused)
	assert_false(menu.visible)
	assert_eq(main.state_name(), "FLIGHT", "the flight goes on")
	main.toggle_pause()
	menu.quit_button.pressed.emit()
	assert_eq(main.state_name(), "TITLE")
	assert_false(main.is_paused)
	assert_false(menu.visible)
	assert_false(main.pause_label.visible)
