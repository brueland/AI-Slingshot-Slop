extends GutTest
# Task 252: scripts/core/star_boosts.gd: in the roguelike every star gives a small random boost for the rest of the
# run (+2% speed, -3% drag, +0.015 bounciness or +0.2 m launch height); the n-th star of a run always gives the same.

const PATH := "res://scripts/core/star_boosts.gd"


func test_star_boosts() -> void:
	var b = load(PATH)
	assert_eq(b.LIST.size(), 4)
	var seen := {}
	for n in range(1, 101):
		var id: String = b.roll(77, n)
		assert_eq(b.roll(77, n), id, "the same star, the same boost")
		seen[id] = true
	assert_eq(seen.size(), 4, "every boost turns up")
	assert_ne([b.roll(1, 1), b.roll(1, 2), b.roll(1, 3)], [b.roll(2, 1), b.roll(2, 2), b.roll(2, 3)], "another run, other boosts")
	var s := PlayerStats.new()
	b.apply(s, {"speed": 2, "glide": 1, "bounce": 3, "lift": 1})
	assert_almost_eq(s.max_speed, 22.0 * 1.02 * 1.02, 0.0001)
	assert_almost_eq(s.drag, 0.002 * 0.97, 0.000001)
	assert_almost_eq(s.restitution, Balance.BASE_RESTITUTION + 0.045, 0.0001)
	assert_almost_eq(s.launch_height, 2.2, 0.0001)
	var capped := PlayerStats.new()
	b.apply(capped, {"bounce": 100})
	assert_almost_eq(capped.restitution, RoguePerks.MAX_RESTITUTION, 0.0001, "bounciness is capped like perks")
	assert_eq(b.summary(["speed", "lift", "speed"]), "Speed+ x2, Lift+ x1")
	assert_eq(b.summary([]), "")
