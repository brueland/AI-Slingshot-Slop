extends GutTest
# Task 269: a shot's result includes its flight path, and the roguelike run remembers the last shot's path.


func test_last_path() -> void:
	var s := RunSession.new(PlayerStats.new(), 3)
	s.launch_from_pull(Vector2(-80, 80))
	while not s.is_finished():
		s.step(1.0 / 60.0)
	var r: Dictionary = s.result()
	assert_eq(r.get("path"), s.path, "the result has the path")
	var run = load("res://scripts/core/rogue_run.gd").new()
	run.start(4)
	assert_eq(run.last_path.size(), 0)
	run.finish_shot(r)
	assert_eq(run.last_path, s.path, "the run remembers it")
	run.finish_shot({"distance": 3.0})
	assert_eq(run.last_path.size(), 0, "a result without a path forgets it")
	run.finish_shot(r)
	run.start(5)
	assert_eq(run.last_path.size(), 0, "a new run starts without one")
