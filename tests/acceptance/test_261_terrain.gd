extends GutTest
# Task 261: how hilly the ground is: flat at first, then a little hillier as the game goes on (roguelike: 0.12 m more
# every round from round 3; classic: 0.25 m more every 100 m of the best distance), never more than 2.5 m.


func test_how_hilly() -> void:
	var t = load("res://scripts/core/terrain.gd")
	assert_eq(t.MAX_HILLS, 2.5)
	assert_eq(t.for_round(1), 0.0)
	assert_eq(t.for_round(2), 0.0)
	assert_almost_eq(t.for_round(3), 0.12, 0.0001)
	assert_almost_eq(t.for_round(10), 0.96, 0.0001)
	assert_eq(t.for_round(40), 2.5, "capped")
	assert_eq(t.for_best_distance(0.0), 0.0)
	assert_almost_eq(t.for_best_distance(400.0), 1.0, 0.0001)
	assert_eq(t.for_best_distance(5000.0), 2.5)
	var s := PlayerStats.new()
	assert_eq(s.get("hills"), 0.0, "flat by default")
	assert_eq(s.get("flat_spans"), [])
