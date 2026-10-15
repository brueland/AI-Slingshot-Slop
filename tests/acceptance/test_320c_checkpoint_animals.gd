extends GutTest
# Checkpoint 46 (task 320c): with real frames, a shot that runs into the meadow's animals plays exactly like
# RunSession predicts, and no tree locks a shot any more.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_320c_save.json"
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



func test_animals_with_real_frames() -> void:
	var main = _main()
	await wait_process_frames(2)
	main.progress.levels = {"power": 3}
	main.start_game()
	var pull := Vector2.ZERO
	var s: RunSession = null
	for angle in range(5, 60, 5):
		for strength in [1.0, 0.8, 0.6]:
			var p: Vector2 = Vector2(-cos(deg_to_rad(angle)), sin(deg_to_rad(angle))) * 120.0 * strength
			var t := RunSession.new(main.progress.stats(), main.progress.total_runs + 1)
			t.launch_from_pull(p)
			while not t.is_finished():
				t.step(1.0 / 60.0)
			if int(t.result()["animals"]) > 0:
				pull = p
				s = t
				break
		if s != null:
			break
	assert_not_null(s, "some shot runs into a sheep or a cow")
	if s == null:
		return
	assert_lt(s.elapsed, Balance.MAX_RUN_SECONDS, "and still ends on its own")
	main.launch_with_pull(pull)
	for i in 120:
		if main.state_name() != "FLIGHT":
			break
		await wait_physics_frames(1)
	while main.state_name() == "FLIGHT":
		main.advance(1.0 / 60.0)
	assert_almost_eq(float(main.last_result["distance"]), s.sim.distance(), 0.01, "played like the prediction")
	assert_eq(int(main.last_result["animals"]), int(s.result()["animals"]))


func test_progress_log_records_milestone_46() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 45: complete"), "the earlier lines are kept")
	assert_true(text.contains("Milestone 46: complete"), "add the line 'Milestone 46: complete' to docs/PROGRESS.md")
