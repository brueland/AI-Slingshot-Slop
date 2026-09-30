extends GutTest
# Checkpoint 23 (task 190c): the flight stats work together with real frames: the air time grows during a real
# flight, and the results show it with the best air time.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_190c_save.json"
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


func test_flight_stats_with_real_frames() -> void:
	var main = _main()
	main.start_game()
	main.launch_with_pull(PULL)
	await wait_seconds(0.8)
	assert_gt(main.session.sim.air_time, 0.3, "the air time grows with real frames")
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	await wait_seconds(0.2)
	assert_eq(main.progress.best_air_time, float(main.last_result["air_time"]))
	assert_true(main.results_panel.air_label.text.ends_with("(best %.1f s)" % main.progress.best_air_time))
	assert_between(main.feedback.hop_start, 0.0, main.session.sim.air_time, "hops tracked")


func test_new_code_follows_the_conventions() -> void:
	var main_text := FileAccess.get_file_as_string("res://scripts/game/main.gd")
	assert_lt(main_text.split("\n").size(), 450, "main.gd stays under 450 lines")
	for path in ["res://scripts/core/flight_sim.gd", "res://scripts/game/feedback.gd"]:
		assert_false(FileAccess.get_file_as_string(path).contains("print("), path)


func test_progress_log_records_milestone_23() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 23: complete"), "add the line 'Milestone 23: complete' to docs/PROGRESS.md")
