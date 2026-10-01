extends GutTest
# Task 231: the rocket fires for as long as the boost key is held (and there is fuel): each rocket tank (upgrade
# level or Rocket perk) is 0.5 s of burn at 24 m/s per second, so a full tank still adds 12 m/s, but a short tap
# adds less. boost_charges now counts tanks and never goes down; boost_fuel burns.

const SIM := "res://scripts/core/flight_sim.gd"
const BALANCE := "res://scripts/core/balance.gd"
const DT := 1.0 / 60.0


func _flying(tanks: int):
	var sim = load(SIM).new()
	sim.boost_charges = tanks
	sim.launch(Vector2(0, 40), Vector2(10, 0))
	return sim


func test_rocket_constants() -> void:
	var c: Dictionary = load(BALANCE).get_script_constant_map()
	assert_eq(c.get("BOOST_THRUST"), 24.0)
	assert_eq(c.get("BOOST_TANK_SECONDS"), 0.5)
	assert_eq(c.get("BOOST_SPEED"), 12.0, "a full tank adds what the old boost did")


func test_fuel_fills_at_launch() -> void:
	var sim = _flying(3)
	assert_almost_eq(float(sim.boost_fuel), 1.5, 0.0001, "three tanks of 0.5 s")
	assert_almost_eq(float(sim.boost_capacity()), 1.5, 0.0001)
	assert_false(sim.boost_held)
	assert_false(sim.is_boosting(), "not until the key goes down")
	var none = _flying(0)
	assert_eq(float(none.boost_fuel), 0.0)
	assert_false(none.boost(), "no rocket, no boost")


func test_rocket_burns_while_held() -> void:
	var sim = _flying(2)
	var plain = _flying(0)
	watch_signals(sim)
	assert_true(sim.boost(), "the key goes down")
	assert_signal_emit_count(sim, "boosted", 1)
	assert_false(sim.boost(), "already firing")
	assert_signal_emit_count(sim, "boosted", 1)
	assert_true(sim.is_boosting())
	for i in 30:
		sim.step(DT)
		plain.step(DT)
	assert_almost_eq(float(sim.boost_fuel), 0.5, 0.0001, "half a second burned")
	var k := 24.0 * 0.5 / sqrt(2.0)
	assert_almost_eq(sim.velocity.x - plain.velocity.x, k, 0.3, "pushed forward")
	assert_almost_eq(sim.velocity.y - plain.velocity.y, k, 0.3, "and up")
	sim.release_boost()
	assert_false(sim.is_boosting(), "the key goes up")
	var fuel: float = sim.boost_fuel
	sim.step(DT)
	assert_eq(float(sim.boost_fuel), fuel, "released: no burn")
	assert_true(sim.boost(), "pressed again")
	for i in 60:
		sim.step(DT)
	assert_almost_eq(float(sim.boost_fuel), 0.0, 0.0001, "the tank runs dry")
	assert_false(sim.is_boosting())
	assert_false(sim.boost(), "nothing left")


func test_a_longer_hold_flies_farther() -> void:
	var last := -1.0
	for hold in [0, 6, 18, 60]:
		var sim = load(SIM).new()
		sim.boost_charges = 3
		sim.launch(Vector2(0, 2), Vector2(14, 14))
		var t := 0
		while not sim.stopped and t < 20000:
			if t == 40:
				sim.boost()
			if t == 40 + hold:
				sim.release_boost()
			sim.step(DT)
			t += 1
		assert_gt(float(sim.distance()), last + 1.0, "held for %d frames" % hold)
		last = sim.distance()


func test_no_rocket_on_the_ground_or_when_stopped() -> void:
	var sim = load(SIM).new()
	sim.boost_charges = 1
	sim.launch(Vector2(0, 0), Vector2(5, 0))
	assert_false(sim.boost(), "sliding on the ground")
	sim.stopped = true
	assert_false(sim.boost(), "stopped")
	assert_almost_eq(float(sim.boost_fuel), 0.5, 0.0001, "nothing burned")


func test_the_session_passes_the_key_on() -> void:
	var s = load("res://scripts/core/run_session.gd").new(PlayerStats.from_levels({"boosts": 2}), 1)
	assert_false(s.boost(), "not before the launch")
	s.launch_from_pull(Vector2(-80, 80))
	s.step(DT)
	assert_true(s.boost())
	assert_true(s.sim.is_boosting())
	s.release_boost()
	assert_false(s.sim.is_boosting())
	assert_false(s.sim.boost_held)
