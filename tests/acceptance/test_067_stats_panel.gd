extends GutTest
# Task 067: scripts/ui/distance_chart.gd (a line chart of the last runs) and scripts/ui/stats_panel.gd (lifetime
# stats plus the chart). UI pieces only; task 068 opens them from the title screen.

const CHART := "res://scripts/ui/distance_chart.gd"
const PANEL := "res://scripts/ui/stats_panel.gd"
const PROGRESS := "res://scripts/core/progress.gd"


func test_chart_points() -> void:
	if not ResourceLoader.exists(CHART):
		fail_test("missing file " + CHART)
		return
	var c = load(CHART)
	assert_eq(c.chart_points([], Vector2(100, 50)).size(), 0)
	var pts: PackedVector2Array = c.chart_points([10.0, 20.0, 5.0], Vector2(100, 50))
	assert_eq(pts.size(), 3)
	if pts.size() == 3:
		assert_true(pts[0].is_equal_approx(Vector2(0, 25)), "10 of 20 is half way up: %s" % pts[0])
		assert_true(pts[1].is_equal_approx(Vector2(50, 0)), "the largest value touches the top")
		assert_true(pts[2].is_equal_approx(Vector2(100, 37.5)), "the newest is on the right")
	var zeros: PackedVector2Array = c.chart_points([0.0, 0.0], Vector2(100, 50))
	assert_true(zeros[1].is_equal_approx(Vector2(100, 50)), "all zero: along the bottom, no division by zero")


func test_chart_node() -> void:
	if not ResourceLoader.exists(CHART):
		fail_test("missing file " + CHART)
		return
	var c = load(CHART).new()
	add_child_autofree(c)
	assert_true(c is Control)
	assert_eq(c.custom_minimum_size, Vector2(360, 120))
	c.set_values([3, 4.5, 6])
	assert_eq(c.values.size(), 3)
	assert_almost_eq(c.values[1], 4.5, 0.0001)
	await wait_process_frames(2)


func test_stats_panel() -> void:
	if not ResourceLoader.exists(PANEL):
		fail_test("missing file " + PANEL)
		return
	var p = load(PROGRESS).new()
	p.total_runs = 12
	p.best_distance = 345.6
	p.lifetime = {"distance": 2345.9, "stars": 31, "bounces": 57, "best_height": 44.4}
	p.recent_distances.assign([100.0, 120.0, 345.6])
	var s = load(PANEL).new()
	add_child_autofree(s)
	watch_signals(s)
	assert_true(s is PanelContainer)
	assert_false(s.visible)
	s.show_stats(p)
	assert_true(s.visible)
	assert_eq(s.runs_label.text, "Runs: 12")
	assert_eq(s.distance_label.text, "Total distance: 2345 m")
	assert_eq(s.best_label.text, "Best distance: 345 m")
	assert_eq(s.height_label.text, "Best height: 44 m")
	assert_eq(s.stars_label.text, "Stars collected: 31")
	assert_eq(s.bounces_label.text, "Bounces: 57")
	assert_true(s.chart.get_script() != null and s.chart.get_script().resource_path == CHART)
	assert_eq(s.chart.values.size(), 3)
	await wait_process_frames(2)
	s.close_button.pressed.emit()
	assert_signal_emitted(s, "closed")
