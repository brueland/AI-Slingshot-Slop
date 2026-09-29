extends GutTest
# Task 053: WorldView draws solid ground: a tiled dirt texture filling GROUND_DEPTH_PX (600 px) below the grass,
# so the ground no longer floats as a thin strip over the sky; distance labels get a dark outline.

const PATH := "res://scripts/game/world_view.gd"


func test_ground_rect() -> void:
	var wv = load(PATH)
	assert_true(wv.get_script_constant_map().has("GROUND_DEPTH_PX"), "WorldView.GROUND_DEPTH_PX exists")
	if not wv.get_script_constant_map().has("GROUND_DEPTH_PX"):
		return
	assert_almost_eq(float(wv.GROUND_DEPTH_PX), 600.0, 0.001)
	var r: Rect2 = wv.ground_rect()
	assert_eq(r.position, Vector2(-1600, 0), "starts 100 m before the slingshot, at ground level")
	assert_almost_eq(r.size.x, (2000.0 + 200.0) * 16.0, 0.001, "covers the course plus 100 m on each side")
	assert_almost_eq(r.size.y, 600.0, 0.001, "600 px deep")


func test_dirt_texture_loaded() -> void:
	var node = load(PATH).new()
	add_child_autofree(node)
	assert_not_null(node.get("dirt_texture"), "WorldView.dirt_texture")
	if node.get("dirt_texture") != null:
		assert_eq(node.dirt_texture.resource_path, "res://assets/sprites/mud.png")
	assert_not_null(node.ground_texture, "the grass texture is still used")
	await wait_process_frames(2)
	pass_test("the ground draws without errors")
