extends GutTest
# Task 203: a "Menu (Esc)" button in the bottom-right corner of the HUD pauses the game, so mouse players can reach
# the pause menu (Resume, Options, Quit to title).

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_203_save.json"
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


func test_menu_button() -> void:
	var main = _main()
	var button = main.hud.menu_button
	assert_eq(button.text, "Menu (Esc)")
	assert_eq(button.focus_mode, Control.FOCUS_NONE, "Space (boost) never presses it")
	main.start_game()
	await wait_process_frames(3)
	var screen: Rect2 = main.get_viewport().get_visible_rect()
	var rect: Rect2 = button.get_global_rect()
	assert_true(button.is_visible_in_tree(), "shown while aiming")
	assert_true(screen.encloses(rect), "on screen")
	assert_gt(rect.position.x, screen.size.x * 0.75, "in the bottom-right corner")
	assert_gt(rect.position.y, screen.size.y * 0.75, "in the bottom-right corner")
	var sling: Vector2 = main.slingshot.get_global_transform_with_canvas().origin
	assert_false(rect.grow(48.0).has_point(sling), "clear of the slingshot")
	assert_false(rect.intersects(main.hud.course_bar.get_global_rect()), "clear of the course bar")
	button.pressed.emit()
	assert_true(main.is_paused, "the Menu button pauses")
	assert_true(main.ui_layer.pause_menu.visible)
	button.pressed.emit()
	assert_false(main.is_paused, "and resumes")
	main.go_to_title()
	assert_false(button.is_visible_in_tree(), "not on the title")
