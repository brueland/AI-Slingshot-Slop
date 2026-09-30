extends GutTest
# Task 126: keyboard aiming. The arrow keys start aiming and change the angle (up/down, 2 degrees) and power
# (left/right, 5%); Enter launches with that pull.

const PATH := "res://scripts/game/slingshot.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_126_save.json"


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func _key(code: int) -> InputEventKey:
	var e := InputEventKey.new()
	e.keycode = code
	e.pressed = true
	return e


func test_key_aim() -> void:
	var s = load(PATH).new()
	add_child_autofree(s)
	watch_signals(s)
	assert_almost_eq(s.key_angle, 45.0, 0.0001)
	assert_almost_eq(s.key_power, 0.8, 0.0001)
	assert_false(s.key_aim(KEY_ENTER), "Enter does nothing before aiming")
	assert_true(s.key_aim(KEY_UP))
	assert_true(s.key_aiming)
	assert_true(s.dragging, "the band is pulled while aiming with keys")
	assert_almost_eq(s.key_angle, 47.0, 0.0001)
	s.key_aim(KEY_LEFT)
	assert_almost_eq(s.key_power, 0.75, 0.0001)
	assert_eq(s.pull, s.key_pull())
	var r := deg_to_rad(47.0)
	assert_true(s.key_pull().is_equal_approx(Vector2(-cos(r), sin(r)) * 120.0 * 0.75))
	for i in 40:
		s.key_aim(KEY_DOWN)
	assert_almost_eq(s.key_angle, 5.0, 0.0001, "the angle stays within 5-85 degrees")
	assert_false(s.key_aim(KEY_A), "other keys are not used")
	var expected: Vector2 = s.key_pull()
	assert_true(s.key_aim(KEY_ENTER))
	assert_signal_emitted_with_parameters(s, "launched", [expected])
	assert_false(s.key_aiming)
	assert_false(s.dragging)
	assert_eq(s.last_pull, expected, "remembered like a mouse shot")
	s.enabled = false
	assert_false(s.key_aim(KEY_UP), "not while disabled")


func test_keyboard_shot_in_the_game() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	main.start_game()
	main.slingshot._unhandled_input(_key(KEY_RIGHT))
	main.slingshot._unhandled_input(_key(KEY_RIGHT))
	main.advance(1.0 / 60.0)
	assert_gt(main.trajectory.points.size(), 0, "the aim preview shows while aiming with keys")
	main.slingshot._unhandled_input(_key(KEY_ENTER))
	assert_eq(main.state_name(), "FLIGHT", "Enter launched")
