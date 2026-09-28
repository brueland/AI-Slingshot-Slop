extends GutTest
# Task 019: RunTracker applies springs and mud when the projectile touches the ground
# (docs/DESIGN.md section 9, RunTracker).

const PATH := "res://scripts/core/run_tracker.gd"
const SIM_PATH := "res://scripts/core/flight_sim.gd"


func _tracker(items: Array):
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH).new(items)


func _sim(position: Vector2, velocity: Vector2):
	var sim = load(SIM_PATH).new()
	sim.launch(position, velocity)
	return sim


func test_spring_launches_a_sliding_projectile() -> void:
	var t = _tracker([{"type": "spring", "x": 30.0, "y": 0.0}])
	if t == null:
		return
	watch_signals(t)
	var sim = _sim(Vector2(30.5, 0), Vector2(8, 0))
	t.after_step(sim, Vector2(30.4, 0))
	assert_almost_eq(sim.velocity.y, 14.0, 0.0001, "SPRING_SPEED")
	assert_almost_eq(sim.velocity.x, 12.0, 0.0001, "8 + SPRING_PUSH")
	assert_eq(t.springs_hit, 1)
	assert_true(t.is_used(0))
	assert_signal_emitted_with_parameters(t, "spring_hit", [0])
	sim.velocity = Vector2(8, 0)
	t.after_step(sim, Vector2(30.4, 0))
	assert_eq(sim.velocity, Vector2(8, 0), "a spring works once")


func test_spring_keeps_a_faster_upward_speed() -> void:
	var t = _tracker([{"type": "spring", "x": 30.0, "y": 0.0}])
	if t == null:
		return
	var sim = _sim(Vector2(29.0, 0), Vector2(8, 20))
	t.after_step(sim, Vector2(28.8, 0))
	assert_almost_eq(sim.velocity.y, 20.0, 0.0001, "maxf(20, 14)")


func test_spring_needs_ground_contact_and_range() -> void:
	var t = _tracker([{"type": "spring", "x": 30.0, "y": 0.0}])
	if t == null:
		return
	var flying = _sim(Vector2(30.0, 2.0), Vector2(8, 0))
	t.after_step(flying, Vector2(29.9, 2.0))
	assert_eq(t.springs_hit, 0, "flying over a spring does nothing")
	var far = _sim(Vector2(32.0, 0.0), Vector2(8, 0))
	t.after_step(far, Vector2(31.9, 0.0))
	assert_eq(t.springs_hit, 0, "2 m away is outside SPRING_HALF_WIDTH")


func test_spring_restarts_a_stopped_projectile() -> void:
	var t = _tracker([{"type": "spring", "x": 30.0, "y": 0.0}])
	if t == null:
		return
	var sim = _sim(Vector2(30.0, 0), Vector2.ZERO)
	sim.stopped = true
	t.after_step(sim, Vector2(30.0, 0))
	assert_false(sim.stopped)
	assert_almost_eq(sim.velocity.y, 14.0, 0.0001)


func test_mud_halves_speed_once() -> void:
	var t = _tracker([{"type": "mud", "x": 50.0, "y": 0.0}])
	if t == null:
		return
	watch_signals(t)
	var sim = _sim(Vector2(53.0, 0), Vector2(10, 0))
	t.after_step(sim, Vector2(52.8, 0))
	assert_almost_eq(sim.velocity.x, 5.0, 0.0001)
	assert_eq(t.mud_hits, 1)
	assert_signal_emitted_with_parameters(t, "mud_hit", [0])
	t.after_step(sim, Vector2(52.9, 0))
	assert_almost_eq(sim.velocity.x, 5.0, 0.0001, "mud works once")


func test_mud_only_on_the_ground_inside_the_patch() -> void:
	var t = _tracker([{"type": "mud", "x": 50.0, "y": 0.0}])
	if t == null:
		return
	var above = _sim(Vector2(52.0, 1.0), Vector2(10, 0))
	t.after_step(above, Vector2(51.8, 1.0))
	var past = _sim(Vector2(56.5, 0.0), Vector2(10, 0))
	t.after_step(past, Vector2(56.3, 0.0))
	assert_eq(t.mud_hits, 0, "above the mud, or past its 6 m width")


func test_sliding_onto_a_spring_sends_it_flying() -> void:
	var t = _tracker([{"type": "spring", "x": 30.0, "y": 0.0}])
	if t == null:
		return
	# sliding from 8 m/s at 6 m/s^2 would stop at 30.3 m; the spring at 30 m catches it first
	var sim = _sim(Vector2(25, 0), Vector2(8, 0))
	for i in 2000:
		if sim.stopped:
			break
		var before: Vector2 = sim.position
		sim.step(1.0 / 60.0)
		t.after_step(sim, before)
	assert_eq(t.springs_hit, 1)
	assert_gt(sim.max_height, 3.0)
	assert_gt(sim.distance(), 10.0)
