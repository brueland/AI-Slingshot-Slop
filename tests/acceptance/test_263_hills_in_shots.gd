extends GutTest
# Task 263: every shot plays on its stats' hills: the session's sim gets them (shifted per course, flat around the
# boss), course items sit on or float over them, and mud works on a hillside.


func test_hills_in_a_session() -> void:
	var stats := PlayerStats.new()
	stats.hills = 2.0
	var s := RunSession.new(stats, 7)
	assert_eq(s.sim.hills, 2.0)
	assert_ne(s.sim.hill_phase, RunSession.new(stats, 8).sim.hill_phase, "another course, other hills")
	var plain := CourseGenerator.generate(7, Balance.COURSE_LENGTH)
	for i in plain.size():
		var x := float(plain[i]["x"])
		assert_almost_eq(float(s.course[i]["y"]), float(plain[i]["y"]) + s.sim.terrain_height(x), 0.0001, "on the hills")
	var fight := PlayerStats.new()
	fight.hills = 2.0
	fight.boss = BossFight.make(10)
	var f := RunSession.new(fight, 7)
	assert_eq(f.sim.terrain_height(70.0), 0.0, "the boss stands on flat ground")
	assert_eq(RunSession.new(PlayerStats.new(), 7).sim.hills, 0.0, "flat by default")


func test_mud_on_a_hill() -> void:
	var sim := FlightSim.new()
	sim.hills = 2.0
	var x := 120.0
	while sim.terrain_height(x) < 0.5:
		x += 1.0
	var t := RunTracker.new([{"type": "mud", "x": x - 1.0, "y": sim.terrain_height(x - 1.0)}])
	sim.launch(Vector2(x, sim.ground_height(x)), Vector2(8.0, 0.0))
	t.after_step(sim, Vector2(x - 0.1, sim.ground_height(x - 0.1)))
	assert_eq(t.mud_hits, 1, "mud slows the alien sliding on a hillside")
