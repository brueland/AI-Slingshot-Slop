extends GutTest
# Task 165: the game counts every balloon popped (Progress.balloons_total) and sheep woken (Progress.sheep_woken).

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_165_save.json"


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


## A classic shot where two balloons count as popped and three sheep as woken, flown to the end.
func _busy_shot(main) -> void:
	main.launch_with_pull(Vector2(-84.852814, 84.852814))
	main.advance(1.0 / 60.0)
	main.session.balloons.popped_count = 2
	main.feedback.sheep_woken_run = 3
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)


func test_records() -> void:
	var main = _main()
	main.start_game()
	_busy_shot(main)
	assert_eq(main.state_name(), "RESULTS")
	assert_eq(main.progress.balloons_total, int(main.last_result["balloons"]), "every popped balloon counts")
	assert_gte(main.progress.balloons_total, 2)
	assert_eq(main.progress.sheep_woken, main.feedback.sheep_woken_run, "every woken sheep counts")
	assert_gte(main.progress.sheep_woken, 3)
	var saved = JSON.parse_string(FileAccess.get_file_as_string(SAVE))
	assert_eq(int(saved["balloons_total"]), main.progress.balloons_total, "saved")
	assert_eq(int(saved["sheep_woken"]), main.progress.sheep_woken, "saved")
	main.continue_to_shop()
	main.leave_shop()
	assert_eq(main.feedback.sheep_woken_run, 0, "a new shot starts over")


func test_loading() -> void:
	var p = load("res://scripts/core/progress.gd").from_dict({"balloons_total": 9, "sheep_woken": -4})
	assert_eq(p.balloons_total, 9)
	assert_eq(p.sheep_woken, 0, "never negative")
