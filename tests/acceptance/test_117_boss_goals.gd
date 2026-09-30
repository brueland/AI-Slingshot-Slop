extends GutTest
# Task 117: roguelike boss goals. From round 12, every 6th round is a boss round with two goals of different types at
# once (never distance together with zone); a boss goal is met only when both parts are.

const PATH := "res://scripts/core/rogue_goals.gd"


func test_boss_rounds() -> void:
	var g = load(PATH)
	assert_eq(g.get_script_constant_map().get("BOSS_FROM_ROUND"), 12)
	assert_eq(g.get_script_constant_map().get("BOSS_EVERY"), 6)
	for r in [1, 6, 10, 11, 13, 17]:
		assert_false(g.is_boss_round(r), "round %d is not a boss round" % r)
	for r in [12, 18, 24, 60]:
		assert_true(g.is_boss_round(r), "round %d is a boss round" % r)


func test_make_boss_goal() -> void:
	var g = load(PATH)
	for s in 40:
		var boss: Dictionary = g.make_boss_goal(12, s)
		assert_eq(boss["type"], "boss")
		assert_eq(boss["round"], 12)
		var parts: Array = boss["parts"]
		assert_eq(parts.size(), 2)
		var a: Dictionary = parts[0]
		var b: Dictionary = parts[1]
		assert_ne(a["type"], "boss")
		assert_ne(a["type"], b["type"], "two different goals")
		assert_false(a["type"] in ["distance", "zone"] and b["type"] in ["distance", "zone"], "distance and zone never together")
		assert_eq(a, g.make_goal(12, s), "the first part is the round's usual goal")
		assert_eq(boss["text"], "BOSS: %s + %s" % [a["text"], b["text"]])
	assert_eq(g.make_boss_goal(18, 5), g.make_boss_goal(18, 5), "same round and seed, same boss")


func test_check_needs_both_parts() -> void:
	var g = load(PATH)
	var boss := {"type": "boss", "target": 0.0, "parts": [{"type": "distance", "target": 100.0}, {"type": "bounces", "target": 3.0}]}
	assert_true(g.check(boss, {"distance": 120.0, "bounces": 3}))
	assert_false(g.check(boss, {"distance": 120.0, "bounces": 2}), "one part is not enough")
	assert_false(g.check(boss, {"distance": 90.0, "bounces": 5}))
	assert_false(g.check({"type": "boss", "target": 0.0, "parts": []}, {"distance": 500.0}), "an empty boss is never met")
	assert_true(g.check({"type": "distance", "target": 40.0}, {"distance": 45.0}), "normal goals are unchanged")
