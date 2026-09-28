extends GutTest
# Task 010: scripts/core/scoring.gd computes a run's score (docs/DESIGN.md section 5).

const PATH := "res://scripts/core/scoring.gd"
const STATS_PATH := "res://scripts/core/player_stats.gd"


func _scoring():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH)


func _stats(levels: Dictionary):
	return load(STATS_PATH).from_levels(levels)


func test_base_stats_score() -> void:
	var sc = _scoring()
	if sc == null:
		return
	var r: Dictionary = sc.compute(53.7, 2, 3, _stats({}))
	assert_eq(r.get("distance_points"), 53, "floor of the distance")
	assert_eq(r.get("star_points"), 20, "2 stars x 10")
	assert_eq(r.get("bounce_points"), 0, "no Style Points upgrade yet")
	assert_almost_eq(float(r.get("multiplier", 0.0)), 1.0, 0.0001)
	assert_eq(r.get("total"), 73)
	assert_eq(r.get("coins"), 73, "coins earned = total")


func test_upgraded_score() -> void:
	var sc = _scoring()
	if sc == null:
		return
	var stats = _stats({"multiplier": 1, "star_value": 1, "bounce_bonus": 2})
	var r: Dictionary = sc.compute(100.9, 4, 5, stats)
	assert_eq(r.get("distance_points"), 100)
	assert_eq(r.get("star_points"), 60, "4 stars x 15")
	assert_eq(r.get("bounce_points"), 30, "5 bounces x 6")
	assert_almost_eq(float(r.get("multiplier", 0.0)), 1.25, 0.0001)
	assert_eq(r.get("total"), 237, "floor(190 x 1.25) = floor(237.5)")
	assert_eq(r.get("coins"), 237)


func test_negative_distance_scores_zero_distance_points() -> void:
	var sc = _scoring()
	if sc == null:
		return
	var r: Dictionary = sc.compute(-3.0, 0, 0, _stats({}))
	assert_eq(r.get("distance_points"), 0)
	assert_eq(r.get("total"), 0)


func test_result_types() -> void:
	var sc = _scoring()
	if sc == null:
		return
	var r: Dictionary = sc.compute(12.3, 1, 1, _stats({"bounce_bonus": 1}))
	for key in ["distance_points", "star_points", "bounce_points", "total", "coins"]:
		assert_true(r.has(key), "missing key " + key)
		if r.has(key):
			assert_eq(typeof(r[key]), TYPE_INT, key + " must be an int")
	assert_eq(typeof(r.get("multiplier")), TYPE_FLOAT, "multiplier must be a float")
