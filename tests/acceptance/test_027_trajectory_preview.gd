extends GutTest
# Task 027: scripts/game/trajectory_preview.gd shows dots along the predicted flight while aiming.

const PATH := "res://scripts/game/trajectory_preview.gd"
const SIM_PATH := "res://scripts/core/flight_sim.gd"


func _tp():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH)


func test_compute_points_samples_the_flight() -> void:
	var tp = _tp()
	if tp == null:
		return
	var pts: PackedVector2Array = tp.compute_points(Vector2(0, 2), Vector2(10, 10), 0.002, 6)
	assert_eq(pts.size(), 6)
	# the first point is where a FlightSim is after STEP_TIME (0.1 s), stepped in SUBSTEPS (6) pieces
	var sim = load(SIM_PATH).new()
	sim.drag = 0.002
	sim.launch(Vector2(0, 2), Vector2(10, 10))
	for i in 6:
		sim.step(0.1 / 6.0)
	if pts.size() > 0:
		assert_almost_eq(pts[0].x, sim.position.x, 0.0001)
		assert_almost_eq(pts[0].y, sim.position.y, 0.0001)
	for i in range(1, pts.size()):
		assert_gt(pts[i].x, pts[i - 1].x, "points move forward")


func test_compute_points_stops_at_the_ground() -> void:
	var tp = _tp()
	if tp == null:
		return
	var pts: PackedVector2Array = tp.compute_points(Vector2(0, 2), Vector2(10, 10), 0.002, 100)
	assert_lt(pts.size(), 100, "a 1.5 s flight has fewer than 100 points 0.1 s apart")
	assert_gt(pts.size(), 5)
	for p in pts:
		assert_gt(p.y, 0.0, "only points above the ground")


func test_node_keeps_screen_points() -> void:
	var tp = _tp()
	if tp == null:
		return
	var node = tp.new()
	add_child_autofree(node)
	assert_true(node is Node2D)
	assert_eq(node.points.size(), 0)
	node.update_preview(Vector2(0, 2), Vector2(10, 10), 0.002, 6)
	assert_eq(node.points.size(), 6)
	var world: PackedVector2Array = tp.compute_points(Vector2(0, 2), Vector2(10, 10), 0.002, 6)
	if node.points.size() > 0 and world.size() > 0:
		assert_almost_eq(node.points[0].x, world[0].x * 16.0, 0.001, "points are stored in screen pixels")
		assert_almost_eq(node.points[0].y, -world[0].y * 16.0, 0.001)
	node.clear()
	assert_eq(node.points.size(), 0)
