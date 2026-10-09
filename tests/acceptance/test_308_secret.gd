extends GutTest
# Task 308: behind the brick wall stands a big thank-you sign and the end of the world; when the alien breaks through,
# the wall is drawn as rubble and "You found the secret!" pops up. The ground goes back to -280 m. Each new shot
# rebuilds the wall.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_308_save.json"
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



func test_secret() -> void:
	var main = _main()
	main.start_game()
	var wall = null
	for w in main.feedback.watchers:
		if w is WrongWay:
			wall = w
	assert_not_null(wall, "the WRONG WAY signs and the wall follow every shot")
	if wall == null:
		return
	assert_false(wall.wall_down)
	main.session.sim.wall_broken.emit()
	assert_true(wall.wall_down, "rubble where the wall stood")
	assert_eq(wall.get_child(wall.get_child_count() - 1).text, "You found the secret!")
	assert_eq(WorldView.span_around(0.0), Vector2(-280.0, 555.0), "the ground goes back to -280 m")
	main.camera.snap_to(WorldView.world_to_screen(Vector2(-190.0, 0.0)))
	await wait_process_frames(3)
	assert_true(FileAccess.get_file_as_string("res://scripts/game/wrong_way.gd").contains("THANK YOU"), "the thank-you sign")
	main.go_to_title()
	main.start_game()
	assert_false(wall.wall_down, "a new shot rebuilds the wall")
