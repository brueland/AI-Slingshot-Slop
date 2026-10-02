extends GutTest
# Task 257: the alien is bouncier: a bounce keeps 45% of the landing speed (was 35%) and 90% of the forward speed (was
# 85%), so a shot bounces more often and rolls on farther.


func test_bouncier() -> void:
	var c: Dictionary = load("res://scripts/core/balance.gd").get_script_constant_map()
	assert_eq(c.get("BASE_RESTITUTION"), 0.45)
	assert_eq(c.get("BOUNCE_FRICTION"), 0.9)
	var before := FlightSim.new()
	before.restitution = 0.35
	var now := FlightSim.new()
	for sim in [before, now]:
		sim.launch(Vector2(0, 2), Vector2(14, 14))
		sim.simulate(1.0 / 60.0, 20000)
	assert_gt(now.bounce_count, before.bounce_count, "more bounces")
	assert_gt(now.distance(), before.distance() + 3.0, "and farther")
