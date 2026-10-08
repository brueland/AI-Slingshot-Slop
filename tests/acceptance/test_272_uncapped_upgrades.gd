extends GutTest
# Task 272: classic upgrades are not capped: every one goes to level 25 (prices keep growing), the shop shows the
# level without a maximum, and past their old caps drag and bounciness keep improving more slowly (bounciness
# never past 0.9).


func test_uncapped_upgrades() -> void:
	for id in UpgradeCatalog.ids():
		assert_eq(UpgradeCatalog.max_level(id), {"guide": 12, "bounce": 8}.get(id, 25), id + " (task 297)")
		var top: int = UpgradeCatalog.max_level(id)
		assert_gt(UpgradeCatalog.cost(id, top - 1), UpgradeCatalog.cost(id, top - 2), id + " keeps getting dearer")
	var five := PlayerStats.from_levels({"aero": 5, "bounce": 5})
	var more := PlayerStats.from_levels({"aero": 8, "bounce": 6})
	assert_almost_eq(five.drag, 0.002 * (1.0 - 0.9), 0.0000001, "the first 5 levels as before")
	assert_almost_eq(more.drag, five.drag * pow(0.9, 3), 0.0000001, "then 10% less drag per level")
	assert_almost_eq(more.restitution, five.restitution + 0.02, 0.0001, "and +0.02 bounciness per level")
	assert_almost_eq(PlayerStats.from_levels({"bounce": 8}).restitution, 0.9, 0.0001, "capped")
	assert_almost_eq(PlayerStats.from_levels({"bounce": 25}).restitution, 0.9, 0.0001, "never past 0.9")
	assert_gt(PlayerStats.from_levels({"aero": 25}).drag, 0.0, "drag never reaches 0")
	var p := Progress.new()
	p.add_coins(99999999)
	p.levels["power"] = 10
	assert_true(p.can_buy("power"), "the old maximum is not the end")
	assert_true(p.buy("power"))
	assert_eq(p.level_of("power"), 11)
