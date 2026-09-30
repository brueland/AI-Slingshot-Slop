extends GutTest
# Task 157: lucky roguelike rounds: from round 4, about one in eight (never a boss round); meeting one gives a reroll.


func test_lucky_rounds() -> void:
	var g = load("res://scripts/core/rogue_goals.gd")
	assert_true(g.is_lucky_round(9, 7))
	assert_false(g.is_lucky_round(8, 7))
	assert_false(g.is_lucky_round(1, 0), "never before round 4")
	for s in 200:
		assert_false(g.is_lucky_round(12, s), "a boss round is never lucky")
	var count := 0
	for r in range(4, 404):
		if g.is_lucky_round(r, 3):
			count += 1
	assert_between(count, 30, 70, "about one round in eight")
	var run = load("res://scripts/core/rogue_run.gd").new()
	run.start(7)
	run.round_number = 9
	run.goal = {"type": "distance", "target": 10.0, "round": 9, "text": "Fly at least 10 m"}
	var rerolls: int = run.rerolls
	var out: Dictionary = run.finish_shot({"distance": 50.0})
	assert_true(out.get("lucky"))
	assert_eq(run.rerolls, rerolls + 1, "a lucky round gives a reroll")
	run.goal = {"type": "distance", "target": 10.0, "round": 10, "text": "Fly at least 10 m"}
	out = run.finish_shot({"distance": 50.0})
	assert_false(out.get("lucky"))
