extends GutTest
# Task 202: the pause menu gets an Options button (the volume sliders); resuming or quitting closes the options.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_202_save.json"
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


func test_options_from_the_pause_menu() -> void:
	var main = _main()
	var menu = main.ui_layer.pause_menu
	assert_eq(menu.options_button.text, "Options")
	assert_eq(menu.options_button.get_index(), menu.resume_button.get_index() + 1, "between Resume and Quit to title")
	main.start_game()
	main.launch_with_pull(PULL)
	main.advance(1.0 / 60.0)
	main.toggle_pause()
	menu.options_button.pressed.emit()
	var options = main.options_panel
	assert_true(options.visible, "the volume sliders open while paused")
	options.music_slider.value = 0.3
	assert_almost_eq(float(main.progress.settings["music_volume"]), 0.3, 0.0001, "the music volume changes")
	await wait_process_frames(3)
	var screen: Rect2 = main.get_viewport().get_visible_rect()
	assert_true(screen.encloses(options.get_global_rect()), "the options fit on screen")
	assert_true(screen.encloses(menu.get_global_rect()), "the pause menu fits on screen")
	assert_false(options.get_global_rect().intersects(menu.get_global_rect()), "the pause menu stays clickable")
	assert_false(menu.get_global_rect().intersects(main.pause_label.get_global_rect()), "below the Paused text")
	main.toggle_pause()
	assert_false(options.visible, "resuming closes the options")
	assert_eq(main.state_name(), "FLIGHT", "the flight goes on")
	main.toggle_pause()
	menu.options_button.pressed.emit()
	menu.quit_button.pressed.emit()
	assert_eq(main.state_name(), "TITLE")
	assert_false(options.visible, "no options panel left open on the title")
