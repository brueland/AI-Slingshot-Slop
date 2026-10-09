extends GutTest
# Task 303: the meteors, space stations and star cloud are drawn (only what is on screen, high up), with "Whoosh!"
# for a smashed meteor and "Boing!" for a station bounce.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_303_save.json"
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



func test_space_view() -> void:
	var main = _main()
	main.start_game()
	var watchers = main.feedback.get("watchers")
	assert_true(watchers is Array, "feedback.watchers")
	if not watchers is Array or watchers.is_empty():
		return
	var view = watchers[0]
	assert_eq(view.get_script().resource_path, "res://scripts/game/space_things_view.gd", "the space view follows every shot")
	assert_eq(view.get_parent(), main, "in the world")
	assert_eq(view.shot, main.session, "watching the shot")
	var before: int = view.get_child_count()
	main.session.space.meteor_hit.emit(0)
	assert_eq(view.get_child_count(), before + 1, "a popup")
	assert_eq(view.get_child(view.get_child_count() - 1).text, "Whoosh!")
	main.session.space.station_hit.emit(0)
	assert_eq(view.get_child(view.get_child_count() - 1).text, "Boing!")
	main.camera.snap_to(WorldView.world_to_screen(main.session.space.stations[0]))
	await wait_process_frames(3)
	main.camera.snap_to(WorldView.world_to_screen(Vector2(300.0, 700.0)))
	await wait_process_frames(3)
	var text := FileAccess.get_file_as_string("res://scripts/game/space_things_view.gd")
	assert_true(text.contains("canvas_item_add_triangle_array"), "the cloud's stars are one mesh")
	main.start_game()
	assert_eq(view.shot, main.session, "and every new shot")
