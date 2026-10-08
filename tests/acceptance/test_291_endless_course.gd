extends GutTest
# Task 291: the course never ends: when the alien gets within 300 m of its end, RunSession adds the next 2000 m of
# stars, springs and mud (from the next seed, on the hills), and they work like the first ones.

const SESSION := "res://scripts/core/run_session.gd"


func test_endless_course() -> void:
	var s = load(SESSION).new(PlayerStats.new(), 5)
	assert_eq(s.get("course_end"), Balance.COURSE_LENGTH, "the first 2000 m")
	var items_before: int = s.course.size()
	var balloons_before: int = s.balloons.points.size()
	watch_signals(s)
	s.extend_course()
	assert_signal_emitted_with_parameters(s, "extended", [items_before, balloons_before])
	assert_eq(s.course_end, 2.0 * Balance.COURSE_LENGTH)
	assert_gt(s.course.size(), items_before + 50, "another course's worth of items")
	for i in range(1, s.course.size()):
		assert_gte(float(s.course[i]["x"]), float(s.course[i - 1]["x"]), "still sorted along the course")
	for i in range(items_before, s.course.size()):
		assert_between(float(s.course[i]["x"]), 2000.0, 4000.0)
	assert_eq(s.tracker.items.size(), s.course.size(), "the tracker sees them")
	assert_false(s.tracker.is_used(s.course.size() - 1))
	var again = load(SESSION).new(PlayerStats.new(), 5)
	again.extend_course()
	assert_eq(again.course, s.course, "the same seed grows the same way")
	# a star of the new piece is collected like any other
	var k := items_before
	while s.course[k]["type"] != "star":
		k += 1
	var star: Dictionary = s.course[k]
	var sim := FlightSim.new()
	sim.position = Vector2(float(star["x"]) + 0.3, float(star["y"]))
	s.tracker.after_step(sim, sim.position - Vector2(0.6, 0.0))
	assert_true(s.tracker.is_used(k), "a new star is collected")
	# flying near the end grows the course by itself
	var fly = load(SESSION).new(PlayerStats.new(), 9)
	fly.launch_from_pull(Vector2(-84.852814, 84.852814))
	fly.sim.position = Vector2(1750.0, 20.0)
	fly.sim.velocity = Vector2(30.0, 0.0)
	fly.step(1.0 / 60.0)
	assert_eq(fly.course_end, 4000.0, "300 m before the end, the next piece is there")
	var short = load(SESSION).new(PlayerStats.new(), 9)
	short.launch_from_pull(Vector2(-84.852814, 84.852814))
	while not short.is_finished():
		short.step(1.0 / 60.0)
	assert_eq(short.course_end, Balance.COURSE_LENGTH, "a short shot keeps its course")
