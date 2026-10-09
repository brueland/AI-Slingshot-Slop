extends GutTest
# Task 311: every hat gives a small boost in its style (Propeller Cap +3% launch speed, Crown +10% score, ...), and
# classic shots get the worn hat's boost.

const PATH := "res://scripts/core/hat_bonuses.gd"


func test_hat_bonuses() -> void:
	var hb = load(PATH)
	assert_eq(hb.text("propeller"), "+3% launch speed")
	assert_eq(hb.text("none"), "", "no hat, no bonus")
	for entry in Hats.LIST:
		if entry["id"] != "none":
			assert_ne(hb.text(entry["id"]), "", str(entry["id"]) + " gives something")
	var base := PlayerStats.from_levels({})
	var s: PlayerStats = hb.apply(PlayerStats.from_levels({}), "propeller")
	assert_almost_eq(s.max_speed, base.max_speed * 1.03, 0.0001)
	assert_eq(hb.apply(PlayerStats.from_levels({}), "chef").star_value, base.star_value + 2)
	assert_eq(hb.apply(PlayerStats.from_levels({}), "party").bounce_bonus, base.bounce_bonus + 2)
	assert_almost_eq(hb.apply(PlayerStats.from_levels({}), "top_hat").launch_height, base.launch_height + 0.5, 0.0001)
	assert_almost_eq(hb.apply(PlayerStats.from_levels({}), "wizard").drag, base.drag * 0.95, 0.0000001)
	assert_almost_eq(hb.apply(PlayerStats.from_levels({}), "crown").score_multiplier, base.score_multiplier + 0.1, 0.0001)
	assert_almost_eq(hb.apply(PlayerStats.from_levels({}), "cowboy").restitution, base.restitution + 0.02, 0.0001)
	assert_almost_eq(hb.apply(PlayerStats.from_levels({"bounce": 8}), "cowboy").restitution, 0.9, 0.0001, "never past 0.9")
	assert_almost_eq(hb.apply(PlayerStats.from_levels({}), "viking").pickup_radius, base.pickup_radius + 0.4, 0.0001)
	var beanie: PlayerStats = hb.apply(PlayerStats.from_levels({}), "beanie")
	assert_almost_eq(beanie.max_speed, base.max_speed * 1.02, 0.0001)
	assert_almost_eq(beanie.drag, base.drag * 0.98, 0.0000001)
	var p := Progress.new()
	var plain: float = p.stats().max_speed
	p.hat = "propeller"
	assert_almost_eq(p.stats().max_speed, plain * 1.03, 0.0001, "classic shots get the worn hat's boost")
