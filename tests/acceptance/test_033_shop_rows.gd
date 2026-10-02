extends GutTest
# Task 033: scripts/ui/shop_panel.gd, one button per upgrade showing level and price.

const PATH := "res://scripts/ui/shop_panel.gd"
const PROGRESS := "res://scripts/core/progress.gd"


func _shop():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	var s = load(PATH).new()
	add_child_autofree(s)
	return s


func _progress(coins: int, levels: Dictionary):
	var p = load(PROGRESS).new()
	p.coins = coins
	p.levels = levels
	return p


func test_one_button_per_upgrade() -> void:
	var s = _shop()
	if s == null:
		return
	assert_true(s is PanelContainer)
	assert_false(s.visible, "hidden until the shop state")
	assert_eq(s.buttons.size(), 9)
	for id in ["power", "height", "guide", "aero", "bounce", "boosts", "multiplier", "star_value", "bounce_bonus"]:
		assert_true(s.buttons.get(id) is Button, "a Button for " + id)


func test_refresh_shows_level_price_and_affordability() -> void:
	var s = _shop()
	if s == null:
		return
	s.refresh(_progress(100, {"power": 1, "boosts": 25}))
	assert_eq(s.buttons["power"].text, "Band Power  Lv 1  136 coins")
	assert_true(s.buttons["power"].disabled, "136 > 100 coins")
	assert_eq(s.buttons["height"].text, "Tall Frame  Lv 0  60 coins")
	assert_false(s.buttons["height"].disabled)
	assert_eq(s.buttons["boosts"].text, "Rocket Boosts  Lv 25  MAX")
	assert_true(s.buttons["boosts"].disabled)
	assert_ne(s.buttons["height"].tooltip_text, "", "the tooltip shows the description")


func test_pressing_a_button_requests_that_purchase() -> void:
	var s = _shop()
	if s == null:
		return
	watch_signals(s)
	s.refresh(_progress(100, {}))
	s.buttons["height"].pressed.emit()
	assert_signal_emitted_with_parameters(s, "purchase_requested", ["height"])
	s.buttons["aero"].pressed.emit()
	assert_signal_emitted_with_parameters(s, "purchase_requested", ["aero"])
