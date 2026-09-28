extends GutTest
# Task 005: FlightSim sliding and stopping, plus simulate() (docs/DESIGN.md section 7, step 3).

const PATH := "res://scripts/core/flight_sim.gd"


func _sim():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH).new()


func test_slide_decelerates() -> void:
	var sim = _sim()
	if sim == null:
		return
	sim.launch(Vector2(0, 0), Vector2(6, 0))
	sim.step(0.1)
	assert_almost_eq(sim.velocity.x, 5.4, 0.0001, "6 - SLIDE_FRICTION * 0.1")
	assert_almost_eq(sim.position.x, 0.54, 0.0001, "moves with the new speed")
	assert_almost_eq(sim.position.y, 0.0, 0.00001)
	assert_almost_eq(sim.velocity.y, 0.0, 0.00001)


func test_slide_comes_to_a_stop() -> void:
	var sim = _sim()
	if sim == null:
		return
	sim.launch(Vector2(0, 0), Vector2(3, 0))
	var steps = sim.simulate(1.0 / 60.0, 10000)
	assert_true(sim.stopped)
	assert_eq(sim.velocity, Vector2.ZERO)
	assert_between(int(steps), 28, 32, "3 m/s at 6 m/s^2 takes about 0.5 s")
	assert_almost_eq(sim.distance(), 0.75, 0.05)


func test_step_does_nothing_once_stopped() -> void:
	var sim = _sim()
	if sim == null:
		return
	sim.launch(Vector2(0, 0), Vector2(1, 0))
	sim.simulate(1.0 / 60.0, 10000)
	var p: Vector2 = sim.position
	sim.step(1.0 / 60.0)
	assert_eq(sim.position, p)
	assert_true(sim.stopped)


func test_simulate_respects_max_steps() -> void:
	var sim = _sim()
	if sim == null:
		return
	sim.launch(Vector2(0, 50), Vector2(10, 0))
	assert_eq(sim.simulate(1.0 / 60.0, 5), 5)
	assert_false(sim.stopped)


func test_full_flight_lands_and_stops() -> void:
	var sim = _sim()
	if sim == null:
		return
	sim.launch(Vector2(0, 2), Vector2(15, 15))
	sim.simulate(1.0 / 60.0, 20000)
	assert_true(sim.stopped, "a normal shot stops within 20000 steps")
	assert_gt(sim.bounce_count, 0, "a 21 m/s shot bounces at least once")
	assert_gt(sim.distance(), 15.0)
	assert_almost_eq(sim.position.y, 0.0, 0.00001)
