extends GutTest
# Task 249: the ground (grass, dirt and distance markers) is drawn around the camera and redrawn as it moves on, so
# a long shot never flies off the end of the ground (it stopped at 1900-2100 m).

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_249_save.json"
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



const PATH := "res://scripts/game/world_view.gd"


func test_span() -> void:
	var wv = load(PATH)
	assert_eq(wv.span_around(0.0), Vector2(-280.0, 555.0), "from behind the secret behind the wall (task 308)")
	assert_eq(wv.span_around(3000.0), Vector2(2590.0, 3425.0), "400 m on each side, on a 35 m step")
	var r: Rect2 = wv.ground_rect(2590.0, 3425.0)
	assert_eq(r.position, Vector2(2590.0 * 16.0, 0.0))
	assert_almost_eq(r.size.x, 835.0 * 16.0, 0.001)
	assert_almost_eq(fmod(r.position.x, 70.0), 0.0, 0.001, "starts on a whole tile, so redraws line up")
	assert_eq(wv.ground_rect().position, Vector2(-1600, 0), "the default is still the course's ground")


func test_ground_follows_the_camera() -> void:
	var main = _main()
	main.start_game()
	var wv = main.world_view
	await wait_process_frames(2)
	assert_lte(wv.drawn_from_m, -100.0, "behind the slingshot at the start")
	for x in [2500.0, 9000.0, 25000.0]:
		main.camera.snap_to(WorldView.world_to_screen(Vector2(x, 0.0)))
		await wait_process_frames(3)
		assert_almost_eq(wv.view_center_m(), x, 40.0, "the view is around %d m (the camera looks ahead)" % int(x))
		assert_lt(wv.drawn_from_m, x - 300.0, "ground behind the view at %d m" % int(x))
		assert_gt(wv.drawn_to_m, x + 300.0, "and ahead of it")
	assert_eq(WorldView.marker_distances(24990.0, 25100.0), [25000, 25050, 25100], "markers go on")
