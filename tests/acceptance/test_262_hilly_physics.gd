extends GutTest
# Task 262: FlightSim has rolling hills: the ground's height is two gentle waves `hills` high (flat near the
# slingshot, on flat spans and around landing-zone dips), slides follow them, and bounces come off the slope.

const SIM := "res://scripts/core/flight_sim.gd"


func _hilly(h: float):
	var sim = load(SIM).new()
	sim.hills = h
	sim.hill_phase = 1.3
	return sim


func test_hills() -> void:
	var flat = _hilly(0.0)
	assert_eq(flat.terrain_height(100.0), 0.0, "no hills, flat")
	var sim = _hilly(2.0)
	assert_eq(sim.terrain_height(10.0), 0.0, "flat near the slingshot")
	var highest := 0.0
	var steepest := 0.0
	for i in 2000:
		var x := 50.0 + i * 0.5
		highest = maxf(highest, absf(sim.terrain_height(x)))
		steepest = maxf(steepest, absf(sim.terrain_slope(x)))
	assert_lte(highest, 2.0001, "never more than `hills` high")
	assert_gt(highest, 1.0, "but really hilly")
	assert_lt(steepest, 0.2, "and gentle")
	assert_almost_eq(sim.ground_height(321.0), sim.terrain_height(321.0), 0.0001)
	var spans: Array[Vector2] = [Vector2(300.0, 340.0)]
	sim.flat_spans = spans
	assert_eq(sim.terrain_height(320.0), 0.0, "flat on a flat span")
	assert_almost_eq(sim.terrain_height(290.0), _hilly(2.0).terrain_height(290.0) * 10.0 / 15.0, 0.0001,
		"growing back in over 15 m next to it")


func test_slope_bounce() -> void:
	var sim = _hilly(2.0)
	var x := 200.0
	while sim.terrain_slope(x) < 0.08:
		x += 0.5
	var g: float = sim.ground_height(x)
	sim.launch(Vector2(x, g + 0.02), Vector2(0.0, -10.0))
	sim.step(0.01)
	assert_lt(sim.velocity.x, -0.5, "an uphill slope sends a straight drop back down the hill")
	assert_gt(sim.velocity.y, 2.0, "and up")
	var level = load(SIM).new()
	level.launch(Vector2(0, 0.05), Vector2(5, -10))
	level.drag = 0.0
	level.step(0.01)
	assert_almost_eq(level.velocity.x, 5.0 * Balance.BOUNCE_FRICTION, 0.0001, "flat ground bounces as before")


func test_rolling_over_hills() -> void:
	var sim = _hilly(2.0)
	sim.launch(Vector2(0, 2), Vector2(14, 12))
	sim.simulate(1.0 / 60.0, 40000)
	assert_true(sim.stopped)
	assert_almost_eq(sim.position.y, sim.ground_height(sim.position.x), 0.001, "it rests on the hills")
