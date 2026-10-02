extends GutTest
# Task 265: the ground is drawn along the current shot's hills (dirt and grass follow them; the distance markers sit
# on them), and main.gd makes every new shot's sim the ground everything is drawn on.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_265_save.json"
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



func test_hills_drawn() -> void:
	var wv = load("res://scripts/game/world_view.gd")
	var sim := FlightSim.new()
	sim.hills = 2.0
	var version: int = wv.terrain_version
	wv.use_terrain(sim)
	assert_eq(wv.terrain, sim)
	assert_eq(wv.terrain_version, version + 1, "a new terrain")
	assert_almost_eq(wv.ground_height_at(321.0), sim.terrain_height(321.0), 0.0001)
	assert_eq(wv.ground_point(321.0), WorldView.world_to_screen(Vector2(321.0, sim.terrain_height(321.0))))
	wv.use_terrain(null)
	assert_eq(wv.ground_height_at(321.0), 0.0, "null is flat")
	var main = _main()
	main.start_rogue(5)
	main.rogue.round_number = 15
	main._begin_aim()
	assert_eq(wv.terrain, main.session.sim, "every shot's sim is the ground")
	assert_eq(wv.terrain_owner, main.world_view.get_instance_id())
	assert_gt(main.session.sim.hills, 1.0)
	main.camera.snap_to(WorldView.world_to_screen(Vector2(200.0, 0.0)))
	await wait_process_frames(3)
	assert_eq(main.world_view.drawn_version, wv.terrain_version, "redrawn for the new hills")
	remove_child(main)
	assert_null(wv.terrain, "flat again once the game leaves (other scenes and tests see flat ground)")
	add_child(main)
