extends GutTest
# Task 003: scripts/core/flight_sim.gd, airborne flight with gravity and quadratic drag
# (docs/DESIGN.md sections 7 and 9). Ground contact is not tested here.

const PATH := "res://scripts/core/flight_sim.gd"


func _sim():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH).new()


func test_defaults() -> void:
	var sim = _sim()
	if sim == null:
		return
	assert_almost_eq(sim.gravity, 15.0, 0.0001)
	assert_almost_eq(sim.drag, 0.002, 0.000001)
	assert_almost_eq(sim.restitution, 0.35, 0.0001)
	assert_eq(sim.boost_charges, 0)
	assert_eq(sim.bounce_count, 0)
	assert_false(sim.stopped)


func test_launch_sets_state() -> void:
	var sim = _sim()
	if sim == null:
		return
	sim.bounce_count = 4
	sim.stopped = true
	sim.launch(Vector2(3, 2), Vector2(10, 8))
	assert_eq(sim.position, Vector2(3, 2))
	assert_eq(sim.velocity, Vector2(10, 8))
	assert_almost_eq(sim.start_x, 3.0, 0.0001)
	assert_almost_eq(sim.max_height, 2.0, 0.0001)
	assert_eq(sim.bounce_count, 0)
	assert_false(sim.stopped)
	assert_almost_eq(sim.distance(), 0.0, 0.0001)


func test_gravity_only_step() -> void:
	var sim = _sim()
	if sim == null:
		return
	sim.drag = 0.0
	sim.launch(Vector2(0, 5), Vector2(10, 10))
	sim.step(0.1)
	# semi-implicit Euler: velocity first, then position
	assert_almost_eq(sim.velocity.x, 10.0, 0.0001)
	assert_almost_eq(sim.velocity.y, 8.5, 0.0001)
	assert_almost_eq(sim.position.x, 1.0, 0.0001)
	assert_almost_eq(sim.position.y, 5.85, 0.0001)


func test_drag_matches_formula_over_many_steps() -> void:
	var sim = _sim()
	if sim == null:
		return
	sim.launch(Vector2(0, 5), Vector2(10, 10))
	var p := Vector2(0, 5)
	var v := Vector2(10, 10)
	var dt := 1.0 / 60.0
	for i in 30:
		var accel := Vector2(0, -15.0) - v * v.length() * 0.002
		v += accel * dt
		p += v * dt
		sim.step(dt)
	assert_almost_eq(sim.velocity.x, v.x, 0.0001)
	assert_almost_eq(sim.velocity.y, v.y, 0.0001)
	assert_almost_eq(sim.position.x, p.x, 0.0001)
	assert_almost_eq(sim.position.y, p.y, 0.0001)
	assert_lt(sim.velocity.x, 10.0, "drag must slow the horizontal speed")


func test_max_height_and_distance() -> void:
	var sim = _sim()
	if sim == null:
		return
	sim.drag = 0.0
	sim.launch(Vector2(4, 2), Vector2(3, 15))
	for i in 100:
		sim.step(1.0 / 60.0)
	# apex of 2 + 15^2 / (2 * 15) = 9.5 m, reached after 1 s; after 100 steps the projectile is falling again
	assert_almost_eq(sim.max_height, 9.5, 0.2)
	assert_lt(sim.position.y, sim.max_height)
	assert_almost_eq(sim.distance(), sim.position.x - 4.0, 0.0001)
	assert_gt(sim.distance(), 4.0)


func test_is_airborne() -> void:
	var sim = _sim()
	if sim == null:
		return
	sim.launch(Vector2(0, 2), Vector2(5, 0))
	assert_true(sim.is_airborne(), "above the ground")
	sim.launch(Vector2(0, 0), Vector2(5, 3))
	assert_true(sim.is_airborne(), "on the ground but moving up")
	sim.launch(Vector2(0, 0), Vector2(5, 0))
	assert_false(sim.is_airborne(), "on the ground, not moving up")
