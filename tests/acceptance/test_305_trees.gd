extends GutTest
# Task 305: trees along the meadow (every 90-220 m from 200 m, 5-9 m tall, never in a landing zone): at 18 m/s or
# faster the alien smashes through (keeping 85% of its speed); slower it bounces back off (40%), and dropping slowly
# onto a crown rolls it off the side.

const PATH := "res://scripts/core/trees.gd"


func test_trees() -> void:
	var tr = load(PATH)
	var plan: Array = tr.layout(5, 2000.0)
	assert_gt(plan.size(), 7)
	for t in plan:
		assert_gt(t.x, 200.0)
		assert_between(t.y, 5.0, 9.0)
	var trees = tr.new()
	var keep_clear: Array[Vector2] = [Vector2(290.0, 310.0)]
	var spots: Array[Vector2] = [Vector2(100.0, 7.0), Vector2(300.0, 6.0)]
	trees.add(spots, 0.0, keep_clear)
	assert_eq(trees.xs, [100.0], "none in a landing zone")
	watch_signals(trees)
	var fast := FlightSim.new()
	fast.position = Vector2(100.5, 3.0)
	fast.velocity = Vector2(30.0, 0.0)
	trees.after_step(fast, Vector2(99.5, 3.0))
	assert_true(trees.broken[0], "fast: it smashes through")
	assert_almost_eq(fast.velocity.x, 25.5, 0.001, "keeping 85% of its speed")
	assert_signal_emitted_with_parameters(trees, "tree_broken", [0])
	var standing = tr.new()
	var one: Array[Vector2] = [Vector2(100.0, 7.0)]
	standing.add(one, 0.0)
	watch_signals(standing)
	var slow := FlightSim.new()
	slow.position = Vector2(100.0, 3.0)
	slow.velocity = Vector2(10.0, 0.0)
	standing.after_step(slow, Vector2(99.0, 3.0))
	assert_false(standing.broken[0], "slow: the tree stands")
	assert_almost_eq(slow.velocity.x, -4.0, 0.001, "and the alien bounces back")
	assert_almost_eq(slow.position.x, 98.4, 0.001, "on the side it came from")
	assert_signal_emitted(standing, "tree_bounced")
	var over := FlightSim.new()
	over.position = Vector2(100.0, 12.0)
	over.velocity = Vector2(10.0, 0.0)
	standing.after_step(over, Vector2(99.0, 12.0))
	assert_eq(over.velocity, Vector2(10.0, 0.0), "flying over it")
	var drop := FlightSim.new()
	drop.position = Vector2(100.5, 6.5)
	drop.velocity = Vector2(1.0, -5.0)
	standing.after_step(drop, Vector2(100.4, 7.5))
	assert_eq(drop.velocity, Vector2(4.0, 3.0), "dropped slowly onto the crown: it rolls off")
	assert_almost_eq(drop.position.y, 7.0, 0.001)
	var s = load("res://scripts/core/run_session.gd").new(PlayerStats.new(), 5)
	assert_eq(s.trees.xs.size(), plan.size(), "every shot has its course's trees")
	assert_eq(s.result()["trees"], 0)
	s.extend_course()
	assert_gt(s.trees.xs[s.trees.xs.size() - 1], 2000.0, "and more as the course grows")
