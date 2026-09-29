extends GutTest
# Task 102: scripts/core/rogue_sizes.gd, alien sizes for the roguelike (Small, Normal, Big). Big is a little slower
# with more drag but reaches stars easily; Small flies faster and farther but must fly closer to a star. In the
# roguelike stars are picked up by the alien's body. RogueRun keeps the chosen size until it is changed.

const PATH := "res://scripts/core/rogue_sizes.gd"
const RUN := "res://scripts/core/rogue_run.gd"
const STATS := "res://scripts/core/player_stats.gd"


func _z():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH)


func test_list() -> void:
	var z = _z()
	if z == null:
		return
	assert_almost_eq(z.STAR_REACH, 0.9, 0.0001)
	var ids := []
	for entry in z.LIST:
		ids.append(entry["id"])
	assert_eq(ids, ["small", "normal", "big"])
	assert_eq(z.get_def("big")["name"], "Big")
	assert_eq(z.get_def("huge"), {})


func test_apply() -> void:
	var z = _z()
	if z == null:
		return
	var normal = z.apply(load(STATS).from_levels({}), "normal")
	assert_almost_eq(normal.max_speed, 22.0, 0.0001)
	assert_almost_eq(normal.drag, 0.002, 0.000001)
	assert_almost_eq(normal.size_scale, 1.0, 0.0001)
	assert_almost_eq(normal.pickup_offset, 0.75, 0.0001, "measured from the alien's center")
	assert_almost_eq(normal.pickup_radius, 1.65, 0.0001, "its radius + 0.9 m")
	var big = z.apply(load(STATS).from_levels({}), "big")
	assert_almost_eq(big.size_scale, 2.5, 0.0001)
	assert_almost_eq(big.max_speed, 22.0 * 0.95, 0.0001)
	assert_almost_eq(big.drag, 0.002 * 1.3, 0.000001)
	assert_almost_eq(big.pickup_offset, 1.875, 0.0001)
	assert_almost_eq(big.pickup_radius, 2.775, 0.0001)
	var small = z.apply(load(STATS).from_levels({}), "small")
	assert_almost_eq(small.size_scale, 0.6, 0.0001)
	assert_almost_eq(small.max_speed, 22.0 * 1.15, 0.0001)
	assert_almost_eq(small.drag, 0.002 * 0.65, 0.000001)
	assert_almost_eq(small.pickup_radius, 0.45 + 0.9, 0.0001)
	var odd = z.apply(load(STATS).from_levels({}), "huge")
	assert_almost_eq(odd.size_scale, 1.0, 0.0001, "unknown sizes count as normal")


func test_run_keeps_a_size() -> void:
	if _z() == null:
		return
	var r = load(RUN).new()
	r.start(7)
	assert_eq(r.get("size_id"), "normal")
	assert_almost_eq(r.stats().max_speed, 22.0, 0.0001)
	assert_almost_eq(r.stats().pickup_offset, 0.75, 0.0001, "the roguelike measures pickups from the body")
	assert_true(r.set_size("big"))
	assert_eq(r.size_id, "big")
	assert_almost_eq(r.stats().size_scale, 2.5, 0.0001)
	r.finish_shot({"distance": 45.0})
	r.choose_perk(r.offer[0])
	assert_eq(r.size_id, "big", "the size stays until changed")
	assert_false(r.set_size("huge"))
	assert_eq(r.size_id, "big")
	r.start(8)
	assert_eq(r.size_id, "normal", "a new run starts normal")


func test_big_rolls_into_low_stars() -> void:
	if _z() == null:
		return
	var r = load(RUN).new()
	r.start(7)
	r.set_size("big")
	var t = RunTracker.new([{"type": "star", "x": 10.0, "y": 4.0}], r.stats().pickup_offset, r.stats().pickup_radius)
	var sim := FlightSim.new()
	sim.launch(Vector2(12, 0), Vector2(6, 0))
	t.after_step(sim, Vector2(8, 0))
	assert_eq(t.stars_collected, 1, "a big alien rolling along the ground collects a star 4 m up")
