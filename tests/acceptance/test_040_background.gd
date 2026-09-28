extends GutTest
# Task 040: scripts/game/background.gd, a parallax sky and clouds (Parallax2D layers) drawn behind the world,
# added by main.gd as its first child.

const PATH := "res://scripts/game/background.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_040_save.json"


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func test_two_parallax_layers() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var bg = load(PATH).new()
	add_child_autofree(bg)
	assert_true(bg is Node2D)
	assert_lt(bg.z_index, 0, "drawn behind the world")
	assert_eq(bg.layers.size(), 2)
	if bg.layers.size() != 2:
		return
	var sky = bg.layers[0]
	var clouds = bg.layers[1]
	assert_true(sky is Parallax2D and clouds is Parallax2D)
	assert_lt(sky.scroll_scale.x, clouds.scroll_scale.x, "the sky moves slower than the clouds")
	assert_lt(clouds.scroll_scale.x, 1.0, "both move slower than the world")
	var sprite: Node = sky.get_child(0) if sky.get_child_count() > 0 else null
	assert_true(sprite is Sprite2D)
	if sprite is Sprite2D:
		assert_eq(sprite.texture.resource_path, "res://assets/backgrounds/sky.png")
	var cloud_count := 0
	for c in clouds.get_children():
		if c is Sprite2D and c.texture.resource_path == "res://assets/sprites/cloud.png":
			cloud_count += 1
	assert_gt(cloud_count, 1, "several clouds")


func test_main_adds_it_first() -> void:
	if not ResourceLoader.exists(SCENE):
		fail_test("missing " + SCENE)
		return
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	var bg = main.get("background")
	assert_not_null(bg, "main.background")
	if bg == null:
		return
	assert_eq(bg.get_script().resource_path, PATH)
	assert_eq(main.get_child(0), bg, "the background is main's first child, so it is drawn first")
