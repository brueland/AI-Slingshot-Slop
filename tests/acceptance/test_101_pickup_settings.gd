extends GutTest
# Task 101: star pickups become a setting. PlayerStats has size_scale, pickup_offset and pickup_radius; RunSession
# gives the offset and radius to its RunTracker. The defaults keep the classic rule exactly (1.5 m around the
# contact point); a positive offset measures from higher up (the alien's body), so rolling into a low star counts.

const TRACKER := "res://scripts/core/run_tracker.gd"
const STATS := "res://scripts/core/player_stats.gd"
const SESSION := "res://scripts/core/run_session.gd"
const SIM := "res://scripts/core/flight_sim.gd"


func _sim_at(to: Vector2):
	var sim = load(SIM).new()
	sim.launch(to, Vector2(8, 0))
	return sim


func test_stats_defaults() -> void:
	var s = load(STATS).from_levels({"power": 3})
	assert_almost_eq(float(s.get("size_scale")), 1.0, 0.0001)
	assert_almost_eq(float(s.get("pickup_offset")), 0.0, 0.0001)
	assert_almost_eq(float(s.get("pickup_radius")), 1.5, 0.0001, "the classic star radius")


func test_tracker_defaults_are_the_classic_rule() -> void:
	var t = load(TRACKER).new([{"type": "star", "x": 10.0, "y": 1.6}])
	assert_almost_eq(t.pickup_offset, 0.0, 0.0001)
	assert_almost_eq(t.pickup_radius, 1.5, 0.0001)
	t.after_step(_sim_at(Vector2(12, 0)), Vector2(8, 0))
	assert_eq(t.stars_collected, 0, "rolling on the ground misses a star 1.6 m up (classic)")


func test_offset_and_radius() -> void:
	var t = load(TRACKER).new([{"type": "star", "x": 10.0, "y": 2.2}, {"type": "star", "x": 20.0, "y": 3.5}], 0.75, 1.65)
	t.after_step(_sim_at(Vector2(12, 0)), Vector2(8, 0))
	assert_eq(t.stars_collected, 1, "rolling into a star 2.2 m up counts when measured from the body")
	t.after_step(_sim_at(Vector2(22, 0)), Vector2(18, 0))
	assert_eq(t.stars_collected, 1, "3.5 m up is still out of reach")
	var wide = load(TRACKER).new([{"type": "star", "x": 20.0, "y": 3.5}], 1.875, 2.775)
	wide.after_step(_sim_at(Vector2(22, 0)), Vector2(18, 0))
	assert_eq(wide.stars_collected, 1, "a bigger body reaches higher")


func test_session_passes_the_settings() -> void:
	var stats = load(STATS).from_levels({})
	stats.pickup_offset = 0.75
	stats.pickup_radius = 1.65
	var s = load(SESSION).new(stats, 3)
	assert_almost_eq(s.tracker.pickup_offset, 0.75, 0.0001)
	assert_almost_eq(s.tracker.pickup_radius, 1.65, 0.0001)
	var classic = load(SESSION).new(load(STATS).from_levels({}), 3)
	assert_almost_eq(classic.tracker.pickup_offset, 0.0, 0.0001)
	assert_almost_eq(classic.tracker.pickup_radius, 1.5, 0.0001)
