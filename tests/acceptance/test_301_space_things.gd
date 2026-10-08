extends GutTest
# Task 301: meteors (120-260 m up) and space stations (220-320 m up) along the course: smashing a meteor boosts the
# alien 12 m/s along its flight, a station bounces it off (90% of its speed). Every shot has its course's ones.

const PATH := "res://scripts/core/space_things.gd"


func test_space_things() -> void:
	var st = load(PATH)
	var plan: Dictionary = st.layout(5, 2000.0)
	assert_gt(plan["meteors"].size(), 10, "a meteor every 60-140 m")
	assert_gt(plan["stations"].size(), 1, "a station every 300-700 m")
	for m in plan["meteors"]:
		assert_between(m.y, 120.0, 260.0)
		assert_gt(m.x, 150.0)
	for s in plan["stations"]:
		assert_between(s.y, 220.0, 320.0)
	var things = st.new()
	things.add({"meteors": [Vector2(100.0, 150.0)], "stations": [Vector2(300.0, 250.0)]}, 0.0)
	watch_signals(things)
	var m: Vector2 = things.meteor_position(0)
	assert_almost_eq(m.distance_to(Vector2(100.0, 150.0)), 3.0, 0.001, "a meteor circles its spot")
	var sim := FlightSim.new()
	sim.position = m + Vector2(0.3, 0.0)
	sim.velocity = Vector2(30.0, 0.0)
	things.after_step(sim, m - Vector2(0.3, 0.0), 0.0)
	assert_almost_eq(sim.velocity.x, 42.0, 0.001, "smashing it boosts the alien along its flight")
	assert_true(things.meteor_used[0])
	assert_signal_emitted_with_parameters(things, "meteor_hit", [0])
	sim.position = Vector2(296.0, 250.0)
	sim.velocity = Vector2(30.0, 0.0)
	things.after_step(sim, Vector2(295.0, 250.0), 0.0)
	assert_almost_eq(sim.velocity.x, -27.0, 0.001, "a station bounces it back")
	assert_almost_eq(sim.position.x, 295.5, 0.001, "and pushes it out")
	assert_signal_emitted(things, "station_hit")
	var s = load("res://scripts/core/run_session.gd").new(PlayerStats.new(), 5)
	assert_eq(s.space.meteors, plan["meteors"], "every shot has its course's meteors")
	assert_eq(s.space.stations, plan["stations"])
	s.launch_from_pull(Vector2(-84.852814, 84.852814))
	s.step(0.5)
	assert_almost_eq(s.space.time, 0.5, 0.0001, "they move with the shot")
	assert_eq(s.result()["meteors"], 0)
	s.extend_course()
	assert_gt(s.space.meteors[s.space.meteors.size() - 1].x, 2000.0, "and more come as the course grows")
