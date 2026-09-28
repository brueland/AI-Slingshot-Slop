extends GutTest
# Task 002: scripts/core/launch_math.gd turns a slingshot pull (screen pixels, y down) into a launch
# velocity (world m/s, y up). docs/DESIGN.md section 9, LaunchMath.

const PATH := "res://scripts/core/launch_math.gd"


func _lm():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH)


func test_zero_pull_gives_zero_velocity() -> void:
	var lm = _lm()
	if lm == null:
		return
	assert_eq(lm.velocity_from_pull(Vector2.ZERO, 120.0, 22.0), Vector2.ZERO)


func test_full_pull_straight_back_launches_forward_at_max_speed() -> void:
	var lm = _lm()
	if lm == null:
		return
	var v: Vector2 = lm.velocity_from_pull(Vector2(-120, 0), 120.0, 22.0)
	assert_almost_eq(v.x, 22.0, 0.0001)
	assert_almost_eq(v.y, 0.0, 0.0001)


func test_pull_left_and_down_flies_right_and_up() -> void:
	var lm = _lm()
	if lm == null:
		return
	var v: Vector2 = lm.velocity_from_pull(Vector2(-60, 60), 120.0, 22.0)
	# length 84.85 of 120 = 70.7 % strength, direction 45 degrees up-right
	assert_almost_eq(v.x, 11.0, 0.001)
	assert_almost_eq(v.y, 11.0, 0.001)
	var w: Vector2 = lm.velocity_from_pull(Vector2(-100, 50), 120.0, 22.0)
	assert_gt(w.x, 0.0, "pulling left must launch to the right")
	assert_gt(w.y, 0.0, "pulling down on screen must launch upward")
	assert_almost_eq(w.y / w.x, 0.5, 0.0001)


func test_overlong_pull_is_clamped() -> void:
	var lm = _lm()
	if lm == null:
		return
	var v: Vector2 = lm.velocity_from_pull(Vector2(-300, 0), 120.0, 22.0)
	assert_almost_eq(v.length(), 22.0, 0.0001)


func test_clamp_pull() -> void:
	var lm = _lm()
	if lm == null:
		return
	var p: Vector2 = lm.clamp_pull(Vector2(300, 400), 120.0)
	assert_almost_eq(p.x, 72.0, 0.0001)
	assert_almost_eq(p.y, 96.0, 0.0001)
	assert_eq(lm.clamp_pull(Vector2(3, 4), 120.0), Vector2(3, 4))


func test_non_positive_max_pull_gives_zero() -> void:
	var lm = _lm()
	if lm == null:
		return
	assert_eq(lm.velocity_from_pull(Vector2(-50, 20), 0.0, 22.0), Vector2.ZERO)
