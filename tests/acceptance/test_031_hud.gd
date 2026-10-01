extends GutTest
# Task 031: scripts/ui/hud.gd, the heads-up display: flight readouts and progress. It must never block the
# mouse (the slingshot is dragged underneath it).

const PATH := "res://scripts/ui/hud.gd"


func _hud():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	var h = load(PATH).new()
	add_child_autofree(h)
	return h


func test_is_a_control_that_ignores_the_mouse() -> void:
	var h = _hud()
	if h == null:
		return
	assert_true(h is Control)
	assert_eq(h.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	for key in ["distance_label", "height_label", "stars_label", "boosts_label", "best_label", "coins_label", "goal_label"]:
		assert_true(h.get(key) is Label, "hud.%s must be a Label" % key)


func test_update_flight() -> void:
	var h = _hud()
	if h == null:
		return
	h.update_flight(123.9, 45.2, 3, 1)
	assert_eq(h.distance_label.text, "Distance: 123 m")
	assert_eq(h.height_label.text, "Height: 45 m")
	assert_eq(h.stars_label.text, "Stars: 3")
	assert_eq(h.boosts_label.text, "Rocket: 1.0 s", "seconds of rocket left (task 233)")
	h.update_flight(-2.0, -0.5, 0, 0)
	assert_eq(h.distance_label.text, "Distance: 0 m", "never negative")
	assert_eq(h.height_label.text, "Height: 0 m")


func test_update_progress_and_next_goal() -> void:
	var h = _hud()
	if h == null:
		return
	h.update_progress(260.0, 1234)
	assert_eq(h.best_label.text, "Best: 260 m")
	assert_eq(h.coins_label.text, "Coins: 1234")
	assert_eq(h.goal_label.text, "Next: Half-K Hero at 500 m")
	h.update_progress(1200.0, 0)
	assert_eq(h.goal_label.text, "All milestones reached!")
