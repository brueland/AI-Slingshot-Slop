extends GutTest
# Task 302: from 600 m up the sky is thick with stars (most 4 x 4 m cells hold one, the same in every shot); flying
# through collects them, and they count with the course's stars (score, result, HUD).

const PATH := "res://scripts/core/star_cloud.gd"


func test_star_cloud() -> void:
	var sc = load(PATH)
	assert_eq(sc.star_in(Vector2i(10, 100)), Vector2.INF, "nothing below 600 m")
	var filled := 0
	for cx in 100:
		var star: Vector2 = sc.star_in(Vector2i(cx, 175))
		if star != Vector2.INF:
			filled += 1
			assert_true(Rect2(Vector2(cx, 175) * 4.0, Vector2(4.0, 4.0)).has_point(star), "inside its cell")
			assert_eq(sc.star_in(Vector2i(cx, 175)), star, "the same every time")
	assert_between(filled, 45, 75, "most cells hold a star")
	var cloud = sc.new()
	cloud.pickup_radius = 1.5
	var sim := FlightSim.new()
	sim.position = Vector2(300.0, 702.0)
	cloud.after_step(sim, Vector2(100.0, 702.0))
	var expected := 0
	for cx in range(24, 77):
		for cy in range(174, 178):
			var star: Vector2 = sc.star_in(Vector2i(cx, cy))
			if star != Vector2.INF and Geometry2D.get_closest_point_to_segment(star, Vector2(100.0, 702.0), Vector2(300.0, 702.0)).distance_to(star) <= 1.5:
				expected += 1
	assert_gt(expected, 10, "a ton of stars on 200 m")
	assert_eq(cloud.count, expected, "every star within reach of the path")
	cloud.after_step(sim, Vector2(100.0, 702.0))
	assert_eq(cloud.count, expected, "each only once")
	var s = load("res://scripts/core/run_session.gd").new(PlayerStats.new(), 5)
	s.cloud.count = 7
	assert_eq(s.stars_collected(), 7, "cloud stars count with the course's")
	assert_eq(s.result()["stars"], 7)
	assert_eq(s.result()["cloud_stars"], 7)
	assert_true(FileAccess.get_file_as_string("res://scripts/game/main.gd").contains("session.stars_collected()"), "the HUD shows them")
