extends GutTest
# Checkpoint 3 (task 030c): the main scene plays a whole run with real frames (so every _draw() and
# _physics_process() runs), the next run is set up correctly, and the code follows the conventions.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_030c_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)
const GAME_SCRIPTS := {
	"res://scripts/game/world_view.gd": "WorldView",
	"res://scripts/game/projectile_view.gd": "ProjectileView",
	"res://scripts/game/slingshot.gd": "Slingshot",
	"res://scripts/game/trajectory_preview.gd": "TrajectoryPreview",
	"res://scripts/game/camera_rig.gd": "CameraRig",
	"res://scripts/game/course_view.gd": "CourseView",
}

var _states: Array = []


func _main():
	if not ResourceLoader.exists(SCENE):
		fail_test("missing " + SCENE)
		return null
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	_states.clear()
	main.state_changed.connect(func(s): _states.append(s))
	return main


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func test_a_run_with_real_frames() -> void:
	var main = _main()
	if main == null:
		return
	main.start_game()
	await wait_process_frames(3)
	var anchor: Vector2 = main.slingshot.global_position
	main.slingshot.begin_drag(anchor)
	main.slingshot.update_drag(anchor + FULL_PULL_45)
	await wait_physics_frames(3)
	assert_gt(main.trajectory.points.size(), 0, "_physics_process -> advance() updates the preview while dragging")
	main.slingshot.release()
	assert_eq(main.state_name(), "FLIGHT")
	await wait_physics_frames(20)
	assert_gt(main.session.sim.distance(), 1.0, "_physics_process -> advance() moves the flight on its own")
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	await wait_process_frames(3)
	assert_eq(main.state_name(), "RESULTS")
	assert_eq(_states, [1, 2, 3], "AIM -> FLIGHT -> RESULTS")


func test_second_run_is_wired_to_the_new_session() -> void:
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
	assert_eq(main.state_name(), "AIM")
	assert_eq(main.session.course, RunSession.new(main.progress.stats(), 2).course, "seed 2, on the hills of the best distance")
	assert_eq(main.course_view.item_count(), main.session.course.size())
	main.session.tracker.star_collected.emit(0)
	assert_false(main.course_view.sprites[0].visible, "the new run's tracker hides stars in the new course")


func test_game_scripts_follow_the_conventions() -> void:
	for path in GAME_SCRIPTS:
		if not ResourceLoader.exists(path):
			fail_test("missing file " + path)
			continue
		var text := FileAccess.get_file_as_string(path)
		assert_true(text.contains("class_name " + GAME_SCRIPTS[path]), "%s must declare class_name %s" % [path, GAME_SCRIPTS[path]])
		assert_lt(text.split("\n").size(), 300, path + " must stay under 300 lines")
		assert_false(text.contains("print("), path + " must not print")
	var main_text := FileAccess.get_file_as_string("res://scripts/game/main.gd")
	assert_lt(main_text.split("\n").size(), 450, "main.gd must stay under 450 lines")
	assert_false(main_text.contains("print("), "main.gd must not print")


func test_main_tscn_is_the_only_scene() -> void:
	var scenes := []
	_collect("res://scenes", scenes)
	_collect("res://scripts", scenes)
	assert_eq(scenes, ["res://scenes/main.tscn"], "build nodes in code; no other .tscn files")


func test_progress_log_records_milestone_3() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 3: complete"),
		"add the line 'Milestone 3: complete' to docs/PROGRESS.md")


func _collect(dir_path: String, out: Array) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return
	for f in dir.get_files():
		if f.ends_with(".tscn"):
			out.append(dir_path + "/" + f)
	for d in dir.get_directories():
		_collect(dir_path + "/" + d, out)
