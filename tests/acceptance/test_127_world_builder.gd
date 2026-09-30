extends GutTest
# Task 127 (refactor): scripts/game/world_builder.gd creates main's world nodes (same nodes, same order, children of
# main), so main.gd's _ready() is short and new decorations can be added without touching main.gd.

const PATH := "res://scripts/game/world_builder.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_127_save.json"


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func test_builder_creates_the_world() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var main_text := FileAccess.get_file_as_string("res://scripts/game/main.gd")
	assert_true(main_text.contains("WorldBuilder.build(self)"), "main.gd calls WorldBuilder.build(self)")
	for moved in ["SkyBackground.new()", "Critters.new()", "ProjectileView.new()", "Feedback.new()"]:
		assert_false(main_text.contains(moved), "main.gd must not contain '%s' (WorldBuilder does it)" % moved)
	var text := FileAccess.get_file_as_string(PATH)
	assert_true(text.contains("class_name WorldBuilder"))
	assert_true(text.contains("static func build(main: Node) -> void:"))
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	var order := ["background", "audio", "fader", "world_view", "scenery", "critters", "birds", "ufo", "course_view",
		"balloon_view", "slingshot", "trajectory", "ghost", "trail", "shadow", "projectile_view", "camera", "popups",
		"effects", "feedback", "ui_layer"]
	var last := -1
	for node_name in order:
		var node = main.get(node_name)
		assert_not_null(node, "main.%s" % node_name)
		if node == null:
			continue
		assert_eq(node.get_parent(), main)
		assert_gt(node.get_index(), last, node_name + " keeps its place")
		last = node.get_index()
	main.start_game()
	main.launch_with_pull(Vector2(-84.852814, 84.852814))
	assert_eq(main.state_name(), "FLIGHT", "the game still plays")
