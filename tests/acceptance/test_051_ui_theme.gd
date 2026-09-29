extends GutTest
# Task 051: scripts/ui/ui_theme.gd builds the game's UI Theme: rounded dark-blue panels with a gold border,
# blue buttons with hover/pressed/disabled looks, and white outlined text.

const PATH := "res://scripts/ui/ui_theme.gd"


func _theme():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH).build()


func test_build_returns_a_theme() -> void:
	var t = _theme()
	if t == null:
		return
	assert_true(t is Theme)
	assert_eq(t.default_font_size, 20)


func test_panel_style() -> void:
	var t = _theme()
	if t == null:
		return
	var sb = t.get_stylebox("panel", "PanelContainer")
	assert_true(sb is StyleBoxFlat, "PanelContainer/panel is a StyleBoxFlat")
	if not sb is StyleBoxFlat:
		return
	assert_eq(sb.bg_color, Color(0.09, 0.13, 0.24, 0.92))
	assert_eq(sb.corner_radius_top_left, 16)
	assert_eq(sb.corner_radius_bottom_right, 16)
	assert_eq(sb.border_width_top, 3)
	assert_eq(sb.border_width_left, 3)
	assert_eq(sb.border_color, Color(1.0, 0.85, 0.3))
	assert_almost_eq(sb.content_margin_left, 24.0, 0.001)


func test_button_styles() -> void:
	var t = _theme()
	if t == null:
		return
	var want := {
		"normal": Color(0.2, 0.45, 0.85), "hover": Color(0.3, 0.55, 0.95),
		"pressed": Color(0.15, 0.35, 0.7), "disabled": Color(0.3, 0.3, 0.35, 0.8),
	}
	for state in want:
		var sb = t.get_stylebox(state, "Button")
		assert_true(sb is StyleBoxFlat, "Button/%s is a StyleBoxFlat" % state)
		if sb is StyleBoxFlat:
			assert_eq(sb.bg_color, want[state], "Button/%s color" % state)
			assert_eq(sb.corner_radius_top_left, 10, "Button/%s rounded" % state)
	assert_eq(t.get_color("font_color", "Button"), Color.WHITE)


func test_outlined_labels() -> void:
	var t = _theme()
	if t == null:
		return
	assert_eq(t.get_color("font_color", "Label"), Color.WHITE)
	assert_eq(t.get_constant("outline_size", "Label"), 6)
	assert_gt(t.get_color("font_outline_color", "Label").a, 0.5)
