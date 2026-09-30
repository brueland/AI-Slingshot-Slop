extends GutTest
# Task 220: the pause menu's buttons sit in one row near the bottom, clear of the Paused text and the options panel.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_220_save.json"
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


func test_pause_row() -> void:
	var main = _main()
	main.start_game()
	main.launch_with_pull(PULL)
	main.advance(1.0 / 60.0)
	main.toggle_pause()
	var menu = main.ui_layer.pause_menu
	assert_true(menu.resume_button.get_parent() is HBoxContainer, "the buttons sit in a row")
	await wait_process_frames(3)
	var r: Rect2 = menu.get_global_rect()
	_on_screen(main, menu, "the pause menu")
	assert_false(r.intersects(main.pause_label.get_global_rect()), "below the Paused text")
	assert_lt(r.end.y, main.hud.course_bar.get_global_rect().position.y, "above the course bar")
	assert_false(r.intersects(main.hud.menu_button.get_global_rect()), "clear of the Menu button")
	menu.options_button.pressed.emit()
	await wait_process_frames(3)
	assert_false(main.options_panel.get_global_rect().intersects(menu.get_global_rect()), "the options and the pause menu do not overlap")
