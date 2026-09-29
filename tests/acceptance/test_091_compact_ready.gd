extends GutTest
# Task 091 (refactor): main.gd's _ready() is written compactly (no blank or comment lines between the node
# creations) to make room for milestone 10. The nodes, their order and their wiring do not change.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_091_save.json"


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func _ready_lines() -> PackedStringArray:
	var text := FileAccess.get_file_as_string("res://scripts/game/main.gd")
	var start := text.find("func _ready() -> void:")
	var end := text.find("\nfunc ", start + 1)
	return text.substr(start, end - start).strip_edges().split("\n")


func test_ready_is_compact() -> void:
	var lines := _ready_lines()
	assert_lt(lines.size(), 56, "_ready() has fewer than 56 lines (it has %d)" % lines.size())
	for line in lines:
		assert_ne(line.strip_edges(), "", "no blank lines inside _ready()")
		assert_false(line.strip_edges().begins_with("#"), "no comment-only lines inside _ready(): " + line)


func test_nodes_and_order_are_unchanged() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	var order := ["background", "audio", "fader", "world_view", "scenery", "critters", "course_view", "slingshot",
		"trajectory", "trail", "shadow", "projectile_view", "camera", "popups", "effects", "feedback", "ui_layer"]
	var last := -1
	for node_name in order:
		var node = main.get(node_name)
		assert_not_null(node, "main.%s" % node_name)
		if node == null:
			continue
		assert_eq(node.get_parent(), main, node_name + " is a child of main")
		assert_gt(node.get_index(), last, node_name + " keeps its place in the order")
		last = node.get_index()
	assert_eq(main.background.get_index(), 0, "the sky is the first child")
	assert_eq(main.feedback.critters, main.critters)
	assert_eq(main.feedback.hud, main.hud)
	assert_true(main.slingshot.launched.is_connected(main.launch_with_pull))
