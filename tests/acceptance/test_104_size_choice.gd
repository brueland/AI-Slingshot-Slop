extends GutTest
# Task 104: the roguelike perk panel has a "Next shot size" row (Small, Normal, Big). The choice is kept by the run
# and used from the next shot on.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_104_save.json"


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func _after_first_shot():
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	main.start_rogue(7)
	main.launch_with_pull(Vector2(-84.852814, 84.852814))
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	return main


func test_size_row() -> void:
	var main = _after_first_shot()
	var panel = main.ui_layer.rogue_panel
	assert_true(panel.visible)
	assert_true(panel.get("size_label") is Label, "rogue_panel.size_label")
	if not panel.get("size_label") is Label:
		return
	assert_eq(panel.size_buttons.keys(), ["small", "normal", "big"])
	assert_eq(panel.size_buttons["big"].text, "Big")
	assert_eq(panel.size_label.text, "Next shot size: Normal - balanced")
	assert_true(panel.size_buttons["normal"].button_pressed)
	assert_false(panel.size_buttons["big"].button_pressed)
	watch_signals(panel)
	panel.size_buttons["big"].pressed.emit()
	assert_signal_emitted_with_parameters(panel, "size_chosen", ["big"])
	assert_eq(main.rogue.size_id, "big")
	assert_eq(panel.size_label.text, "Next shot size: Big - a little slower, more drag, easy to hit stars")
	assert_true(panel.size_buttons["big"].button_pressed)
	assert_false(panel.size_buttons["normal"].button_pressed)
	await wait_process_frames(3)
	assert_true(main.get_viewport().get_visible_rect().encloses(panel.get_global_rect()), "the panel still fits on screen")


func test_the_next_shot_uses_the_size() -> void:
	var main = _after_first_shot()
	var panel = main.ui_layer.rogue_panel
	panel.size_buttons["small"].pressed.emit()
	panel.perk_buttons[0].pressed.emit()
	assert_eq(main.state_name(), "AIM")
	assert_almost_eq(main.session.stats.size_scale, 0.6, 0.0001)
	assert_almost_eq(main.projectile_view.size_scale, 0.6, 0.0001)
	main.launch_with_pull(Vector2(-84.852814, 84.852814))
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	assert_eq(panel.size_label.text, "Next shot size: Small - faster and farther, harder to hit stars", "the size stays")
	assert_true(panel.size_buttons["small"].button_pressed)
