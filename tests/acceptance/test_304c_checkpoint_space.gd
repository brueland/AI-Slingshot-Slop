extends GutTest
# Checkpoint 43 (task 304c): with real frames, a fully upgraded shot straight up flies into the star cloud, collects a
# ton of stars that count in the result and the HUD, exactly like RunSession predicts.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_304c_save.json"
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



const UP := Vector2(-20.837781, 118.176930)


func test_space_with_real_frames() -> void:
	var main = _main()
	await wait_process_frames(2)
	var levels := {}
	for id in UpgradeCatalog.ids():
		levels[id] = 25
	main.progress.levels = levels
	main.start_game()
	var s := RunSession.new(main.progress.stats(), main.progress.total_runs + 1)
	s.launch_from_pull(UP)
	while not s.is_finished():
		s.step(1.0 / 60.0)
	assert_gt(s.sim.max_height, 650.0, "a maxed shot straight up gets into the cloud")
	assert_gt(s.cloud.count, 10, "and grabs a ton of stars")
	main.launch_with_pull(UP)
	for i in 120:
		await wait_physics_frames(1)
	while main.state_name() == "FLIGHT" and main.session.cloud.count == 0:
		main.advance(1.0 / 60.0)
	await wait_process_frames(3)
	assert_true(main.hud.stars_label.text.ends_with(str(main.session.stars_collected())), "the HUD counts the cloud's stars")
	while main.state_name() == "FLIGHT":
		main.advance(1.0 / 60.0)
	assert_eq(int(main.last_result["stars"]), s.stars_collected(), "played like the prediction")
	assert_eq(int(main.last_result["cloud_stars"]), s.cloud.count)


func test_progress_log_records_milestone_43() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 42: complete"), "the earlier lines are kept")
	assert_true(text.contains("Milestone 43: complete"), "add the line 'Milestone 43: complete' to docs/PROGRESS.md")
