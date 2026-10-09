extends GutTest
# Checkpoint 45 (task 316c): with real frames, wearing the Propeller Cap a classic shot flies exactly like RunSession
# predicts with the hat's boost, a roguelike run keeps the hat, and the new sheep and cows draw in the meadow.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_316c_save.json"
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



func test_hats_and_animals_with_real_frames() -> void:
	var main = _main()
	await wait_process_frames(2)
	main.progress.best_distance = 150.0
	main.progress.hat = "propeller"
	main.start_game()
	assert_almost_eq(main.session.stats.max_speed, PlayerStats.from_levels({}).max_speed * 1.03, 0.0001, "the propeller's boost")
	var s := RunSession.new(main.progress.stats(), main.progress.total_runs + 1)
	s.launch_from_pull(PULL)
	while not s.is_finished():
		s.step(1.0 / 60.0)
	main.launch_with_pull(PULL)
	for i in 120:
		if main.state_name() != "FLIGHT":
			break
		await wait_physics_frames(1)
	while main.state_name() == "FLIGHT":
		main.advance(1.0 / 60.0)
	assert_almost_eq(float(main.last_result["distance"]), s.sim.distance(), 0.01, "played like the prediction")
	main.go_to_title()
	main.start_rogue(77)
	assert_eq(main.rogue.hat, "propeller", "the roguelike keeps the hat")
	main.camera.snap_to(WorldView.world_to_screen(Vector2(main.critters.xs[0], 0.0)))
	await wait_process_frames(3)
	main.camera.snap_to(WorldView.world_to_screen(Vector2(main.cows.xs[0], 0.0)))
	await wait_process_frames(3)
	assert_eq(main.critters.sheep_texture(1).get_size(), Vector2(100.0, 68.0), "the sheep sprites")
	assert_eq(main.cows.cow_texture(1).get_size(), Vector2(156.0, 92.0), "the cow sprites")


func test_progress_log_records_milestone_45() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 44: complete"), "the earlier lines are kept")
	assert_true(text.contains("Milestone 45: complete"), "add the line 'Milestone 45: complete' to docs/PROGRESS.md")
