extends GutTest
# Task 299: the flowers are drawn as one mesh (one draw call) instead of a line and six circles each.


func test_flower_mesh() -> void:
	var f = load("res://scripts/game/flowers.gd").new()
	add_child_autofree(f)
	for x in [12.0, 20.0, 31.0]:
		f.grow_at(x)
	f.advance(1.0)
	f.queue_redraw()
	await wait_process_frames(2)
	assert_eq(f.mesh_indices.size(), 3 * (6 + 6 * 24), "a stem and six discs per flower")
	assert_eq(f.mesh_colors.size(), f.mesh_points.size())
	var base: Vector2 = WorldView.ground_point(12.0)
	assert_true(f.mesh_points.has(base + Vector2(0.0, -14.0)), "the first flower's middle sits on its 14 px stem")
	var text := FileAccess.get_file_as_string("res://scripts/game/flowers.gd")
	assert_false(text.contains("draw_circle"), "no separate circles")
	assert_true(text.contains("canvas_item_add_triangle_array"))
