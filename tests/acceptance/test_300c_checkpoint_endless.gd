extends GutTest
# Checkpoint 42 (task 300c): with real frames, a fully upgraded low classic shot flies past 2000 m exactly like
# RunSession predicts, its course grows with sprites for the new items, the ground ahead has springs, mud and
# stars, and the HUD box keeps its width all the way.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_300c_save.json"
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



## A low shot (15 degrees up): under the meteors, and over most trees (task 305).
const LOW := Vector2(-115.911095, 31.058285)


func test_endless_with_real_frames() -> void:
	var main = _main()
	await wait_process_frames(2)
	var levels := {}
	for id in UpgradeCatalog.ids():
		levels[id] = 25
	main.progress.levels = levels
	main.start_game()
	var s := RunSession.new(main.progress.stats(), main.progress.total_runs + 1)
	s.launch_from_pull(LOW)
	while not s.is_finished():
		s.step(1.0 / 60.0)
	assert_gt(s.sim.distance(), 2200.0, "a maxed shot goes past the first course (trees slow it a little)")
	main.launch_with_pull(LOW)
	var width: float = main.hud.distance_label.get_parent().size.x
	for i in 120:
		await wait_physics_frames(1)
	while main.state_name() == "FLIGHT" and main.session.sim.position.x < 2200.0:
		main.advance(1.0 / 60.0)
	await wait_process_frames(3)
	assert_eq(main.hud.distance_label.get_parent().size.x, width, "the HUD box kept its width")
	assert_gt(main.session.course_end, 2000.0, "the course grew")
	assert_eq(main.course_view.item_count(), main.session.course.size(), "with sprites for the new items")
	var x: float = main.session.sim.position.x
	var ahead := 0
	for item in main.session.course:
		if float(item["x"]) > x and float(item["x"]) < x + 300.0:
			ahead += 1
	assert_gt(ahead, 3, "springs, mud and stars ahead")
	while main.state_name() == "FLIGHT":
		main.advance(1.0 / 60.0)
	assert_almost_eq(float(main.last_result["distance"]), s.sim.distance(), 0.01, "played like the prediction")


func test_progress_log_records_milestone_42() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 41: complete"), "the earlier lines are kept")
	assert_true(text.contains("Milestone 42: complete"), "add the line 'Milestone 42: complete' to docs/PROGRESS.md")
