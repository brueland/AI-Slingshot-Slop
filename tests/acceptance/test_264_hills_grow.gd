extends GutTest
# Task 264: the hills grow as the game goes on: a roguelike shot gets its round's hills (with its landing zones kept
# flat), a classic shot the hills of the best distance.


func test_hills_grow() -> void:
	var run = load("res://scripts/core/rogue_run.gd").new()
	run.start(3)
	assert_eq(run.stats().hills, 0.0, "round 1 is flat")
	run.round_number = 12
	assert_almost_eq(run.stats().hills, Terrain.for_round(12), 0.0001)
	run.goal = {"type": "zone", "target": 60.0, "round": 12, "text": "Stop between 60 and 80 m"}
	assert_eq(run.stats().flat_spans, [Vector2(58.5, 81.5)], "the landing zone stays flat")
	var p := Progress.new()
	assert_eq(p.stats().hills, 0.0)
	p.best_distance = 600.0
	assert_almost_eq(p.stats().hills, 1.5, 0.0001, "classic: hillier as the best distance grows")
