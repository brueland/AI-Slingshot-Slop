extends GutTest
# Task 217: a big orange PLAY button opens a mode chooser over the title (Classic, Roguelike, Daily Run); Back closes it.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_218_save.json"
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



func test_mode_chooser() -> void:
	var main = _main()
	var t = main.title_panel
	assert_eq(t.start_button.text, "PLAY")
	assert_eq(t.start_button.theme_type_variation, "PrimaryButton")
	assert_false(t.mode_overlay.visible, "the mode chooser starts hidden")
	t.start_button.pressed.emit()
	assert_true(t.mode_overlay.visible, "PLAY opens the mode chooser")
	await wait_process_frames(3)
	for b in [t.play_button, t.rogue_button, t.daily_button]:
		assert_true(b.is_visible_in_tree(), b.text + " is offered")
		_on_screen(main, b, b.text)
	assert_eq(t.play_button.text, "Classic")
	for b in t.mode_overlay.find_children("*", "Button", true, false):
		if b.text == "Back":
			b.pressed.emit()
	assert_false(t.mode_overlay.visible, "Back closes it")
	t.start_button.pressed.emit()
	t.rogue_button.pressed.emit()
	assert_eq(main.mode, "rogue", "choosing a mode starts it")
	assert_false(t.mode_overlay.visible)
	main.go_to_title()
	assert_false(t.mode_overlay.visible, "back on the title with the chooser closed")
