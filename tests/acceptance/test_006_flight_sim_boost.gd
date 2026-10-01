extends GutTest
# Task 006: FlightSim.boost(): spend a boost charge in the air (docs/DESIGN.md section 9, FlightSim).
# Updated by task 231: boost() fires the rocket, which burns BOOST_THRUST m/s per second while the key is held.

const PATH := "res://scripts/core/flight_sim.gd"


func _sim():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH).new()


func test_boost_without_charges_does_nothing() -> void:
	var sim = _sim()
	if sim == null:
		return
	sim.launch(Vector2(0, 5), Vector2(10, 2))
	assert_false(sim.boost())
	assert_eq(sim.velocity, Vector2(10, 2))


func test_boost_in_the_air() -> void:
	var sim = _sim()
	if sim == null:
		return
	watch_signals(sim)
	sim.boost_charges = 2
	sim.launch(Vector2(0, 5), Vector2(10, -2))
	assert_true(sim.boost())
	assert_signal_emitted(sim, "boosted")
	assert_eq(sim.velocity, Vector2(10, -2), "the push comes with the next steps")
	var plain = _sim()
	plain.launch(Vector2(0, 5), Vector2(10, -2))
	sim.step(0.1)
	plain.step(0.1)
	var k := 24.0 * 0.1 / sqrt(2.0)
	assert_almost_eq(sim.velocity.x - plain.velocity.x, k, 0.05)
	assert_almost_eq(sim.velocity.y - plain.velocity.y, k, 0.05)
	assert_eq(sim.boost_charges, 2, "charges are rocket tanks: the fuel burns instead")
	assert_almost_eq(float(sim.boost_fuel), 0.9, 0.0001)


func test_no_boost_on_the_ground_or_when_stopped() -> void:
	var sim = _sim()
	if sim == null:
		return
	sim.boost_charges = 3
	sim.launch(Vector2(0, 0), Vector2(4, 0))
	assert_false(sim.boost(), "sliding on the ground")
	sim.simulate(1.0 / 60.0, 10000)
	assert_false(sim.boost(), "stopped")
	assert_eq(sim.boost_charges, 3)


func test_boost_flies_farther() -> void:
	var plain = _sim()
	var boosted = _sim()
	if plain == null or boosted == null:
		return
	boosted.boost_charges = 1
	plain.launch(Vector2(0, 2), Vector2(12, 12))
	boosted.launch(Vector2(0, 2), Vector2(12, 12))
	for i in 20000:
		if boosted.stopped:
			break
		if boosted.velocity.y < 0.0 and boosted.boost_charges > 0:
			boosted.boost()
		boosted.step(1.0 / 60.0)
	plain.simulate(1.0 / 60.0, 20000)
	assert_true(boosted.stopped and plain.stopped)
	assert_gt(boosted.distance(), plain.distance() + 5.0)
