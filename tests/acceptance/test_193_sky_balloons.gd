extends GutTest
# Task 193: three hot-air balloons far off in the sky, drifting slowly and bobbing.

const PATH := "res://scripts/game/sky_balloons.gd"


func test_sky_balloons() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var sky = load(PATH).new()
	add_child_autofree(sky)
	assert_eq(sky.START_M.size(), 3)
	var start: Vector2 = sky.balloon_position_m(0)
	sky.advance(10.0)
	var later: Vector2 = sky.balloon_position_m(0)
	assert_almost_eq(later.x - start.x, 6.0, 0.0001, "drifts 0.6 m/s")
	for i in 3:
		var p: Vector2 = sky.balloon_position_m(i)
		assert_between(p.y, sky.START_M[i].y - 1.5, sky.START_M[i].y + 1.5, "bobs gently")
	await wait_process_frames(2)
	pass_test("the balloons draw without errors")
