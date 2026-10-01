extends GutTest
# Task 020: scripts/core/run_session.gd runs one whole shot headlessly: stats -> launch -> flight with
# course items -> result (docs/DESIGN.md section 9, RunSession).

const PATH := "res://scripts/core/run_session.gd"
const STATS_PATH := "res://scripts/core/player_stats.gd"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)   # 120 px pulled down-left


func _session(levels: Dictionary = {}, seed: int = 1):
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH).new(load(STATS_PATH).from_levels(levels), seed)


func test_new_session_is_ready_to_launch() -> void:
	var s = _session({"height": 2})
	if s == null:
		return
	assert_false(s.launched)
	assert_false(s.is_finished())
	assert_gt(s.course.size(), 0, "the course is generated from the seed")
	assert_eq(s.tracker.items, s.course)
	assert_almost_eq(s.sim.position.y, 5.0, 0.0001, "the projectile waits at launch height")
	s.step(1.0 / 60.0)
	assert_almost_eq(s.sim.position.y, 5.0, 0.0001, "nothing moves before launch")


func test_launch_uses_stats() -> void:
	var s = _session({"aero": 1, "boosts": 1})
	if s == null:
		return
	var v: Vector2 = s.launch_from_pull(FULL_PULL_45)
	assert_almost_eq(v.x, 22.0 / sqrt(2.0), 0.001)
	assert_almost_eq(v.y, 22.0 / sqrt(2.0), 0.001)
	assert_true(s.launched)
	assert_eq(s.sim.position, Vector2(0, 2))
	assert_almost_eq(s.sim.drag, 0.002 * 0.82, 0.0000001, "stats are applied to the sim")
	assert_eq(s.sim.boost_charges, 1)


func test_short_pull_is_a_weak_shot() -> void:
	var s = _session()
	if s == null:
		return
	var v: Vector2 = s.launch_from_pull(Vector2(-30, 0))
	assert_almost_eq(v.length(), 22.0 * 30.0 / 120.0, 0.001)


func test_full_run_finishes_with_a_result() -> void:
	var s = _session()
	if s == null:
		return
	s.launch_from_pull(FULL_PULL_45)
	for i in 20000:
		if s.is_finished():
			break
		s.step(1.0 / 60.0)
	assert_true(s.is_finished())
	var r: Dictionary = s.result()
	for key in ["distance", "stars", "bounces", "max_height", "distance_points", "star_points", "bounce_points",
			"multiplier", "total", "coins"]:
		assert_true(r.has(key), "result is missing " + key)
	assert_between(float(r.get("distance", 0.0)), 40.0, 75.0)
	assert_eq(r.get("stars"), s.tracker.stars_collected)
	assert_eq(r.get("bounces"), s.sim.bounce_count)
	assert_eq(r.get("distance_points"), floori(float(r.get("distance", 0.0))))


func test_boost_only_after_launch() -> void:
	var s = _session({"boosts": 2})
	if s == null:
		return
	assert_false(s.boost(), "cannot boost before launch")
	s.launch_from_pull(FULL_PULL_45)
	s.step(1.0 / 60.0)
	assert_true(s.boost())
	assert_true(s.sim.is_boosting(), "the rocket fires while the key is held (task 231)")
	assert_eq(s.sim.boost_charges, 2, "charges are rocket tanks now")


func test_runs_are_force_stopped_after_max_run_seconds() -> void:
	var s = _session()
	if s == null:
		return
	s.launch_from_pull(FULL_PULL_45)
	s.sim.gravity = 0.0
	s.sim.drag = 0.0
	for i in 121 * 10:
		s.step(0.1)
	assert_true(s.is_finished(), "a projectile that never lands is stopped after 120 s")
	assert_gt(s.elapsed, 119.9)
