extends GutTest
# Task 186: the results show "Air time: 3.4 s" right under the bounces.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_186_save.json"
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


func test_results_air_time() -> void:
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
	assert_true(panel.visible)
	assert_true(panel.air_label.text.begins_with("Air time: %.1f s" % float(main.last_result["air_time"])))
	assert_eq(panel.air_label.get_index(), panel.bounces_label.get_index() + 1, "right under the bounces")
	await wait_process_frames(3)
	assert_true(main.get_viewport().get_visible_rect().encloses(panel.get_global_rect()), "a busy first run still fits on screen")
	panel.show_result(main.last_result.merged({"air_time": 2.26, "best_air_time": 0.0}, true), false)
	assert_eq(panel.air_label.text, "Air time: 2.3 s")
