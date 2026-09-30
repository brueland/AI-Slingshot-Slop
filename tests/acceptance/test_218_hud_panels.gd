extends GutTest
# Task 218: the HUD's readouts sit in two outlined glass panels (flight on the left with the height bar beside it,
# progress on the right).

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


func test_hud_panels() -> void:
	var main = _main()
	main.start_game()
	await wait_process_frames(3)
	var hud = main.hud
	var left = hud.distance_label.get_parent().get_parent().get_parent()
	var right = hud.best_label.get_parent().get_parent()
	for p in [left, right]:
		assert_true(p is PanelContainer, "a panel around the group")
		if not p is PanelContainer:
			return
		var box = p.get_theme_stylebox("panel")
		assert_true(box is StyleBoxFlat and box.border_width_top == 2, "an outline")
		assert_eq(p.mouse_filter, Control.MOUSE_FILTER_IGNORE, "never blocks the mouse")
		_on_screen(main, p, "HUD panel")
	assert_eq(hud.altitude_bar.get_parent(), hud.distance_label.get_parent().get_parent(), "the height bar sits beside the readouts")
	assert_false(left.get_global_rect().intersects(right.get_global_rect()))
	_on_screen(main, hud.menu_button, "the Menu button")
	main.go_to_title()
	main.start_rogue(5)
	var ids: Array[String] = []
	for p in RoguePerks.LIST:
		ids.append(str(p["id"]))
	main.rogue.perks.assign(ids)
	main.ui_layer.refresh(main)
	await wait_process_frames(3)
	_on_screen(main, right, "the right panel with every perk")
