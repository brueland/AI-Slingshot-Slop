extends GutTest
# Checkpoint 35 (task 260c): with real frames, the game plays bouncier shots exactly like RunSession predicts, a
# balloon touching the big alien's head pops, and a UFO's beam lifts the alien.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_260c_save.json"
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



func test_bouncier_flights_with_real_frames() -> void:
	var main = _main()
	await wait_process_frames(2)
	main.start_game()
	var s := RunSession.new(main.progress.stats(), main.progress.total_runs + 1)
	s.launch_from_pull(PULL)
	while not s.is_finished():
		s.step(1.0 / 60.0)
	main.launch_with_pull(PULL)
	for i in 300:
		if main.state_name() != "FLIGHT":
			break
		await wait_physics_frames(1)
	while main.state_name() == "FLIGHT":
		main.advance(1.0 / 60.0)
	assert_eq(int(main.last_result["bounces"]), s.sim.bounce_count, "the game bounces like the prediction")
	assert_almost_eq(float(main.last_result["distance"]), s.sim.distance(), 0.01)
	assert_gt(s.sim.bounce_count, 1, "a plain shot bounces a few times")


func test_beam_lift_in_a_session() -> void:
	var s := RunSession.new(RogueSizes.apply(PlayerStats.new(), "big"), 5)
	s.launch_from_pull(PULL)
	s.sim.position = Vector2(420.0, 8.0)
	s.sim.velocity = Vector2(0.5, -1.0)
	var vy: float = s.sim.velocity.y
	for i in 6:
		s.step(1.0 / 60.0)
	assert_gt(s.sim.velocity.y, vy - 1.0, "the beam slows the fall (without it: about -2.5 m/s)")


func test_progress_log_records_milestone_35() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 34: complete"), "the earlier lines are kept")
	assert_true(text.contains("Milestone 35: complete"), "add the line 'Milestone 35: complete' to docs/PROGRESS.md")
