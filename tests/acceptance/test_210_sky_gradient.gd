extends GutTest
# Task 210: SkyGradient, a screen-wide sky from day blue near the ground to black space high up.

const PATH := "res://scripts/game/sky_gradient.gd"


func test_sky_colors() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var s = load(PATH)
	var ground: Array = s.colors_for_height(0.0)
	assert_eq(ground[0], s.TOPS[0])
	assert_eq(ground[1], s.BOTTOMS[0])
	var mid: Array = s.colors_for_height(70.0)
	assert_eq(mid[0], s.TOPS[1].lerp(s.TOPS[2], 0.5), "halfway between 40 m and 100 m")
	assert_true(s.colors_for_height(5000.0)[0].is_equal_approx(s.TOPS[3]), "space")
	assert_eq(s.colors_for_height(-10.0)[0], s.TOPS[0])
	var previous := 10.0
	for h in [0.0, 40.0, 100.0, 180.0]:
		var top: Color = s.colors_for_height(h)[0]
		assert_lt(top.get_luminance(), previous, "darker higher up")
		previous = top.get_luminance()
	var g = s.new()
	add_child_autofree(g)
	assert_eq(g.layer, -100, "behind everything")
	g.set_height(120.0)
	assert_eq(g.height, 120.0)
	await wait_process_frames(2)
	pass_test("the sky draws without errors")
