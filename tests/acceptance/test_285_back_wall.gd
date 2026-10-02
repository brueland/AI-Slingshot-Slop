extends GutTest
# Task 285: 120 m behind the slingshot stands a giant brick wall: a shot fired backwards bounces off it (keeping its
# bounciness share of the speed) and comes back.


func test_back_wall() -> void:
	assert_eq(load("res://scripts/core/balance.gd").get_script_constant_map().get("WALL_X"), -120.0)
	var sim = load("res://scripts/core/flight_sim.gd").new()
	watch_signals(sim)
	sim.launch(Vector2(-110.0, 5.0), Vector2(-20.0, 0.0))
	for i in 60:
		sim.step(1.0 / 60.0)
	assert_signal_emitted(sim, "wall_hit")
	assert_gte(sim.position.x, -120.0, "never through the wall")
	assert_gt(sim.velocity.x, 0.0, "bounced back toward the course")
	sim.simulate(1.0 / 60.0, 20000)
	assert_gte(sim.position.x, -120.0)
	var forward = load("res://scripts/core/flight_sim.gd").new()
	forward.launch(Vector2(0, 2), Vector2(14, 14))
	forward.simulate(1.0 / 60.0, 20000)
	assert_gt(forward.distance(), 0.0, "shots to the right never meet it")
