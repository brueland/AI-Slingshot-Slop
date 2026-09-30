extends GutTest
# Task 114: the results screen shows a small map of the shot (scripts/ui/shot_map.gd): the flight path over the
# ground, stretched to fit a 380 x 70 box.

const PATH := "res://scripts/ui/shot_map.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_114_save.json"


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func test_map_points() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var m = load(PATH).new()
	add_child_autofree(m)
	assert_eq(m.custom_minimum_size, Vector2(380, 70))
	m.set_path(PackedVector2Array([Vector2(0, 2), Vector2(50, 20), Vector2(100, 0)]))
	assert_almost_eq(m.far, 100.0, 0.001)
	assert_almost_eq(m.high, 20.0, 0.001)
	assert_eq(m.map_point(Vector2(0, 0)), Vector2(5, 65), "the start sits on the ground line")
	assert_eq(m.map_point(Vector2(100, 0)), Vector2(375, 65), "the farthest point at the right edge")
	assert_eq(m.map_point(Vector2(50, 20)), Vector2(190, 5), "the highest point at the top")
	await wait_process_frames(2)
	m.set_path(PackedVector2Array())
	await wait_process_frames(2)
	pass_test("draws with and without a path")


func test_results_show_the_shot() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	main.start_game()
	main.launch_with_pull(Vector2(-84.852814, 84.852814))
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	var panel = main.results_panel
	assert_true(panel.get("shot_map") is Control, "results_panel.shot_map")
	if panel.get("shot_map") == null:
		return
	assert_eq(main.last_result.get("path"), main.session.path, "the result keeps the shot's path")
	assert_eq(panel.shot_map.points, main.session.path)
	assert_gt(panel.shot_map.points.size(), 5)
	await wait_process_frames(3)
	assert_true(main.get_viewport().get_visible_rect().encloses(panel.get_global_rect()), "the results still fit on screen")
