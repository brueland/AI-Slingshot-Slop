extends GutTest
# Task 216b: the theme again has no focus box on buttons, grey disabled button text, and dark label outlines.


func test_theme_details() -> void:
	var theme: Theme = load("res://scripts/ui/ui_theme.gd").build()
	assert_true(theme.get_stylebox("focus", "Button") is StyleBoxEmpty, "no focus box around clicked buttons")
	assert_eq(theme.get_color("font_disabled_color", "Button"), Color(0.7, 0.7, 0.75), "disabled buttons have grey text")
	assert_eq(theme.get_color("font_outline_color", "Label"), Color(0, 0, 0, 0.85), "labels have a dark outline")
	assert_eq(theme.get_color("font_color", "Button"), Color.WHITE)
