extends GutTest
# Task 296: the perk screen after a roguelike shot has a Menu button: it opens the pause menu (Resume brings the
# perk screen back, Options opens the options, Quit to title ends the run).

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_296_save.json"
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



func _to_perk_screen(main) -> void:
	main.start_rogue(5)
	main.launch_with_pull(PULL)
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)


func test_perk_screen_menu() -> void:
	var main = _main()
	_to_perk_screen(main)
	await wait_process_frames(2)
	var panel = main.ui_layer.rogue_panel
	var pause = main.ui_layer.pause_menu
	assert_eq(main.state_name(), "RESULTS")
	assert_true(panel.visible, "the perk screen")
	assert_true(panel.get("menu_button") is Button, "rogue_panel.menu_button")
	if not panel.get("menu_button") is Button:
		return
	assert_eq(panel.menu_button.text, "Menu")
	assert_true(panel.menu_button.is_visible_in_tree())
	assert_lte(panel.size.y, 680.0, "the perk screen still fits a 720 px screen")
	panel.menu_button.pressed.emit()
	assert_true(pause.visible, "the pause menu")
	assert_false(panel.visible, "in place of the perk screen")
	pause.resume_button.pressed.emit()
	assert_false(pause.visible, "Resume closes it")
	assert_true(panel.visible, "and the perk screen is back")
	assert_eq(main.state_name(), "RESULTS")
	panel.menu_button.pressed.emit()
	pause.options_button.pressed.emit()
	assert_true(main.options_panel.visible, "Options")
	pause.quit_button.pressed.emit()
	assert_eq(main.state_name(), "TITLE", "Quit to title")
	assert_false(pause.visible)
