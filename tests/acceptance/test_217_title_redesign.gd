extends GutTest
# Task 217: the title is a full screen with no box: the logo, a big orange PLAY that opens a mode chooser (Classic,
# Roguelike, Daily Run), the other buttons in a bar along the bottom, and a small Reset progress link top right.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_217_save.json"
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


func test_title_layout_and_mode_chooser() -> void:
	var main = _main()
	var t = main.title_panel
	assert_eq(t.start_button.text, "PLAY")
	assert_eq(t.start_button.theme_type_variation, "PrimaryButton")
	assert_false(t.mode_overlay.visible, "the mode chooser starts hidden")
	await wait_process_frames(3)
	var screen: Rect2 = main.get_viewport().get_visible_rect()
	for c in [t.title_label, t.start_button, t.bottom_bar, t.reset_button]:
		_on_screen(main, c, str(c.name))
	assert_lt(absf(t.start_button.get_global_rect().get_center().x - screen.get_center().x), 2.0, "PLAY is centered")
	assert_lt(t.bottom_bar.get_global_rect().end.y, main.ui_layer.challenge_label.get_global_rect().position.y, "clear of the tip lines")
	assert_gt(t.reset_button.get_global_rect().position.x, screen.size.x * 0.75, "Reset progress is out of the way")
	assert_true(t.reset_button.flat, "a small link, not a big button")
	t.start_button.pressed.emit()
	assert_true(t.mode_overlay.visible, "PLAY opens the mode chooser")
	await wait_process_frames(2)
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
	assert_true(t.visible)
	assert_false(t.mode_overlay.visible, "back on the title with the chooser closed")
