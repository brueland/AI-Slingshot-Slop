extends GutTest
# Task 215: chunky buttons (a darker lip along the bottom that presses in), an orange PrimaryButton style, and panels
# with a shadow.


func test_button_and_panel_style() -> void:
	var ui = load("res://scripts/ui/ui_theme.gd")
	var blue := Color(0.2, 0.5, 0.9)
	var normal: StyleBoxFlat = ui.button_box(blue, false)
	var pressed: StyleBoxFlat = ui.button_box(blue, true)
	assert_eq(normal.border_width_bottom, 6, "a lip along the bottom")
	assert_eq(pressed.border_width_bottom, 2, "pressed in")
	assert_eq(normal.content_margin_top + normal.content_margin_bottom, pressed.content_margin_top + pressed.content_margin_bottom,
		"the same height pressed or not")
	assert_gt(pressed.content_margin_top, normal.content_margin_top, "the text moves down when pressed")
	assert_lt(normal.border_color.get_luminance(), blue.get_luminance(), "a darker lip")
	assert_gt(normal.shadow_size, 0)
	var theme: Theme = ui.build()
	assert_true(theme.is_type_variation("PrimaryButton", "Button"))
	var primary: StyleBoxFlat = theme.get_stylebox("normal", "PrimaryButton")
	assert_eq(primary.bg_color, ui.PRIMARY_COLORS["normal"], "orange")
	assert_eq(theme.get_font_size("font_size", "PrimaryButton"), 42)
	var panel: StyleBoxFlat = theme.get_stylebox("panel", "PanelContainer")
	assert_eq(panel.corner_radius_top_left, 22)
	assert_gt(panel.shadow_size, 0, "panels cast a shadow")
