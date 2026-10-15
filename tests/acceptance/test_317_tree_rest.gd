extends GutTest
# Task 317: an alien too slow to break a tree that rolls up against it no longer bonks every frame forever (which
# locked the shot): it bounces only while moving toward the trunk, and at a crawl (under 2 m/s) it comes to rest
# against the tree and the shot ends.


func _trees():
	var t = load("res://scripts/core/trees.gd").new()
	var one: Array[Vector2] = [Vector2(100.0, 7.0)]
	t.add(one, 0.0)
	return t


func test_slow_roll_into_a_tree_ends() -> void:
	var trees = _trees()
	watch_signals(trees)
	var sim := FlightSim.new()
	sim.launch(Vector2(95.0, 0.5), Vector2(6.0, 0.0))
	var steps := 0
	while not sim.stopped and steps < 3600:
		var before := sim.position
		sim.step(1.0 / 60.0)
		trees.after_step(sim, before)
		steps += 1
	assert_true(sim.stopped, "the shot ends")
	assert_lt(steps, 600, "within 10 s")
	assert_lte(get_signal_emit_count(trees, "tree_bounced"), 3, "a bonk or two, not one every frame")
	assert_lte(sim.position.x, 100.0 - 1.6 + 0.001, "on its side of the tree")
	assert_false(trees.broken[0], "too slow to break it")


func test_moving_away_is_no_hit() -> void:
	var trees = _trees()
	watch_signals(trees)
	var sim := FlightSim.new()
	sim.position = Vector2(98.4, 0.0)
	sim.velocity = Vector2(-3.0, 0.0)
	trees.after_step(sim, Vector2(98.45, 0.0))
	assert_eq(sim.velocity.x, -3.0, "already leaving the tree: no bounce")
	assert_signal_not_emitted(trees, "tree_bounced")


func test_a_real_bounce_still_bounces() -> void:
	var trees = _trees()
	watch_signals(trees)
	var sim := FlightSim.new()
	sim.position = Vector2(100.0, 3.0)
	sim.velocity = Vector2(10.0, 0.0)
	trees.after_step(sim, Vector2(99.0, 3.0))
	assert_almost_eq(sim.velocity.x, -4.0, 0.001, "a 10 m/s hit bounces back as before")
	assert_signal_emitted(trees, "tree_bounced")
