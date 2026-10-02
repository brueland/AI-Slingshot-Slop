extends GutTest
# Task 011: scripts/core/progress.gd holds coins and upgrade levels and buys upgrades
# (docs/DESIGN.md section 9, Progress).

const PATH := "res://scripts/core/progress.gd"


func _progress():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH).new()


func test_defaults() -> void:
	var p = _progress()
	if p == null:
		return
	assert_eq(p.coins, 0)
	assert_eq(p.levels, {})
	assert_almost_eq(p.best_distance, 0.0, 0.0001)
	assert_eq(p.total_runs, 0)
	assert_false(p.goal_reached)
	assert_eq(p.level_of("power"), 0)


func test_add_coins_ignores_non_positive_amounts() -> void:
	var p = _progress()
	if p == null:
		return
	p.add_coins(100)
	p.add_coins(-5)
	p.add_coins(0)
	assert_eq(p.coins, 100)


func test_buy_spends_coins_and_raises_the_level() -> void:
	var p = _progress()
	if p == null:
		return
	p.add_coins(100)
	assert_eq(p.next_cost("power"), 80)
	assert_true(p.can_buy("power"))
	assert_true(p.buy("power"))
	assert_eq(p.coins, 20)
	assert_eq(p.level_of("power"), 1)
	assert_eq(p.next_cost("power"), 136)
	assert_false(p.can_buy("power"), "136 > 20 coins")
	assert_false(p.buy("power"))
	assert_eq(p.coins, 20, "a failed purchase costs nothing")
	assert_eq(p.level_of("power"), 1)


func test_cannot_buy_unknown_or_maxed_upgrades() -> void:
	var p = _progress()
	if p == null:
		return
	p.add_coins(999999)
	assert_false(p.buy("laser"))
	p.levels["boosts"] = 25
	assert_eq(p.next_cost("boosts"), -1)
	assert_false(p.can_buy("boosts"), "boosts is maxed at 25")
	assert_false(p.buy("boosts"))
	assert_eq(p.coins, 999999)


func test_stats_follow_levels() -> void:
	var p = _progress()
	if p == null:
		return
	assert_almost_eq(p.stats().max_speed, 22.0, 0.0001)
	p.add_coins(80)
	p.buy("power")
	assert_almost_eq(p.stats().max_speed, 27.5, 0.0001)
