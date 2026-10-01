extends GutTest
# Task 233: the HUD shows the rocket's seconds left ("Rocket: 1.5 s", or "Rocket: none" before buying one) with an
# orange gauge right under it (hidden without a rocket), and the boost hint says to hold Space.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_233_save.json"
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


func _key(pressed: bool) -> InputEventAction:
	var e := InputEventAction.new()
	e.action = "boost"
	e.pressed = pressed
	return e


func test_rocket_gauge() -> void:
	var gauge = load("res://scripts/ui/rocket_gauge.gd").new()
	add_child_autofree(gauge)
	assert_true(gauge is ProgressBar)
	assert_eq(gauge.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_false(gauge.show_percentage)
	gauge.show_fuel(0.6, 1.5)
	assert_true(gauge.visible)
	assert_almost_eq(gauge.value, 0.4, 0.0001)
	gauge.show_fuel(0.0, 0.0)
	assert_false(gauge.visible, "no rocket, no gauge")
	var main = _main()
	var hud = main.hud
	assert_eq(hud.HINT_BOOST, "Hold Space in the air to fire the rocket!")
	hud.update_flight(0.0, 0.0, 0, 0.0, 0.0)
	assert_eq(hud.boosts_label.text, "Rocket: none", "before buying a rocket")
	assert_false(hud.rocket_bar.visible)
	assert_eq(hud.rocket_bar.get_parent(), hud.boosts_label.get_parent())
	assert_eq(hud.rocket_bar.get_index(), hud.boosts_label.get_index() + 1, "right under the rocket line")
	main.progress.levels = {"boosts": 3}
	main.start_game()
	main.launch_with_pull(PULL)
	main.advance(1.0 / 60.0)
	assert_eq(hud.boosts_label.text, "Rocket: 1.5 s")
	assert_true(hud.rocket_bar.visible)
	assert_almost_eq(hud.rocket_bar.value, 1.0, 0.0001, "a full tank")
	main._unhandled_input(_key(true))
	for i in 42:
		main.advance(1.0 / 60.0)
	assert_eq(hud.boosts_label.text, "Rocket: 0.8 s", "0.7 s burned")
	assert_almost_eq(hud.rocket_bar.value, 0.8 / 1.5, 0.0001)
	await wait_frames(2)
	assert_true(main.get_viewport().get_visible_rect().encloses(hud.rocket_bar.get_global_rect()), "on screen")
