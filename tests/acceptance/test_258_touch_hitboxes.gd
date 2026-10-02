extends GutTest
# Task 258: springs and balloons react when the alien's drawn body touches them: a spring fires when the alien's side
# reaches it or the alien comes low over it, and a balloon pops when it touches the alien's body, not just its feet.

const SPRING := [{"type": "spring", "x": 30.0, "y": 0.0}]


func _spring_hits(at: Vector2) -> int:
	var t = load("res://scripts/core/run_tracker.gd").new(SPRING.duplicate(true), 1.125, 2.0)
	var sim := FlightSim.new()
	sim.launch(at, Vector2(-3.0, 0.0))
	t.after_step(sim, at + Vector2(0.1, 0.0))
	return t.springs_hit


func test_springs() -> void:
	assert_eq(load("res://scripts/core/run_tracker.gd").get_script_constant_map().get("SPRING_TOP"), 0.6)
	assert_eq(_spring_hits(Vector2(32.2, 0.0)), 1, "the alien's side touches it (2.2 m away)")
	assert_eq(_spring_hits(Vector2(30.2, 0.5)), 1, "coming in low over it")
	assert_eq(_spring_hits(Vector2(30.0, 1.5)), 0, "too high")
	assert_eq(_spring_hits(Vector2(33.0, 0.0)), 0, "too far")


func test_balloons() -> void:
	var pts: Array[Vector2] = [Vector2(100.0, 10.0)]
	var b = load("res://scripts/core/balloons.gd").new(pts)
	var sim := FlightSim.new()
	sim.position = Vector2(100.1, 6.7)
	b.after_step(sim, Vector2(99.9, 6.7))
	assert_eq(b.popped_count, 0, "a point 3.3 m below misses")
	b.body = 1.125
	b.after_step(sim, Vector2(99.9, 6.7))
	assert_eq(b.popped_count, 1, "but the alien's head touches it")
	var s := RunSession.new(PlayerStats.new(), 3)
	assert_almost_eq(s.balloons.body, PlayerStats.new().pickup_offset, 0.0001, "the session gives its balloons the alien's body")
