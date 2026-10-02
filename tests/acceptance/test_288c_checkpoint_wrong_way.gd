extends GutTest
# Checkpoint 41 (task 288c): with real frames, a shot fired hard backwards passes the WRONG WAY signs, bonks off the
# brick wall and comes back toward the course.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_288c_save.json"
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



func test_wrong_way_with_real_frames() -> void:
	var main = _main()
	await wait_process_frames(2)
	main.progress.levels = {"power": 6}
	main.start_game()
	watch_signals(main.feedback)
	main.launch_with_pull(Vector2(110.0, 40.0))
	var hits := [0]
	main.session.sim.wall_hit.connect(func(): hits[0] += 1)
	for i in 600:
		if main.state_name() != "FLIGHT":
			break
		await wait_physics_frames(1)
	while main.state_name() == "FLIGHT":
		main.advance(1.0 / 60.0)
	assert_gt(hits[0], 0, "it reached the wall")
	assert_gte(main.session.sim.position.x, -120.0, "and never went through it")


func test_progress_log_records_milestone_41() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 40: complete"), "the earlier lines are kept")
	assert_true(text.contains("Milestone 41: complete"), "add the line 'Milestone 41: complete' to docs/PROGRESS.md")
