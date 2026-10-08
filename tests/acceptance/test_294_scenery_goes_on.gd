extends GutTest
# Task 294: the rocks, bushes and cacti go on forever: their 8000 m layout repeats, and each sprite moves to its copy
# nearest the view (on the ground) once the view has moved 100 m.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_294_save.json"
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



func _near(main, x_m: float) -> int:
	var count := 0
	for sprite in main.scenery.sprites:
		var x: float = WorldView.screen_to_world(sprite.position).x
		if absf(x - x_m) <= 60.0:
			count += 1
			assert_almost_eq(sprite.position.y, WorldView.ground_point(x).y, 0.01, "on the ground")
	return count


func test_scenery_goes_on() -> void:
	var main = _main()
	main.start_game()
	await wait_process_frames(2)
	assert_gt(_near(main, 30.0), 0, "rocks and plants by the slingshot")
	assert_eq(main.scenery.base_xs.size(), main.scenery.sprites.size())
	main.camera.snap_to(WorldView.world_to_screen(Vector2(8300.0, 0.0)))
	await wait_process_frames(3)
	assert_gt(_near(main, 8300.0), 0, "and 8300 m out")
	main.camera.snap_to(WorldView.world_to_screen(Vector2(20500.0, 0.0)))
	await wait_process_frames(3)
	assert_gt(_near(main, 20500.0), 0, "and 20 km out")
	main.camera.snap_to(WorldView.world_to_screen(Vector2(0.0, 0.0)))
	await wait_process_frames(3)
	assert_gt(_near(main, 30.0), 0, "back home")
