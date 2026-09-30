extends GutTest
# Task 191: a windsock that points with the roguelike wind and droops without it.

const PATH := "res://scripts/game/wind_sock.gd"


func test_wind_sock() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var script = load(PATH)
	assert_eq(script.direction_for("tailwind"), 1.0)
	assert_eq(script.direction_for("headwind"), -1.0)
	assert_eq(script.direction_for("calm"), 0.0)
	assert_eq(script.direction_for("thick_air"), 0.0)
	var sock = script.new()
	add_child_autofree(sock)
	assert_gt(sock.tip_offset().y, 20.0, "droops without wind")
	sock.set_weather("tailwind")
	assert_eq(sock.direction, 1.0)
	assert_eq(sock.tip_offset().x, 30.0, "points right with a tailwind")
	sock.set_weather("headwind")
	assert_eq(sock.tip_offset().x, -30.0, "points left with a headwind")
	var before: Vector2 = sock.tip_offset()
	sock.advance(0.2)
	assert_ne(sock.tip_offset(), before, "it flaps")
	await wait_process_frames(2)
	pass_test("the windsock draws without errors")
