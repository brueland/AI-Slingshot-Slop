extends GutTest
# Task 290: WorldView helpers for an endless, light meadow: the stretch of the world on screen (visible_span), the
# copy of a repeating decoration nearest a place (repeat_x), and the hilly ground as two strips (two draw calls).

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_290_save.json"
const PULL := Vector2(-84.852814, 84.852814)


func before_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func after_each() -> void:
	before_each()


func _main():
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	return main


func _fly(main, pull: Vector2) -> void:
	main.launch_with_pull(pull)
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)


func _on_screen(main, control: Control, what: String) -> void:
	assert_true(main.get_viewport().get_visible_rect().encloses(control.get_global_rect()), what + " is on screen")



func test_view_helpers() -> void:
	var wv = load("res://scripts/game/world_view.gd")
	assert_eq(wv.repeat_x(50.0, 2000.0, 60.0), 50.0, "the layout itself")
	assert_eq(wv.repeat_x(50.0, 2000.0, 2100.0), 2050.0, "the next copy")
	assert_eq(wv.repeat_x(50.0, 2000.0, 9000.0), 8050.0)
	assert_eq(wv.repeat_x(1950.0, 2000.0, -100.0), 1950.0, "never before the layout (behind the slingshot)")
	var node := Node2D.new()
	add_child_autofree(node)
	var width_m: float = node.get_viewport_rect().size.x / Balance.PIXELS_PER_METER
	var span: Vector2 = wv.visible_span(node, 5.0)
	assert_almost_eq(span.x, -5.0, 0.001, "no camera: the screen starts at 0 m")
	assert_almost_eq(span.y, width_m + 5.0, 0.001)
	var dirt: Dictionary = wv.ground_strip(0.0, 10.0, 0.0, 600.0, true)
	assert_eq(dirt["points"].size(), 12, "two points every 2 m from 0 to 10 m")
	assert_eq(dirt["indices"].size(), 30, "two triangles per piece")
	assert_eq(dirt["points"][0], wv.ground_point(0.0))
	assert_eq(dirt["points"][1], Vector2(0.0, 600.0), "the dirt goes down to the flat bottom")
	assert_eq(dirt["uvs"][1], Vector2(0.0, 600.0) / 70.0)
	var grass: Dictionary = wv.ground_strip(0.0, 3.0, -8.0, 24.0, false)
	assert_eq(grass["points"].size(), 6, "0, 2 and 3 m")
	assert_eq(grass["points"][5], wv.ground_point(3.0) + Vector2(0.0, 24.0))
	assert_eq(grass["uvs"][5], Vector2(48.0 / 70.0, 32.0 / 70.0), "the grass texture from top to bottom")
	var text := FileAccess.get_file_as_string("res://scripts/game/world_view.gd")
	assert_true(text.contains("canvas_item_add_triangle_array"), "each strip is one draw call")
	var main = _main()
	main.start_rogue(5)
	main.rogue.round_number = 20
	main._begin_aim()
	await wait_process_frames(3)
	assert_eq(main.world_view.drawn_version, WorldView.terrain_version, "the hills are drawn")
	var camera_span: Vector2 = wv.visible_span(main.world_view, 0.0)
	assert_almost_eq(camera_span.y - camera_span.x, main.get_viewport_rect().size.x / Balance.PIXELS_PER_METER / main.camera.zoom.x, 0.5, "the camera's view")
