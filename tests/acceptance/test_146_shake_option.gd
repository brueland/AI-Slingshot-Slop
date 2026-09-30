extends GutTest
# Task 146: the Options screen has a "Screen shake" switch; it is saved and applied to the camera.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_146_save.json"


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


func test_shake_option() -> void:
	var main = _main()
	var options = main.options_panel
	assert_true(options.get("shake_check") is CheckButton, "options_panel.shake_check")
	if not options.get("shake_check") is CheckButton:
		return
	assert_eq(options.shake_check.text, "Screen shake")
	main.title_panel.options_button.pressed.emit()
	assert_true(options.shake_check.button_pressed, "on by default")
	options.shake_check.toggled.emit(false)
	assert_false(main.progress.shake_on)
	assert_false(main.camera.shake_enabled, "applied to the camera right away")
	var again = _main()
	assert_false(again.camera.shake_enabled, "remembered after a restart")
	again.title_panel.options_button.pressed.emit()
	assert_false(again.options_panel.shake_check.button_pressed)
	await wait_process_frames(3)
	assert_true(again.get_viewport().get_visible_rect().encloses(again.options_panel.get_global_rect()), "fits on screen")
