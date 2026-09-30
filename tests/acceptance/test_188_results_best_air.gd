extends GutTest
# Task 188: the results' air time line also shows the best air time: "Air time: 2.3 s   (best 4.0 s)".

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_188_save.json"
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


func test_results_best_air_time() -> void:
	var main = _main()
	main.start_game()
	_fly(main, PULL)
	var panel = main.results_panel
	var expected := "Air time: %.1f s   (best %.1f s)" % [float(main.last_result["air_time"]), main.progress.best_air_time]
	assert_eq(panel.air_label.text, expected)
	panel.show_result(main.last_result.merged({"air_time": 2.26, "best_air_time": 4.0}, true), false)
	assert_eq(panel.air_label.text, "Air time: 2.3 s   (best 4.0 s)")
	panel.show_result(main.last_result.merged({"air_time": 2.26, "best_air_time": 0.0}, true), false)
	assert_eq(panel.air_label.text, "Air time: 2.3 s", "no best yet")
