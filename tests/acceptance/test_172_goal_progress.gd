extends GutTest
# Task 172: RogueGoals.progress_ratio (how close a shot came to a goal, 0-1) and progress_text (the live readout).


func test_ratio_and_text() -> void:
	var g = load("res://scripts/core/rogue_goals.gd")
	var dist := {"type": "distance", "target": 50.0}
	assert_almost_eq(g.progress_ratio(dist, {"distance": 40.0}), 0.8, 0.0001)
	assert_eq(g.progress_ratio(dist, {"distance": 80.0}), 1.0, "never above 1")
	assert_eq(g.progress_text(dist, {"distance": 34.7}), "34/50 m")
	var high := {"type": "height", "target": 20.0}
	assert_almost_eq(g.progress_ratio(high, {"max_height": 5.0}), 0.25, 0.0001)
	assert_eq(g.progress_text(high, {"max_height": 5.0}), "5/20 m high")
	var hop := {"type": "bounces", "target": 4.0}
	assert_almost_eq(g.progress_ratio(hop, {"bounces": 3}), 0.75, 0.0001)
	assert_eq(g.progress_text(hop, {"bounces": 3}), "3/4 bounces")
	var star := {"type": "stars", "target": 2.0}
	assert_eq(g.progress_ratio(star, {}), 0.0)
	assert_eq(g.progress_text(star, {"stars": 0}), "0/2 stars")
	var zone := {"type": "zone", "target": 40.0}
	assert_eq(g.progress_ratio(zone, {"distance": 45.0}), 1.0, "inside the zone")
	assert_almost_eq(g.progress_ratio(zone, {"distance": 30.0}), 0.75, 0.0001, "short of the zone")
	assert_almost_eq(g.progress_ratio(zone, {"distance": 120.0}), 0.5, 0.0001, "past the zone (40..60 since task 226)")
	assert_eq(g.progress_text(zone, {"distance": 45.2}), "45 m (stop at 40-60 m)")
	var boss := {"type": "boss", "parts": [dist, hop]}
	assert_almost_eq(g.progress_ratio(boss, {"distance": 50.0, "bounces": 1}), 0.25, 0.0001, "the weakest part")
	assert_eq(g.progress_text(boss, {"distance": 50.0, "bounces": 1}), "50/50 m  +  1/4 bounces")
	assert_eq(g.progress_ratio({}, {}), 0.0)
	assert_eq(g.progress_text({}, {}), "")
	for r in range(1, 30):
		var goal: Dictionary = g.make_goal(r, 5)
		assert_between(g.progress_ratio(goal, {"distance": 1.0}), 0.0, 1.0)
		assert_ne(g.progress_text(goal, {}), "", "every goal type has a readout")
