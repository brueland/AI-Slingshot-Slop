extends GutTest
# Task 199: the results show the shot's star rating right under the title.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_199_save.json"
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


func test_results_stars() -> void:
	var main = _main()
	main.start_game()
	main.launch_with_pull(PULL)
	main.advance(1.0 / 60.0)
	main.session.balloons.popped_count = 2
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	var panel = main.results_panel
	assert_eq(panel.rating.get_index(), panel.title_label.get_index() + 1, "right under the title")
	assert_eq(panel.rating.rating, 3, "the first shot is a new best")
	await wait_process_frames(3)
	assert_true(main.get_viewport().get_visible_rect().encloses(panel.get_global_rect()), "a busy first run still fits on screen")
	main.continue_to_shop()
	main.leave_shop()
	_fly(main, Vector2(-12, 0))
	assert_eq(panel.rating.rating, 1, "a weak shot")
