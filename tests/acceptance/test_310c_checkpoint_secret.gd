extends GutTest
# Checkpoint 44 (task 310c): with real frames, a strong shot fired hard backwards breaks through the brick wall into
# the secret (the thank-you sign), finds it for good and earns Wall Breaker, exactly like RunSession predicts; and a
# tree stands in the meadow.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_310c_save.json"
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



const BACK := Vector2(118.176926, 20.837782)


func test_secret_with_real_frames() -> void:
	var main = _main()
	await wait_process_frames(2)
	main.progress.levels = {"power": 8, "aero": 5}
	main.start_game()
	assert_gt(main.session.trees.xs.size(), 5, "trees in the meadow")
	var s := RunSession.new(main.progress.stats(), main.progress.total_runs + 1)
	s.launch_from_pull(BACK)
	while not s.is_finished():
		s.step(1.0 / 60.0)
	assert_true(s.sim.wall_down, "a strong shot backwards breaks the wall")
	main.launch_with_pull(BACK)
	for i in 120:
		if main.state_name() != "FLIGHT":
			break
		await wait_physics_frames(1)
	while main.state_name() == "FLIGHT":
		main.advance(1.0 / 60.0)
	assert_true(main.session.sim.wall_down, "through the wall")
	assert_almost_eq(main.session.sim.position.x, s.sim.position.x, 0.01, "played like the prediction")
	assert_true(main.progress.found.has("secret_wall"), "the secret is found for good")
	assert_true(main.progress.achievements.has("wall_breaker"), "Wall Breaker")


func test_progress_log_records_milestone_44() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 43: complete"), "the earlier lines are kept")
	assert_true(text.contains("Milestone 44: complete"), "add the line 'Milestone 44: complete' to docs/PROGRESS.md")
