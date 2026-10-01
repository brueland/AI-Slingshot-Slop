extends GutTest
# Task 235: the ground can have dips: a flat floor 0.75 m down between a dip's ends, with 1.5 m slopes outside them
# that are too steep to rest on. A shot that would stop on a slope rolls onto the floor, and a slow one that runs
# past the far end rolls back, so landing zones (task 236 puts one under each) catch near misses. Without dips
# nothing changes.

const SIM := "res://scripts/core/flight_sim.gd"
const BALANCE := "res://scripts/core/balance.gd"


func _sim(with_dip: bool):
	var sim = load(SIM).new()
	if with_dip:
		var d: Array[Vector2] = [Vector2(40, 60)]
		sim.dips = d
	return sim


func _slide_from(with_dip: bool, x: float, speed: float):
	var sim = _sim(with_dip)
	sim.launch(Vector2(x, sim.ground_height(x)), Vector2(speed, 0.0))
	sim.simulate(1.0 / 60.0, 20000)
	return sim


func test_dip_shape() -> void:
	var c: Dictionary = load(BALANCE).get_script_constant_map()
	assert_eq(c.get("DIP_DEPTH"), 0.75)
	assert_eq(c.get("DIP_SLOPE"), 1.5)
	var sim = _sim(true)
	for x in [0.0, 38.5, 61.5, 100.0]:
		assert_eq(float(sim.ground_height(x)), 0.0, "flat at %.1f" % x)
	for x in [40.0, 50.0, 60.0]:
		assert_almost_eq(float(sim.ground_height(x)), -0.75, 0.0001, "the floor at %.1f" % x)
	assert_almost_eq(float(sim.ground_height(39.25)), -0.375, 0.0001, "halfway down the slope")
	assert_almost_eq(float(sim.ground_slope(39.0)), -0.5, 0.0001)
	assert_almost_eq(float(sim.ground_slope(61.0)), 0.5, 0.0001)
	assert_eq(float(sim.ground_slope(50.0)), 0.0)
	assert_eq(float(_sim(false).ground_height(50.0)), 0.0, "no dips, flat ground")


func test_a_short_slide_rolls_into_the_zone() -> void:
	var speed := sqrt(2.0 * 6.0 * 9.2)
	var flat = _slide_from(false, 30.0, speed)
	assert_almost_eq(float(flat.position.x), 39.2, 0.3, "on flat ground it stops short of 40 m")
	var dip = _slide_from(true, 30.0, speed)
	assert_true(dip.stopped)
	assert_between(float(dip.position.x), 40.0, 60.0, "with the dip it rolls in")
	assert_almost_eq(float(dip.position.y), -0.75, 0.0001, "and rests on the floor")


func test_a_slow_overshoot_rolls_back() -> void:
	var speed := 12.0
	var flat = _slide_from(false, 50.0, speed)
	assert_gt(float(flat.position.x), 61.0, "on flat ground it stops past 60 m")
	var dip = _slide_from(true, 50.0, speed)
	assert_between(float(dip.position.x), 40.0, 60.0, "the far slope sends it back")


func test_a_fast_shot_still_runs_out() -> void:
	var dip = _slide_from(true, 50.0, 16.0)
	assert_gt(float(dip.position.x), 61.5, "a fast slide climbs out and stops beyond the dip")
	assert_eq(float(dip.position.y), 0.0)


func test_landing_in_the_dip() -> void:
	var sim = _sim(true)
	sim.launch(Vector2(50, 5), Vector2(0, -1))
	sim.simulate(1.0 / 60.0, 20000)
	assert_true(sim.stopped)
	assert_almost_eq(float(sim.position.y), -0.75, 0.0001, "it lands on the floor, not in mid-air at 0 m")


func test_no_dips_no_change() -> void:
	var a = _sim(false)
	var b = _sim(false)
	var far: Array[Vector2] = [Vector2(1500, 1520)]
	b.dips = far
	for sim in [a, b]:
		sim.launch(Vector2(0, 2), Vector2(14, 12))
		sim.simulate(1.0 / 60.0, 20000)
	assert_eq(b.position, a.position, "a dip far away changes nothing")
	assert_eq(b.bounce_count, a.bounce_count)
