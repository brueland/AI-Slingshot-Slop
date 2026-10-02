extends GutTest
# Task 004: FlightSim ground contact: bounce with restitution, or settle to sliding
# (docs/DESIGN.md section 7, step 2).

const PATH := "res://scripts/core/flight_sim.gd"


func _sim():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH).new()


func test_hard_landing_bounces() -> void:
	var sim = _sim()
	if sim == null:
		return
	sim.drag = 0.0
	watch_signals(sim)
	sim.launch(Vector2(0, 0.05), Vector2(5, -10))
	sim.step(0.01)
	# vy = -10 - 15 * 0.01 = -10.15, rebound = 10.15 * 0.45 = 4.5675 >= 2 (bouncier since task 257)
	assert_almost_eq(sim.position.y, 0.0, 0.00001, "clamped to the ground")
	assert_almost_eq(sim.velocity.y, 4.5675, 0.0001, "bounces up with restitution")
	assert_almost_eq(sim.velocity.x, 4.5, 0.0001, "keeps 90% of horizontal speed")
	assert_eq(sim.bounce_count, 1)
	assert_false(sim.stopped)
	assert_signal_emitted(sim, "bounced")
	var params = get_signal_parameters(sim, "bounced")
	if params != null:
		assert_almost_eq(float(params[0]), 4.5675, 0.0001, "bounced(impact_speed) carries the rebound speed")


func test_soft_landing_settles_without_bounce() -> void:
	var sim = _sim()
	if sim == null:
		return
	sim.drag = 0.0
	sim.launch(Vector2(0, 0.01), Vector2(5, -3))
	sim.step(0.01)
	# rebound = 3.15 * 0.45 = 1.4175 < 2: no bounce, vertical speed becomes 0
	assert_almost_eq(sim.position.y, 0.0, 0.00001)
	assert_almost_eq(sim.velocity.y, 0.0, 0.00001)
	assert_almost_eq(sim.velocity.x, 5.0, 0.0001, "no bounce friction when it does not bounce")
	assert_eq(sim.bounce_count, 0)
	assert_false(sim.stopped, "landing softly is not stopping; it slides next")
	assert_false(sim.is_airborne())


func test_restitution_controls_rebound() -> void:
	var low = _sim()
	var high = _sim()
	if low == null or high == null:
		return
	for s in [low, high]:
		s.drag = 0.0
		s.launch(Vector2(0, 0.05), Vector2(5, -10))
	high.restitution = 0.75
	low.step(0.01)
	high.step(0.01)
	assert_almost_eq(high.velocity.y, 10.15 * 0.75, 0.0001)
	assert_gt(high.velocity.y, low.velocity.y)


func test_dropped_ball_bounces_several_times() -> void:
	var sim = _sim()
	if sim == null:
		return
	sim.drag = 0.0
	sim.restitution = 0.75
	sim.launch(Vector2(0, 10), Vector2(1, 0))
	var highest_after_first_bounce := 0.0
	var went_below := false
	for i in 600:
		sim.step(1.0 / 60.0)
		if sim.bounce_count >= 1:
			highest_after_first_bounce = maxf(highest_after_first_bounce, sim.position.y)
		if sim.position.y < 0.0:
			went_below = true
	assert_false(went_below, "never below the ground")
	assert_gt(sim.bounce_count, 2, "bounces more than twice")
	assert_lt(highest_after_first_bounce, 10.0, "each bounce is lower than the drop")
	assert_almost_eq(sim.max_height, 10.0, 0.0001)
