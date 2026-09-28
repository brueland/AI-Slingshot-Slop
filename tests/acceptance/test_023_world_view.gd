extends GutTest
# Task 023: scripts/game/world_view.gd draws the ground and distance markers and converts between world
# meters (y up) and screen pixels (y down) (docs/DESIGN.md section 2).

const PATH := "res://scripts/game/world_view.gd"


func _wv():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH)


func test_world_to_screen() -> void:
	var wv = _wv()
	if wv == null:
		return
	assert_eq(wv.world_to_screen(Vector2(10, 2)), Vector2(160, -32))
	assert_eq(wv.world_to_screen(Vector2.ZERO), Vector2.ZERO)
	assert_eq(wv.world_to_screen(Vector2(-1, -1)), Vector2(-16, 16))


func test_screen_to_world_is_the_inverse() -> void:
	var wv = _wv()
	if wv == null:
		return
	assert_eq(wv.screen_to_world(Vector2(160, -32)), Vector2(10, 2))
	var p := Vector2(123.25, 45.5)
	var back: Vector2 = wv.screen_to_world(wv.world_to_screen(p))
	assert_almost_eq(back.x, p.x, 0.0001)
	assert_almost_eq(back.y, p.y, 0.0001)


func test_marker_distances() -> void:
	var wv = _wv()
	if wv == null:
		return
	assert_eq(wv.marker_distances(0.0, 175.0), [50, 100, 150])
	assert_eq(wv.marker_distances(60.0, 200.0), [100, 150, 200])
	assert_eq(wv.marker_distances(0.0, 40.0), [])


func test_node_loads_ground_texture() -> void:
	var wv = _wv()
	if wv == null:
		return
	var node = wv.new()
	add_child_autofree(node)
	assert_true(node is Node2D)
	assert_not_null(node.ground_texture)
	if node.ground_texture != null:
		assert_eq(node.ground_texture.resource_path, "res://assets/sprites/ground.png")
	assert_true(FileAccess.get_file_as_string(PATH).contains("class_name WorldView"))
