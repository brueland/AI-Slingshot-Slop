extends GutTest
# Task 009: scripts/core/player_stats.gd turns upgrade levels into gameplay numbers
# (docs/DESIGN.md section 4, "effect at level L").

const PATH := "res://scripts/core/player_stats.gd"
const SIM_PATH := "res://scripts/core/flight_sim.gd"


func _ps():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH)


func test_no_upgrades_gives_base_stats() -> void:
	var ps = _ps()
	if ps == null:
		return
	var s = ps.from_levels({})
	assert_almost_eq(s.max_speed, 22.0, 0.0001)
	assert_almost_eq(s.launch_height, 2.0, 0.0001)
	assert_eq(s.guide_points, 6)
	assert_almost_eq(s.drag, 0.002, 0.0000001)
	assert_almost_eq(s.restitution, 0.45, 0.0001, "bouncier since task 257")
	assert_eq(s.boost_charges, 0)
	assert_almost_eq(s.score_multiplier, 1.0, 0.0001)
	assert_eq(s.star_value, 10)
	assert_eq(s.bounce_bonus, 0)


func test_level_two_everywhere() -> void:
	var ps = _ps()
	if ps == null:
		return
	var levels := {}
	for id in ["power", "height", "guide", "aero", "bounce", "boosts", "multiplier", "star_value", "bounce_bonus"]:
		levels[id] = 2
	var s = ps.from_levels(levels)
	assert_almost_eq(s.max_speed, 33.0, 0.0001, "22 * (1 + 0.25 * 2)")
	assert_almost_eq(s.launch_height, 5.0, 0.0001, "2 + 1.5 * 2")
	assert_eq(s.guide_points, 18, "6 + 6 * 2")
	assert_almost_eq(s.drag, 0.00128, 0.0000001, "0.002 * (1 - 0.18 * 2)")
	assert_almost_eq(s.restitution, 0.61, 0.0001, "0.45 + 0.08 * 2")
	assert_eq(s.boost_charges, 2)
	assert_almost_eq(s.score_multiplier, 1.5, 0.0001)
	assert_eq(s.star_value, 20, "10 + 5 * 2")
	assert_eq(s.bounce_bonus, 6, "3 * 2")


func test_levels_are_clamped_and_unknown_ids_ignored() -> void:
	var ps = _ps()
	if ps == null:
		return
	var s = ps.from_levels({"power": 99, "boosts": -3, "laser": 5})
	assert_almost_eq(s.max_speed, 77.0, 0.0001, "power clamps to max level 10: 22 * 3.5")
	assert_eq(s.boost_charges, 0, "negative levels clamp to 0")


func test_int_fields_are_ints() -> void:
	var ps = _ps()
	if ps == null:
		return
	var s = ps.from_levels({"guide": 1, "star_value": 1, "bounce_bonus": 1, "boosts": 1})
	assert_eq(typeof(s.guide_points), TYPE_INT)
	assert_eq(typeof(s.star_value), TYPE_INT)
	assert_eq(typeof(s.bounce_bonus), TYPE_INT)
	assert_eq(typeof(s.boost_charges), TYPE_INT)


func test_apply_to_sim() -> void:
	var ps = _ps()
	if ps == null or not ResourceLoader.exists(SIM_PATH):
		return
	var s = ps.from_levels({"aero": 5, "bounce": 5, "boosts": 3})
	var sim = load(SIM_PATH).new()
	s.apply_to(sim)
	assert_almost_eq(sim.drag, 0.0002, 0.0000001)
	assert_almost_eq(sim.restitution, 0.85, 0.0001, "0.45 + 0.08 * 5 (task 257)")
	assert_eq(sim.boost_charges, 3)
