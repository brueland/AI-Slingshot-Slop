extends GutTest
# Task 074: scripts/core/rogue_goals.gd, the roguelike goals: five types whose targets grow every round with no
# cap, a random type per round (round 1 is always distance, star goals only from round 4), a text for the HUD,
# and a check against a run result.

const PATH := "res://scripts/core/rogue_goals.gd"


func _g():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH)


func test_targets_grow_every_round() -> void:
	var g = _g()
	if g == null:
		return
	assert_eq(g.TYPES, ["distance", "height", "zone", "bounces", "stars"])
	assert_almost_eq(g.ZONE_WIDTH, 12.0, 0.0001)
	assert_eq(g.STARS_FROM_ROUND, 4)
	var want := {
		"distance": {1: 40.0, 2: 45.0, 5: 63.0, 10: 111.0},
		"height": {1: 8.0, 5: 13.0, 10: 22.0},
		"zone": {1: 30.0, 5: 44.0, 10: 71.0},
		"bounces": {1: 1.0, 3: 1.0, 4: 2.0, 8: 3.0, 12: 4.0},
		"stars": {1: 1.0, 9: 1.0, 10: 2.0, 20: 3.0},
	}
	for type in want:
		for r in want[type]:
			assert_almost_eq(g.target_for(type, r), want[type][r], 0.0001, "%s round %d" % [type, r])
	assert_gt(g.target_for("distance", 50), g.target_for("distance", 49), "no cap: round 50 is harder than 49")
	assert_almost_eq(g.target_for("distance", 0), 40.0, 0.0001, "rounds below 1 count as round 1")


func test_make_goal() -> void:
	var g = _g()
	if g == null:
		return
	var first: Dictionary = g.make_goal(1, 123)
	assert_eq(first.get("type"), "distance", "round 1 is always a distance goal")
	assert_almost_eq(float(first.get("target", 0.0)), 40.0, 0.0001)
	assert_eq(first.get("round"), 1)
	assert_eq(first.get("text"), "Fly at least 40 m")
	assert_eq(g.make_goal(7, 555), g.make_goal(7, 555), "same round and seed, same goal")
	var seen := {}
	for r in range(2, 40):
		var goal: Dictionary = g.make_goal(r, 42)
		seen[goal["type"]] = true
		assert_almost_eq(float(goal["target"]), g.target_for(goal["type"], r), 0.0001)
	assert_eq(seen.size(), 5, "every goal type shows up over many rounds")
	for s in 300:
		for r in [2, 3]:
			assert_ne(g.make_goal(r, s)["type"], "stars", "no star goals before round 4 (seed %d round %d)" % [s, r])


func test_describe() -> void:
	var g = _g()
	if g == null:
		return
	assert_eq(g.describe("distance", 63.0), "Fly at least 63 m")
	assert_eq(g.describe("height", 9.0), "Reach 9 m high")
	assert_eq(g.describe("bounces", 4.0), "Bounce 4 times")
	assert_eq(g.describe("stars", 1.0), "Collect 1 star")
	assert_eq(g.describe("stars", 3.0), "Collect 3 stars")
	assert_eq(g.describe("zone", 44.0), "Stop between 44 and 56 m")


func test_check() -> void:
	var g = _g()
	if g == null:
		return
	var r := {"distance": 64.0, "max_height": 9.5, "bounces": 4, "stars": 2}
	assert_true(g.check({"type": "distance", "target": 63.0}, r))
	assert_false(g.check({"type": "distance", "target": 65.0}, r))
	assert_true(g.check({"type": "height", "target": 9.0}, r))
	assert_false(g.check({"type": "height", "target": 10.0}, r))
	assert_true(g.check({"type": "bounces", "target": 4.0}, r))
	assert_false(g.check({"type": "stars", "target": 3.0}, r))
	assert_true(g.check({"type": "zone", "target": 52.0}, r), "64 is inside 52..64")
	assert_true(g.check({"type": "zone", "target": 64.0}, r), "the edges count")
	assert_false(g.check({"type": "zone", "target": 44.0}, r), "64 is past 44..56")
	assert_false(g.check({"type": "zone", "target": 65.0}, r), "not there yet")
	assert_false(g.check({"type": "juggle", "target": 1.0}, r))
