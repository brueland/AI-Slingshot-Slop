extends GutTest
# Task 266: springs, mud, the milestone flags and the best-distance flag stand on the hills, and the rocks, plants
# and cows move onto each new shot's hills.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_266_save.json"
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



func test_course_on_hills() -> void:
	var main = _main()
	main.start_rogue(5)
	main.rogue.round_number = 20
	main._begin_aim()
	var sim = main.session.sim
	assert_gt(sim.hills, 1.0)
	var checked := 0
	for i in main.session.course.size():
		var item: Dictionary = main.session.course[i]
		if item["type"] == "spring":
			var sprite = main.course_view.sprites[i]
			assert_almost_eq(sprite.position.y, WorldView.ground_point(item["x"]).y, 0.01, "a spring on the hill")
			checked += 1
	assert_gt(checked, 0)
	main.course_view.set_best_marker(400.0)
	assert_almost_eq(main.course_view.best_marker.position.y, WorldView.ground_point(400.0).y, 0.01)
	assert_almost_eq(main.course_view.flags[2].position.y, WorldView.ground_point(250.0).y, 0.01, "milestone flags too")
	await wait_process_frames(2)
	var off := 0.0
	for sprite in main.scenery.sprites:
		var x: float = WorldView.screen_to_world(sprite.position).x
		off = maxf(off, absf(sprite.position.y - WorldView.ground_point(x).y))
	assert_lt(off, 0.01, "every rock and plant is on the ground")
	assert_almost_eq(main.cows.cow_position(0).y, WorldView.ground_point(main.cows.xs[0]).y, 0.01)
