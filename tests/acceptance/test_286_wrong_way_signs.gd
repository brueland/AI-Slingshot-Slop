extends GutTest
# Task 286: behind the slingshot red WRONG WAY signs point back to the course, the giant brick wall is drawn at
# Balance.WALL_X, and the ground goes on to behind the wall.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_286_save.json"
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



func test_wrong_way_signs() -> void:
	var main = _main()
	var signs = null
	for child in main.get_children():
		if child.get_script() != null and child.get_script().resource_path == "res://scripts/game/wrong_way.gd":
			signs = child
	assert_not_null(signs, "WorldBuilder adds the signs and the wall")
	assert_eq(signs.SIGNS_M, [-25.0, -55.0, -85.0])
	assert_gt(signs.get_index(), main.world_view.get_index(), "in front of the ground")
	assert_eq(WorldView.span_around(0.0).x, -175.0, "the ground reaches behind the wall")
	main.start_game()
	main.camera.snap_to(WorldView.world_to_screen(Vector2(-110.0, 10.0)))
	await wait_process_frames(3)
	assert_lte(main.world_view.drawn_from_m, -140.0)
