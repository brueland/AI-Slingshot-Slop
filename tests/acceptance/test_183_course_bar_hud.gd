extends GutTest
# Task 183: the HUD shows the course bar at the bottom center; it follows the flight and marks the best distance.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_183_save.json"
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


func test_course_bar_on_the_hud() -> void:
	var main = _main()
	main.progress.best_distance = 300.0
	main.start_game()
	var bar = main.hud.course_bar
	assert_almost_eq(bar.best_fraction, 0.3, 0.0001, "the best distance is marked")
	main.launch_with_pull(PULL)
	for i in 120:
		main.advance(1.0 / 60.0)
	assert_almost_eq(bar.fraction, CourseBar.fraction_for(main.session.sim.distance()), 0.0001, "follows the flight")
	assert_gt(bar.fraction, 0.0)
	await wait_process_frames(3)
	var screen: Rect2 = main.get_viewport().get_visible_rect()
	assert_true(screen.encloses(bar.get_global_rect()), "on screen")
	assert_lt(absf(bar.get_global_rect().get_center().x - screen.get_center().x), 1.0, "centered")
	assert_gt(bar.get_global_rect().position.y, screen.size.y - 40.0, "at the bottom")
	assert_false(bar.get_global_rect().intersects(main.hud.hint_label.get_global_rect()), "clear of the hint line")
