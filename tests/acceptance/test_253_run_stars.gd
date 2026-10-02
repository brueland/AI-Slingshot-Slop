extends GutTest
# Task 253: a roguelike run counts its stars and keeps the boost each one gave; the run's stats (and so every
# following shot, and every prediction made with stats()) include the boosts, and a new run starts with none.


func _expected(run) -> PlayerStats:
	var s := RogueSizes.apply(RoguePerks.apply(PlayerStats.from_levels({}), run.perks), run.size_id)
	return RogueWeather.apply(StarBoosts.apply(s, run.star_boosts), run.weather)


func test_stars_in_the_run() -> void:
	var run = load("res://scripts/core/rogue_run.gd").new()
	run.start(31)
	assert_eq(run.stars_total, 0)
	assert_eq(run.star_boosts, {})
	var out: Dictionary = run.finish_shot({"distance": 50.0, "stars": 3})
	assert_eq(run.stars_total, 3)
	assert_eq(out["stars_total"], 3)
	assert_eq(out["stars_gained"], [StarBoosts.roll(31, 1), StarBoosts.roll(31, 2), StarBoosts.roll(31, 3)])
	var total := 0
	for id in run.star_boosts:
		total += int(run.star_boosts[id])
	assert_eq(total, 3, "one boost per star")
	out = run.finish_shot({"distance": 5.0, "stars": 1})
	assert_eq(out["stars_gained"], [StarBoosts.roll(31, 4)], "the fourth star of the run")
	assert_eq(run.finish_shot({"distance": 5.0})["stars_gained"], [], "no stars, no boosts")
	var s: PlayerStats = run.stats()
	var e := _expected(run)
	assert_almost_eq(s.max_speed, e.max_speed, 0.0001, "the stats include the boosts")
	assert_almost_eq(s.drag, e.drag, 0.0000001)
	assert_almost_eq(s.restitution, e.restitution, 0.0001)
	assert_almost_eq(s.launch_height, e.launch_height, 0.0001)
	run.start(32)
	assert_eq(run.stars_total, 0, "a new run starts with no stars")
	assert_eq(run.star_boosts, {})
