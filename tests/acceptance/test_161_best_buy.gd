extends GutTest
# Task 161: the shop highlights the cheapest upgrade you can afford (green).


func test_best_buy() -> void:
	var shop = load("res://scripts/ui/shop_panel.gd").new()
	add_child_autofree(shop)
	var p = load("res://scripts/core/progress.gd").new()
	p.coins = 1000
	shop.refresh(p)
	var expected := ""
	for id in UpgradeCatalog.ids():
		if p.can_buy(id) and (expected == "" or p.next_cost(id) < p.next_cost(expected)):
			expected = id
	assert_eq(shop.best_buy, expected)
	assert_eq(shop.buttons[expected].modulate, Color(0.75, 1.0, 0.75))
	for id in UpgradeCatalog.ids():
		if id != expected:
			assert_eq(shop.buttons[id].modulate, Color.WHITE)
	p.coins = 0
	shop.refresh(p)
	assert_eq(shop.best_buy, "", "nothing affordable, nothing highlighted")
