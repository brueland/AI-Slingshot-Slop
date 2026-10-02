extends GutTest
# Task 058: scripts/game/scenery.gd decorates the ground with bushes, rocks and cacti (same layout every run);
# main.gd builds it once, between the ground and the course items.

const PATH := "res://scripts/game/scenery.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_058_save.json"


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func _sc():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH)


func test_layout_is_deterministic_and_spaced() -> void:
	var sc = _sc()
	if sc == null:
		return
	assert_eq(sc.SEED, 7)
	assert_eq(sc.TEXTURES.size(), 3)
	var a: Array = sc.layout(7, 500.0)
	assert_eq(a, sc.layout(7, 500.0), "same seed, same layout")
	assert_ne(a, sc.layout(8, 500.0))
	assert_between(a.size(), 18, 60)
	if a.is_empty():
		return
	assert_between(float(a[0]["x"]), -52.0, -35.0, "starts 60 m before the slingshot")
	for i in a.size():
		assert_between(int(a[i]["kind"]), 0, 2)
		assert_between(float(a[i]["scale"]), 0.5, 0.9)
		assert_lt(float(a[i]["x"]), 500.0)
		if i > 0:
			assert_between(float(a[i]["x"]) - float(a[i - 1]["x"]), 8.0, 25.0, "gap %d" % i)


func test_build_places_sprites_on_the_ground() -> void:
	var sc = _sc()
	if sc == null:
		return
	var node = sc.new()
	add_child_autofree(node)
	node.build(7, 300.0)
	var items: Array = sc.layout(7, 300.0)
	assert_eq(node.sprites.size(), items.size())
	if node.sprites.is_empty():
		return
	var s: Sprite2D = node.sprites[3]
	assert_eq(s.texture.resource_path, sc.TEXTURES[int(items[3]["kind"])])
	assert_eq(s.position, Vector2(float(items[3]["x"]) * 16.0, 0.0))
	assert_eq(s.offset, Vector2(0, -35), "standing on the ground")
	node.build(7, 100.0)
	assert_eq(node.get_child_count(), node.sprites.size(), "rebuilding replaces the old sprites")


func test_main_builds_scenery_between_ground_and_course() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	var scenery = main.get("scenery")
	assert_not_null(scenery, "main.scenery")
	if scenery == null:
		return
	assert_gt(scenery.get_index(), main.world_view.get_index(), "in front of the ground")
	assert_lt(scenery.get_index(), main.course_view.get_index(), "behind stars, springs and mud")
	assert_eq(scenery.sprites.size(), load(PATH).layout(7, 8000.0).size(), "built once, past the course too (task 250)")
