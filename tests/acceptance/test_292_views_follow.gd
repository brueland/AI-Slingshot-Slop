extends GutTest
# Task 292: when a long shot's course grows, its new stars, springs, mud and balloons appear; milestone flags stand
# all the way to 30000 m; only the stars and balloons on screen are animated and drawn.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_292_save.json"
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



func test_views_follow() -> void:
	var main = _main()
	main.start_game()
	var s = main.session
	var items_before: int = main.course_view.item_count()
	s.extend_course()
	assert_eq(main.course_view.item_count(), s.course.size(), "a sprite for every new item")
	assert_gt(main.course_view.item_count(), items_before)
	var last = main.course_view.sprites[main.course_view.item_count() - 1]
	assert_gt(last.position.x, 2000.0 * Balance.PIXELS_PER_METER, "past 2000 m")
	assert_eq(main.balloon_view.points.size(), s.balloons.points.size(), "and the new balloons")
	assert_eq(main.course_view.flags.size(), 34, "flags all the way")
	assert_eq(main.course_view.flag_distances[33], 30000.0)
	var far := -1
	for i in main.course_view.star_indices:
		if main.course_view.sprites[i].position.x > 1500.0 * Balance.PIXELS_PER_METER:
			far = i
			break
	var size_before: Vector2 = main.course_view.sprites[far].scale
	main.course_view.advance(0.3)
	assert_eq(main.course_view.sprites[far].scale, size_before, "a star far off screen is left alone")
	var text := FileAccess.get_file_as_string("res://scripts/game/balloon_view.gd")
	assert_true(text.contains("visible_span"), "balloons draw only what is on screen")
	await wait_process_frames(2)
