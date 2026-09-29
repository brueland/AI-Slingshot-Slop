extends GutTest
# Task 061 (refactor): scripts/ui/ui_root.gd builds and themes every UI control; main.gd only keeps references
# and connects signals, which makes room in main.gd for the next features. Behavior must not change.

const PATH := "res://scripts/ui/ui_root.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_061_save.json"
const PARTS := {
	"hud": "res://scripts/ui/hud.gd",
	"results_panel": "res://scripts/ui/results_panel.gd",
	"victory_panel": "res://scripts/ui/victory_panel.gd",
	"shop_panel": "res://scripts/ui/shop_panel.gd",
	"title_panel": "res://scripts/ui/title_panel.gd",
	"options_panel": "res://scripts/ui/options_panel.gd",
	"credits_panel": "res://scripts/ui/credits_panel.gd",
}


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func test_ui_root_builds_everything() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var root = load(PATH).new()
	add_child_autofree(root)
	assert_true(root is CanvasLayer)
	for key in PARTS:
		var node = root.get(key)
		assert_not_null(node, "UiRoot.%s" % key)
		if node != null:
			assert_eq(node.get_script().resource_path, PARTS[key], key)
			assert_eq(node.get_parent(), root, key + " is a child of UiRoot")
	assert_true(root.pause_label is Label and not root.pause_label.visible, "a hidden pause label")
	assert_eq(root.pause_label.text, "Paused - press Esc to resume")
	assert_true(root.ui_theme is Theme)
	for child in root.get_children():
		if child is Control:
			assert_eq(child.theme, root.ui_theme, "%s is themed" % child.name)


func test_main_uses_ui_root() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	var layer = main.ui_layer
	assert_true(layer != null and layer.get_script() != null and layer.get_script().resource_path == PATH,
		"main.ui_layer is a UiRoot")
	if layer == null or layer.get_script() == null or layer.get_script().resource_path != PATH:
		return
	for key in PARTS:
		assert_eq(main.get(key), layer.get(key), "main.%s is UiRoot's" % key)
	assert_eq(main.pause_label, layer.pause_label)
	assert_eq(main.ui_theme, layer.ui_theme)
	main.title_panel.play_button.pressed.emit()
	assert_eq(main.state_name(), "AIM", "the buttons are still connected")


func test_main_no_longer_builds_ui() -> void:
	var text := FileAccess.get_file_as_string("res://scripts/game/main.gd")
	for built in ["Hud.new()", "ResultsPanel.new()", "ShopPanel.new()", "Label.new()", "UiTheme.build()"]:
		assert_false(text.contains(built), "main.gd must not contain %s (UiRoot builds it)" % built)
