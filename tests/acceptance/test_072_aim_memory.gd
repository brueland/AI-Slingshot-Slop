extends GutTest
# Task 072: the slingshot remembers the pull of the last launch and, when show_last_aim is on, draws a dashed line
# from that pull point forward through the anchor plus a ghost pouch, so a good shot can be repeated.

const PATH := "res://scripts/game/slingshot.gd"


func _sling():
	var s = load(PATH).new()
	s.position = Vector2(0, -32)
	add_child_autofree(s)
	return s


func _shoot(s, offset: Vector2) -> Vector2:
	s.begin_drag(Vector2(0, -32))
	s.update_drag(Vector2(0, -32) + offset)
	return s.release()


func test_constants_and_defaults() -> void:
	var consts: Dictionary = load(PATH).get_script_constant_map()
	assert_almost_eq(float(consts.get("AIM_LINE_LENGTH", 0.0)), 2.5, 0.0001)
	var s = _sling()
	assert_eq(s.get("last_pull"), Vector2.ZERO)
	assert_eq(s.get("show_last_aim"), false, "off unless unlocked")
	assert_eq(s.aim_line_points().size(), 0)


func test_remembers_the_last_launch() -> void:
	var s = _sling()
	_shoot(s, Vector2(-100, 32))
	assert_eq(s.last_pull, Vector2(-100, 32))
	assert_eq(s.aim_line_points().size(), 0, "hidden while show_last_aim is off")
	s.show_last_aim = true
	var pts: PackedVector2Array = s.aim_line_points()
	assert_eq(pts.size(), 2)
	if pts.size() == 2:
		assert_eq(pts[0], Vector2(-100, 32), "starts at the last pull point (the ghost pouch)")
		assert_eq(pts[1], Vector2(250, -80), "points forward along the launch: -pull * 2.5")


func test_only_real_launches_are_remembered() -> void:
	var s = _sling()
	s.show_last_aim = true
	_shoot(s, Vector2(-80, 40))
	_shoot(s, Vector2(-3, 2))
	assert_eq(s.last_pull, Vector2(-80, 40), "a too-short pull launches nothing and changes nothing")
	s.begin_drag(Vector2(0, -32))
	s.update_drag(Vector2(-50, -32))
	s.cancel_drag()
	assert_eq(s.last_pull, Vector2(-80, 40), "a cancelled drag changes nothing")
	_shoot(s, Vector2(-120, 0))
	assert_eq(s.last_pull, Vector2(-120, 0), "the newest launch replaces it")


func test_draws_the_line() -> void:
	var s = _sling()
	s.show_last_aim = true
	_shoot(s, Vector2(-90, 45))
	await wait_process_frames(2)
	s.begin_drag(Vector2(0, -32))
	s.update_drag(Vector2(-60, 10))
	await wait_process_frames(2)
	pass_test("drawing the aim line (while aiming again too) raises no errors")
