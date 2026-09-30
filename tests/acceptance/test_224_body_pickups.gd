extends GutTest
# Task 224: a star is picked up by the alien as it is drawn (1.5x its physical radius, Balance.LOOK_SCALE): within its
# drawn radius + 0.9 m of its drawn center, for every size and in classic too.


func test_pickups_match_the_drawn_alien() -> void:
	assert_eq(Balance.LOOK_SCALE, 1.5)
	assert_eq(ProjectileView.LOOK_SCALE, Balance.LOOK_SCALE, "the view draws with the same scale")
	var classic := PlayerStats.new()
	assert_almost_eq(classic.pickup_offset, 0.75 * 1.5, 0.0001)
	assert_almost_eq(classic.pickup_radius, 0.75 * 1.5 + RogueSizes.STAR_REACH, 0.0001)
	for id in ["small", "normal", "big"]:
		var s: float = RogueSizes.get_def(id)["scale"]
		var stats := RogueSizes.apply(PlayerStats.new(), id)
		assert_almost_eq(stats.pickup_offset, 0.75 * s * 1.5, 0.0001, id + ": the drawn center")
		assert_almost_eq(stats.pickup_radius, 0.75 * s * 1.5 + RogueSizes.STAR_REACH, 0.0001, id + ": the drawn radius + reach")
	# a big alien flying low collects a star that touches the top of its drawn body
	var big := RogueSizes.apply(PlayerStats.new(), "big")
	var top := 2.0 * 0.75 * 2.5 * 1.5
	var t := RunTracker.new([{"type": "star", "x": 10.0, "y": top + 0.5}], big.pickup_offset, big.pickup_radius)
	var sim := FlightSim.new()
	sim.launch(Vector2(12, 0), Vector2(6, 0))
	t.after_step(sim, Vector2(8, 0))
	assert_eq(t.stars_collected, 1, "a star half a meter over the big alien's head counts")
