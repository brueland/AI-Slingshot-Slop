extends GutTest
# Task 232: Space fires the rocket while it is held: main.gd passes the key going up to the session (a release before
# the first shot does nothing), and How to play says to hold it.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_232_save.json"
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


func test_hold_space() -> void:
	var main = _main()
	main._unhandled_input(_key(false))
	main.progress.levels = {"boosts": 2}
	main.start_game()
	main.launch_with_pull(PULL)
	main.advance(1.0 / 60.0)
	main._unhandled_input(_key(true))
	assert_true(main.session.sim.is_boosting(), "pressed: the rocket fires")
	for i in 12:
		main.advance(1.0 / 60.0)
	assert_almost_eq(float(main.session.sim.boost_fuel), 0.8, 0.001, "12 frames of burn")
	main._unhandled_input(_key(false))
	assert_false(main.session.sim.is_boosting(), "released: it stops")
	for i in 12:
		main.advance(1.0 / 60.0)
	assert_almost_eq(float(main.session.sim.boost_fuel), 0.8, 0.001, "no burn while the key is up")
	main._unhandled_input(_key(true))
	assert_true(main.session.sim.is_boosting(), "pressed again")
	var help := FileAccess.get_file_as_string("res://scripts/ui/help_panel.gd")
	assert_true(help.contains("Hold Space"), "How to play says to hold Space")
