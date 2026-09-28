extends GutTest
# Task 036: main.gd handles the keyboard in _unhandled_input: the "boost" action (Space, defined in
# project.godot) spends a boost during flight, and "ui_cancel" (Esc) toggles pause while aiming or flying.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_036_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func _main():
	if not ResourceLoader.exists(SCENE):
		fail_test("missing " + SCENE)
		return null
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	return main


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func _action(name: String) -> InputEventAction:
	var e := InputEventAction.new()
	e.action = name
	e.pressed = true
	return e


func test_boost_action_is_space() -> void:
	assert_true(InputMap.has_action("boost"), "project.godot defines the boost action")
	var has_space := false
	for e in InputMap.action_get_events("boost"):
		if e is InputEventKey and (e.physical_keycode == KEY_SPACE or e.keycode == KEY_SPACE):
			has_space = true
	assert_true(has_space)


func test_boost_key_spends_a_boost_in_flight() -> void:
	var main = _main()
	if main == null:
		return
	main.progress.levels = {"boosts": 1}
	main.start_game()
	main._unhandled_input(_action("boost"))
	assert_eq(main.session.sim.boost_charges, 1, "no boosting while aiming")
	main.launch_with_pull(FULL_PULL_45)
	main.advance(1.0 / 60.0)
	main._unhandled_input(_action("boost"))
	assert_eq(main.session.sim.boost_charges, 0)


func test_escape_pauses_and_resumes_the_flight() -> void:
	var main = _main()
	if main == null:
		return
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	main.advance(1.0 / 60.0)
	main._unhandled_input(_action("ui_cancel"))
	assert_true(main.is_paused)
	assert_true(main.pause_label is Label and main.pause_label.visible, "a visible pause_label while paused")
	var x: float = main.session.sim.position.x
	for i in 10:
		main.advance(1.0 / 60.0)
	assert_eq(main.session.sim.position.x, x, "nothing moves while paused")
	assert_false(main.request_boost())
	main._unhandled_input(_action("ui_cancel"))
	assert_false(main.is_paused)
	assert_false(main.pause_label.visible)
	main.advance(1.0 / 60.0)
	assert_gt(main.session.sim.position.x, x)


func test_pause_while_aiming_disables_the_slingshot() -> void:
	var main = _main()
	if main == null:
		return
	main.start_game()
	main.toggle_pause()
	assert_true(main.is_paused)
	assert_false(main.slingshot.enabled)
	main.toggle_pause()
	assert_true(main.slingshot.enabled)


func test_no_pause_on_menus() -> void:
	var main = _main()
	if main == null:
		return
	main.toggle_pause()
	assert_false(main.is_paused, "no pause on the title screen")
