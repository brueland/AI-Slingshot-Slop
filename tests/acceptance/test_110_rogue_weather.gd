extends GutTest
# Task 110: scripts/core/rogue_weather.gd, roguelike weather. From round 3 every round has a weather (Tailwind,
# Headwind, Thick Air, Springy or Soggy Ground, or Calm) that changes the shot a little; RogueRun keeps the round's
# weather (a retry keeps it) and its stats include it.

const PATH := "res://scripts/core/rogue_weather.gd"
const RUN := "res://scripts/core/rogue_run.gd"
const STATS := "res://scripts/core/player_stats.gd"


func _w():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH)


func test_list_and_rounds() -> void:
	var w = _w()
	if w == null:
		return
	assert_eq(w.FROM_ROUND, 3)
	var ids := []
	for entry in w.LIST:
		ids.append(entry["id"])
	assert_eq(ids, ["calm", "tailwind", "headwind", "thick_air", "springy", "soggy"])
	assert_eq(w.get_def("tailwind")["name"], "Tailwind")
	assert_eq(w.get_def("snow"), {})
	assert_eq(w.for_round(1, 42), "calm")
	assert_eq(w.for_round(2, 42), "calm")
	assert_eq(w.for_round(9, 42), w.for_round(9, 42), "same seed and round, same weather")
	var seen := {}
	for r in range(3, 80):
		seen[w.for_round(r, 42)] = true
	assert_eq(seen.size(), 6, "every weather shows up")


func test_apply() -> void:
	var w = _w()
	if w == null:
		return
	var base = load(STATS).from_levels({})
	assert_almost_eq(w.apply(load(STATS).from_levels({}), "tailwind").max_speed, 22.0 * 1.08, 0.0001)
	assert_almost_eq(w.apply(load(STATS).from_levels({}), "headwind").max_speed, 22.0 * 0.92, 0.0001)
	assert_almost_eq(w.apply(load(STATS).from_levels({}), "thick_air").drag, 0.002 * 1.5, 0.000001)
	assert_almost_eq(w.apply(load(STATS).from_levels({}), "springy").restitution, 0.45, 0.0001)
	assert_almost_eq(w.apply(load(STATS).from_levels({}), "soggy").restitution, 0.25, 0.0001)
	var calm = w.apply(load(STATS).from_levels({}), "calm")
	assert_almost_eq(calm.max_speed, base.max_speed, 0.0001)
	assert_almost_eq(calm.drag, base.drag, 0.000001)
	var odd = w.apply(load(STATS).from_levels({}), "snow")
	assert_almost_eq(odd.max_speed, 22.0, 0.0001, "unknown weather counts as calm")
	var high = load(STATS).from_levels({})
	high.restitution = 0.85
	assert_almost_eq(w.apply(high, "springy").restitution, 0.9, 0.0001, "bounciness stays within 0.1-0.9")


func test_run_weather() -> void:
	if _w() == null:
		return
	var r = load(RUN).new()
	r.start(42)
	assert_eq(r.get("weather"), "calm")
	r.finish_shot({"distance": 45.0})
	assert_eq(r.round_number, 2)
	assert_eq(r.weather, "calm", "round 2 is still calm")
	r.goal = {"type": "distance", "target": 1.0, "round": 2, "text": "Fly at least 1 m"}
	r.finish_shot({"distance": 45.0})
	assert_eq(r.round_number, 3)
	assert_eq(r.weather, _w().for_round(3, 42), "a new round rolls its weather")
	var before: String = r.weather
	r.finish_shot({"distance": 0.0, "max_height": 0.0, "bounces": 0, "stars": 0})
	assert_eq(r.weather, before, "a retry keeps the weather")
	r.weather = "tailwind"
	assert_almost_eq(r.stats().max_speed, 22.0 * 1.08, 0.0001, "the stats include the weather")
	r.start(7)
	assert_eq(r.weather, "calm", "a new run starts calm")
