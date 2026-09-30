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
	assert_eq(t.default_font_size, 22, "Fredoka at 22 px (task 214)")


func test_panel_style() -> void:
	var t = _theme()
	if t == null:
		return
	var sb = t.get_stylebox("panel", "PanelContainer")
	assert_true(sb is StyleBoxFlat, "PanelContainer/panel is a StyleBoxFlat")
	if not sb is StyleBoxFlat:
		return
	# Updated by task 215: rounder panels with a thicker border and a shadow
	assert_eq(sb.bg_color, Color(0.12, 0.14, 0.32, 0.95))
	assert_eq(sb.corner_radius_top_left, 22)
	assert_eq(sb.corner_radius_bottom_right, 22)
	assert_eq(sb.border_width_top, 4)
	assert_eq(sb.border_width_left, 4)
	assert_eq(sb.border_color, Color(1.0, 0.88, 0.45))
	assert_almost_eq(sb.content_margin_left, 24.0, 0.001)


func test_button_styles() -> void:
	var t = _theme()
	if t == null:
		return
	var want := {
		"normal": Color(0.22, 0.5, 0.95), "hover": Color(0.33, 0.6, 1.0),
		"pressed": Color(0.18, 0.42, 0.85), "disabled": Color(0.35, 0.37, 0.45, 0.9),
	}
	for state in want:
		var sb = t.get_stylebox(state, "Button")
		assert_true(sb is StyleBoxFlat, "Button/%s is a StyleBoxFlat" % state)
		if sb is StyleBoxFlat:
			assert_eq(sb.bg_color, want[state], "Button/%s color" % state)
			assert_eq(sb.corner_radius_top_left, 16, "Button/%s rounded (task 215)" % state)
	assert_eq(t.get_color("font_color", "Button"), Color.WHITE)


func test_outlined_labels() -> void:
	var t = _theme()
	if t == null:
		return
	assert_eq(t.get_color("font_color", "Label"), Color.WHITE)
	assert_eq(t.get_constant("outline_size", "Label"), 6)
	assert_gt(t.get_color("font_outline_color", "Label").a, 0.5)
