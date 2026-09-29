extends GutTest
# Task 060: the slingshot looks like one: 12 px untinted wooden posts, bands that are always visible (resting at
# the pouch), and a power meter above it while pulling that goes green -> yellow -> red.

const PATH := "res://scripts/game/slingshot.gd"
const LOW := Color(0.3, 0.9, 0.3)
const MID := Color(1.0, 0.9, 0.2)
const HIGH := Color(1.0, 0.3, 0.2)


func _sling():
	var s = load(PATH).new()
	s.position = Vector2(0, -32)
	add_child_autofree(s)
	return s


func test_constants() -> void:
	var consts: Dictionary = load(PATH).get_script_constant_map()
	assert_almost_eq(float(consts.get("POST_WIDTH", 0.0)), 12.0, 0.001, "Slingshot.POST_WIDTH")
	assert_eq(consts.get("POWER_LOW"), LOW)
	assert_eq(consts.get("POWER_MID"), MID)
	assert_eq(consts.get("POWER_HIGH"), HIGH)


func test_power_ratio() -> void:
	var s = _sling()
	assert_almost_eq(s.power_ratio(), 0.0, 0.0001, "no pull, no power")
	s.begin_drag(Vector2(0, -32))
	s.update_drag(Vector2(-60, -32))
	assert_almost_eq(s.power_ratio(), 0.5, 0.0001)
	s.update_drag(Vector2(-500, -32))
	assert_almost_eq(s.power_ratio(), 1.0, 0.0001, "clamped at full pull")


func test_power_color() -> void:
	var sc = load(PATH)
	assert_true(sc.power_color(0.0).is_equal_approx(LOW), "green at no pull")
	assert_true(sc.power_color(0.5).is_equal_approx(MID), "yellow at half")
	assert_true(sc.power_color(1.0).is_equal_approx(HIGH), "red at full")
	assert_true(sc.power_color(0.25).is_equal_approx(LOW.lerp(MID, 0.5)))
	assert_true(sc.power_color(0.75).is_equal_approx(MID.lerp(HIGH, 0.5)))


func test_draws_at_rest_and_while_pulling() -> void:
	var s = _sling()
	await wait_process_frames(2)
	s.begin_drag(Vector2(0, -32))
	s.update_drag(Vector2(-90, 10))
	await wait_process_frames(2)
	pass_test("drawing with and without a pull raises no errors")
