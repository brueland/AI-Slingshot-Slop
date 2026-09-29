extends GutTest
# Task 052: main.gd builds one UiTheme (main.ui_theme) and gives it to every Control on ui_layer, so every
# panel, button and HUD label uses the new look.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_052_save.json"


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func _main():
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	return main


func test_every_ui_control_uses_the_theme() -> void:
	var main = _main()
	assert_true(main.get("ui_theme") is Theme, "main.ui_theme is a Theme")
	if not main.get("ui_theme") is Theme:
		return
	var count := 0
	for child in main.ui_layer.get_children():
		if child is Control:
			count += 1
			assert_eq(child.theme, main.ui_theme, "%s uses main.ui_theme" % child.name)
	assert_gt(count, 7, "hud, the panels and the pause label")


func test_theme_reaches_nested_controls() -> void:
	var main = _main()
	if not main.get("ui_theme") is Theme:
		fail_test("main.ui_theme missing")
		return
	assert_eq(main.hud.distance_label.get_theme_constant("outline_size"), 6, "HUD labels are outlined")
	var sb = main.title_panel.play_button.get_theme_stylebox("normal")
	assert_true(sb is StyleBoxFlat and sb.corner_radius_top_left == 10, "buttons are rounded")
	var panel = main.shop_panel.get_theme_stylebox("panel")
	assert_true(panel is StyleBoxFlat and panel.border_width_top == 3, "panels have the gold border")
