extends GutTest
# Task 093: scripts/core/balloons.gd, party balloons above the course (their own list, not course items). Flying
# into one pops it and lifts the alien (vertical speed at least 11 m/s). RunSession pops them during a shot.

const PATH := "res://scripts/core/balloons.gd"
const SESSION := "res://scripts/core/run_session.gd"
const STATS := "res://scripts/core/player_stats.gd"


func _b():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH)


func test_layout() -> void:
	var b = _b()
	if b == null:
		return
	assert_almost_eq(b.RADIUS, 1.2, 0.0001)
	assert_almost_eq(b.LIFT_SPEED, 11.0, 0.0001)
	var pts: Array = b.layout(3, 2000.0)
	assert_eq(pts, b.layout(3, 2000.0), "same seed, same balloons")
	assert_ne(pts, b.layout(4, 2000.0), "another course, other balloons")
	assert_gt(pts.size(), 10)
	var previous := 60.0
	for p in pts:
		assert_between(p.x - previous, 60.0, 140.0)
		assert_between(p.y, 5.0, 14.0)
		previous = p.x


func test_popping() -> void:
	var b = _b()
	if b == null:
		return
	var pts: Array[Vector2] = [Vector2(100.0, 8.0), Vector2(200.0, 8.0)]
	var balloons = b.new(pts)
	watch_signals(balloons)
	var sim := FlightSim.new()
	sim.velocity = Vector2(20.0, -3.0)
	sim.position = Vector2(100.2, 8.6)
	balloons.after_step(sim, Vector2(99.8, 8.7))
	assert_signal_emitted_with_parameters(balloons, "popped", [0])
	assert_eq(balloons.popped_count, 1)
	assert_true(balloons.used[0])
	assert_almost_eq(sim.velocity.y, 11.0, 0.0001, "lifted up")
	assert_almost_eq(sim.velocity.x, 20.0, 0.0001, "same forward speed")
	sim.velocity.y = -5.0
	balloons.after_step(sim, Vector2(99.8, 8.7))
	assert_eq(balloons.popped_count, 1, "a balloon pops once")
	sim.position = Vector2(200.0, 12.0)
	balloons.after_step(sim, Vector2(199.0, 12.0))
	assert_eq(balloons.popped_count, 1, "4 m above the balloon is a miss")
	sim.velocity.y = 15.0
	sim.position = Vector2(200.5, 8.5)
	balloons.after_step(sim, Vector2(199.5, 8.0))
	assert_eq(balloons.popped_count, 2)
	assert_almost_eq(sim.velocity.y, 15.0, 0.0001, "never slows a faster climb")


func test_run_session_pops_balloons() -> void:
	if _b() == null:
		return
	var stats = load(STATS).from_levels({"power": 5, "aero": 3})
	var s = load(SESSION).new(stats, 9)
	assert_not_null(s.get("balloons"), "RunSession.balloons")
	if s.get("balloons") == null:
		return
	assert_eq(s.balloons.points, _b().layout(9, 2000.0))
	var found := false
	for a in range(10, 80):
		var session = load(SESSION).new(stats, 9)
		var lift := [0.0]
		session.balloons.popped.connect(func(_i): lift[0] = session.sim.velocity.y)
		var r := deg_to_rad(float(a))
		session.launch_from_pull(Vector2(-cos(r), sin(r)) * 120.0)
		while not session.is_finished():
			session.step(1.0 / 60.0)
		var result: Dictionary = session.result()
		assert_eq(result.get("balloons"), session.balloons.popped_count)
		if result["balloons"] > 0:
			found = true
			assert_gt(lift[0], 10.999, "the pop lifted the alien")
			break
	assert_true(found, "some strong shot pops a balloon")
