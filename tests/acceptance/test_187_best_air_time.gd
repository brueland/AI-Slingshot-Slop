extends GutTest
# Task 187: the longest air time of any classic shot is remembered (Progress.best_air_time, saved).

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_187_save.json"
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


func test_best_air_time() -> void:
	var main = _main()
	main.start_game()
	_fly(main, PULL)
	var first: float = main.last_result["air_time"]
	assert_eq(main.progress.best_air_time, first)
	assert_eq(main.last_result.get("best_air_time"), first, "the result has the best too")
	main.continue_to_shop()
	main.leave_shop()
	_fly(main, Vector2(-12, 0))
	assert_lt(float(main.last_result["air_time"]), first, "a weak shot")
	assert_eq(main.progress.best_air_time, first, "the best stays")
	var saved = JSON.parse_string(FileAccess.get_file_as_string(SAVE))
	assert_almost_eq(float(saved["best_air_time"]), first, 0.0001, "saved")
	var p = load("res://scripts/core/progress.gd").from_dict({"best_air_time": -3.0})
	assert_eq(p.best_air_time, 0.0, "never negative")
