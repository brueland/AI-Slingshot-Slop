extends GutTest
# Task 034: ShopPanel also shows the coins, a header per category (Slingshot, Projectile, Score) above its
# upgrades, and a Launch! button.

const PATH := "res://scripts/ui/shop_panel.gd"
const PROGRESS := "res://scripts/core/progress.gd"


func _shop():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	var s = load(PATH).new()
	add_child_autofree(s)
	return s


func test_coins_label() -> void:
	var s = _shop()
	if s == null:
		return
	var p = load(PROGRESS).new()
	p.coins = 345
	s.refresh(p)
	assert_true(s.coins_label is Label)
	if s.coins_label is Label:
		assert_eq(s.coins_label.text, "Coins: 345")


func test_category_headers_come_before_their_upgrades() -> void:
	var s = _shop()
	if s == null:
		return
	assert_eq(s.header_labels.size(), 3)
	for category in ["launcher", "projectile", "score"]:
		assert_true(s.header_labels.get(category) is Label, "header for " + category)
	if s.header_labels.size() != 3:
		return
	assert_eq(s.header_labels["launcher"].text, "Slingshot")
	assert_eq(s.header_labels["projectile"].text, "Projectile")
	assert_eq(s.header_labels["score"].text, "Score")
	var parent: Node = s.header_labels["projectile"].get_parent()
	assert_eq(s.buttons["aero"].get_parent(), parent, "headers and buttons share one list")
	var header_index: int = s.header_labels["projectile"].get_index()
	assert_eq(s.buttons["aero"].get_index(), header_index + 1, "aero right below the Projectile header")
	assert_lt(s.buttons["bounce_bonus"].get_parent().get_parent().get_index(), s.launch_button.get_index(), "Launch! comes last, under the columns (task 222)")


func test_launch_button() -> void:
	var s = _shop()
	if s == null:
		return
	watch_signals(s)
	assert_true(s.launch_button is Button)
	if not s.launch_button is Button:
		return
	assert_eq(s.launch_button.text, "Launch!")
	s.launch_button.pressed.emit()
	assert_signal_emitted(s, "launch_requested")
