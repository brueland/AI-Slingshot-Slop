extends GutTest
# Task 030: main.gd builds the world nodes in _ready() and keeps them in sync with the run:
# course sprites, slingshot (drag to launch), trajectory preview while aiming, projectile, camera.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_030_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func _main():
	if not ResourceLoader.exists(SCENE):
		fail_test("missing " + SCENE)
		return null
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	return main


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func _script_of(node) -> String:
	return node.get_script().resource_path if node != null and node.get_script() != null else ""


func test_world_nodes_exist() -> void:
	var main = _main()
	if main == null:
		return
	var want := {
		"world_view": "res://scripts/game/world_view.gd",
		"course_view": "res://scripts/game/course_view.gd",
		"slingshot": "res://scripts/game/slingshot.gd",
		"trajectory": "res://scripts/game/trajectory_preview.gd",
		"projectile_view": "res://scripts/game/projectile_view.gd",
		"camera": "res://scripts/game/camera_rig.gd",
	}
	for key in want:
		var node = main.get(key)
		assert_not_null(node, "main.%s must exist after _ready()" % key)
		if node != null:
			assert_eq(_script_of(node), want[key], "main.%s script" % key)
			assert_true(node.is_inside_tree(), "main.%s is in the tree" % key)


func test_aiming_sets_up_the_views() -> void:
	var main = _main()
	if main == null:
		return
	main.progress.levels = {"height": 2}
	main.start_game()
	assert_eq(main.course_view.item_count(), main.session.course.size())
	assert_eq(main.slingshot.position, Vector2(0, -80), "anchor at world (0, launch_height = 5 m)")
	assert_almost_eq(main.slingshot.frame_height_px, 80.0, 0.001)
	assert_true(main.slingshot.enabled)
	assert_eq(main.projectile_view.position, Vector2(0, -98), "projectile waits at the anchor (-(5 + 0.75 * 1.5) * 16, task 205)")


func test_dragging_shows_the_preview_and_releasing_launches() -> void:
	var main = _main()
	if main == null:
		return
	main.start_game()
	var anchor: Vector2 = main.slingshot.global_position
	assert_true(main.slingshot.begin_drag(anchor))
	main.slingshot.update_drag(anchor + FULL_PULL_45)
	main.advance(1.0 / 60.0)
	assert_between(main.trajectory.points.size(), 1, 6, "guide_points = 6 dots at most")
	main.slingshot.release()
	assert_eq(main.state_name(), "FLIGHT", "the slingshot's launched signal starts the flight")
	assert_false(main.slingshot.enabled, "no second launch during a flight")
	assert_eq(main.trajectory.points.size(), 0, "preview cleared on launch")


func test_flight_moves_the_projectile_camera_and_hides_stars() -> void:
	var main = _main()
	if main == null:
		return
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	assert_eq(main.state_name(), "RESULTS")
	var sim = main.session.sim
	assert_almost_eq(main.projectile_view.position.x, sim.position.x * 16.0, 0.01)
	assert_gt(main.camera.position.x, 500.0, "the camera followed the projectile")
	var hidden := 0
	for s in main.course_view.sprites:
		if not s.visible:
			hidden += 1
	assert_eq(hidden, main.session.tracker.stars_collected, "collected stars disappear")


func test_next_run_rebuilds_the_course() -> void:
	var main = _main()
	if main == null:
		return
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	main.continue_to_shop()
	main.leave_shop()
	assert_eq(main.course_view.item_count(), main.session.course.size())
	assert_true(main.slingshot.enabled)
	for s in main.course_view.sprites:
		assert_true(s.visible, "a new course starts with every star visible")
		if not s.visible:
			return
