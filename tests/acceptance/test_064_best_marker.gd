extends GutTest
# Task 064: a gold flag with a "Best: N m" label stands at the player's best distance in the world, so every
# shot has a target to beat.

const PATH := "res://scripts/game/course_view.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_064_save.json"


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func test_set_best_marker() -> void:
	var cv = load(PATH).new()
	add_child_autofree(cv)
	assert_true(cv.get("best_marker") is Sprite2D, "course_view.best_marker")
	assert_true(cv.get("best_label") is Label, "course_view.best_label")
	if not cv.get("best_marker") is Sprite2D or not cv.get("best_label") is Label:
		return
	assert_false(cv.best_marker.visible, "hidden until there is a best distance")
	cv.set_best_marker(123.4)
	assert_true(cv.best_marker.visible)
	assert_almost_eq(cv.best_marker.position.x, 123.4 * 16.0, 0.01)
	assert_almost_eq(cv.best_marker.position.y, 0.0, 0.001)
	assert_eq(cv.best_label.text, "Best: 123 m")
	assert_eq(cv.best_marker.texture.resource_path, "res://assets/sprites/flag.png")
	cv.set_best_marker(0.0)
	assert_false(cv.best_marker.visible)
	cv.build([{"type": "star", "x": 40.0, "y": 5.0}])
	cv.set_best_marker(50.0)
	cv.build([])
	assert_true(is_instance_valid(cv.best_marker) and cv.best_marker.visible, "rebuilding the course keeps it")


func test_main_places_the_best_marker() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	main.start_game()
	assert_false(main.course_view.best_marker.visible, "no best yet")
	main.go_to_title()
	main.progress.best_distance = 80.0
	main.start_game()
	assert_true(main.course_view.best_marker.visible)
	assert_almost_eq(main.course_view.best_marker.position.x, 1280.0, 0.01)
	await wait_process_frames(2)
