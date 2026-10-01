extends GutTest
# Task 240: "fight" goals: every 10th roguelike round (from round 10) is a boss fight; the goal is met when the boss's
# HP is 0 after a shot, its progress is the share of HP knocked off, and fight rounds are never lucky.


func test_fight_goals() -> void:
	var g = load("res://scripts/core/rogue_goals.gd")
	for r in [10, 20, 30, 40]:
		assert_true(g.is_fight_round(r), "round %d is a boss fight" % r)
	for r in [1, 5, 9, 11, 12, 15, 19, 21]:
		assert_false(g.is_fight_round(r), "round %d is not" % r)
	for s in 200:
		for r in [10, 20, 30]:
			assert_false(g.is_lucky_round(r, s), "a boss fight is never lucky")
	var goal := {"type": "fight", "target": 12.0, "round": 10, "text": "Boss: 12 HP, 4 shots left"}
	assert_false(g.check(goal, {"distance": 80.0, "boss_hp": 3}))
	assert_true(g.check(goal, {"distance": 80.0, "boss_hp": 0}), "knocked out")
	assert_false(g.check(goal, {"distance": 80.0}), "no boss in the result, not beaten")
	assert_almost_eq(g.progress_ratio(goal, {"boss_hp": 3}), 0.75, 0.0001, "three quarters of its HP gone")
	assert_almost_eq(g.progress_ratio(goal, {"boss_hp": 12}), 0.0, 0.0001)
	assert_eq(g.progress_text(goal, {"boss_hp": 3}), "Boss HP 3/12")
	assert_eq(g.describe("fight", 12.0), "Beat the boss (12 HP)")
