extends GutTest
# Checkpoint 36 (task 268c): with real frames, a late roguelike round has hills, the game plays a shot over them
# exactly like RunSession predicts, the alien comes to rest on them, and the ground is drawn along them.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_268c_save.json"
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



func test_hills_with_real_frames() -> void:
	var main = _main()
	await wait_process_frames(2)
	main.start_rogue(4242)
	main.rogue.perks.assign(["power", "power", "aero"])
	main.rogue.round_number = 15
	main.rogue.goal = {"type": "distance", "target": 30.0, "round": 15, "text": "Fly at least 30 m"}
	main._begin_aim()
	assert_almost_eq(main.session.sim.hills, Terrain.for_round(15), 0.0001)
	assert_eq(WorldView.terrain, main.session.sim)
	var s := RunSession.new(main.rogue.stats(), main.rogue.shot_seed())
	s.launch_from_pull(PULL)
	while not s.is_finished():
		s.step(1.0 / 60.0)
	main.launch_with_pull(PULL)
	for i in 240:
		if main.state_name() != "FLIGHT":
			break
		await wait_physics_frames(1)
	while main.state_name() == "FLIGHT":
		main.advance(1.0 / 60.0)
	var sim = main.session.sim
	assert_almost_eq(float(main.last_result["distance"]), s.sim.distance(), 0.01, "played like the prediction")
	assert_almost_eq(sim.position.y, sim.ground_height(sim.position.x), 0.001, "resting on the hills")
	await wait_process_frames(2)
	assert_eq(main.world_view.drawn_version, WorldView.terrain_version, "the ground is drawn along these hills")


func test_progress_log_records_milestone_36() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 35: complete"), "the earlier lines are kept")
	assert_true(text.contains("Milestone 36: complete"), "add the line 'Milestone 36: complete' to docs/PROGRESS.md")
