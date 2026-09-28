extends GutTest
# Task 018: scripts/core/run_tracker.gd collects stars the projectile flies through
# (docs/DESIGN.md section 9, RunTracker).

const PATH := "res://scripts/core/run_tracker.gd"
const SIM_PATH := "res://scripts/core/flight_sim.gd"


func _tracker(items: Array):
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH).new(items)


## A sim that has just moved from `from` to `to`.
func _sim_at(to: Vector2, velocity: Vector2 = Vector2(10, 0)):
	var sim = load(SIM_PATH).new()
	sim.launch(to, velocity)
	return sim


func test_star_on_the_path_is_collected_once() -> void:
	var t = _tracker([{"type": "star", "x": 5.0, "y": 3.0}, {"type": "star", "x": 50.0, "y": 3.0}])
	if t == null:
		return
	watch_signals(t)
	t.after_step(_sim_at(Vector2(6, 3.2)), Vector2(4, 3))
	assert_eq(t.stars_collected, 1)
	assert_true(t.is_used(0))
	assert_false(t.is_used(1))
	assert_signal_emitted_with_parameters(t, "star_collected", [0])
	t.after_step(_sim_at(Vector2(6.5, 3.1)), Vector2(6, 3.2))
	assert_eq(t.stars_collected, 1, "a star is collected only once")


func test_fast_projectile_collects_stars_between_steps() -> void:
	var t = _tracker([{"type": "star", "x": 10.0, "y": 3.5}])
	if t == null:
		return
	# neither end of the step is near the star, but the segment passes 0.5 m from it
	t.after_step(_sim_at(Vector2(20, 3)), Vector2(0, 3))
	assert_eq(t.stars_collected, 1)


func test_star_out_of_reach_is_not_collected() -> void:
	var t = _tracker([{"type": "star", "x": 10.0, "y": 8.0}])
	if t == null:
		return
	t.after_step(_sim_at(Vector2(20, 3)), Vector2(0, 3))
	assert_eq(t.stars_collected, 0)
	assert_false(t.is_used(0))


func test_pickup_radius_is_star_radius() -> void:
	var t = _tracker([{"type": "star", "x": 10.0, "y": 4.4}, {"type": "star", "x": 30.0, "y": 4.6}])
	if t == null:
		return
	t.after_step(_sim_at(Vector2(40, 3)), Vector2(0, 3))
	assert_true(t.is_used(0), "1.4 m away: inside the 1.5 m radius")
	assert_false(t.is_used(1), "1.6 m away: outside")


func test_defaults() -> void:
	var t = _tracker([])
	if t == null:
		return
	assert_eq(t.items, [])
	assert_eq(t.stars_collected, 0)
	assert_eq(t.springs_hit, 0)
	assert_eq(t.mud_hits, 0)
	assert_false(t.is_used(0), "out of range index is not used")
