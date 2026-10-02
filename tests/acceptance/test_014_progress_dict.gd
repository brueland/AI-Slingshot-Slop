extends GutTest
# Task 014: Progress.to_dict() and Progress.from_dict() for saving (docs/DESIGN.md section 9).
# from_dict must accept anything a damaged or old save file could contain.

const PATH := "res://scripts/core/progress.gd"


func _script():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH)


func _sample(script):
	var p = script.new()
	p.coins = 345
	p.levels = {"power": 3, "aero": 1}
	p.best_distance = 123.5
	p.total_runs = 7
	p.goal_reached = true
	return p


func test_to_dict_contents() -> void:
	var script = _script()
	if script == null:
		return
	var d: Dictionary = _sample(script).to_dict()
	assert_eq(d.get("version"), 1)
	assert_eq(d.get("coins"), 345)
	assert_eq(d.get("levels"), {"power": 3, "aero": 1})
	assert_almost_eq(float(d.get("best_distance", 0.0)), 123.5, 0.0001)
	assert_eq(d.get("total_runs"), 7)
	assert_eq(d.get("goal_reached"), true)


func test_to_dict_copies_levels() -> void:
	var script = _script()
	if script == null:
		return
	var p = _sample(script)
	var d: Dictionary = p.to_dict()
	d["levels"]["power"] = 9
	assert_eq(p.level_of("power"), 3, "changing the dictionary must not change the Progress")


func test_round_trip_through_json() -> void:
	var script = _script()
	if script == null:
		return
	var text := JSON.stringify(_sample(script).to_dict())
	var q = script.from_dict(JSON.parse_string(text))
	assert_eq(q.coins, 345)
	assert_eq(typeof(q.coins), TYPE_INT, "JSON numbers come back as floats; convert them to int")
	assert_eq(q.level_of("power"), 3)
	assert_eq(typeof(q.level_of("power")), TYPE_INT)
	assert_eq(q.level_of("aero"), 1)
	assert_almost_eq(q.best_distance, 123.5, 0.0001)
	assert_eq(q.total_runs, 7)
	assert_true(q.goal_reached)


func test_from_empty_dict_gives_defaults() -> void:
	var script = _script()
	if script == null:
		return
	var q = script.from_dict({})
	assert_eq(q.coins, 0)
	assert_eq(q.levels, {})
	assert_eq(q.total_runs, 0)
	assert_false(q.goal_reached)


func test_from_dict_repairs_bad_values() -> void:
	var script = _script()
	if script == null:
		return
	var q = script.from_dict({"coins": -5, "levels": {"power": 99, "laser": 2, "aero": 3.0, "bounce": -1},
		"best_distance": -3.0, "total_runs": -2})
	assert_eq(q.coins, 0, "negative coins become 0")
	assert_eq(q.level_of("power"), 25, "clamped to max level (25 since task 272)")
	assert_false(q.levels.has("laser"), "unknown upgrade ids are dropped")
	assert_eq(q.level_of("aero"), 3)
	assert_eq(q.level_of("bounce"), 0)
	assert_almost_eq(q.best_distance, 0.0, 0.0001)
	assert_eq(q.total_runs, 0)
	var r = script.from_dict({"levels": 5})
	assert_eq(r.levels, {}, "levels that are not a dictionary are ignored")
