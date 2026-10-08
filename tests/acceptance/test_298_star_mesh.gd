extends GutTest
# Task 298: the twinkling night stars are drawn as one mesh (one draw call) instead of 90 separate circles.


func test_star_mesh() -> void:
	var f = load("res://scripts/game/star_field.gd").new()
	add_child_autofree(f)
	var mesh: Dictionary = f.star_mesh(f.stars, 0.5)
	assert_eq(mesh["points"].size(), 90 * 9, "a center and 8 rim points per star")
	assert_eq(mesh["colors"].size(), mesh["points"].size())
	assert_eq(mesh["indices"].size(), 90 * 24, "8 triangles per star")
	var s: Vector3 = f.stars[0]
	var twinkle := 0.6 + 0.4 * sin(0.5 * 2.0 + s.z)
	assert_eq(mesh["points"][0], Vector2(s.x, s.y))
	assert_almost_eq(mesh["points"][1].distance_to(Vector2(s.x, s.y)), 1.5 + 0.8 * twinkle, 0.001, "the size twinkles")
	assert_almost_eq(mesh["colors"][0].a, twinkle, 0.001, "and the brightness")
	var text := FileAccess.get_file_as_string("res://scripts/game/star_field.gd")
	assert_false(text.contains("draw_circle"), "no separate circles")
	assert_true(text.contains("canvas_item_add_triangle_array"))
	f.set_height(400.0)
	f.advance_shooting(0.1)
	f.queue_redraw()
	await wait_process_frames(2)
