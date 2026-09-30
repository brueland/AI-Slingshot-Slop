extends GutTest
# Task 149: the longest combo is remembered: Feedback.best_combo_run for the shot, Progress.best_combo (saved) overall.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_149_save.json"


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


func test_best_combo() -> void:
	var main = _main()
	main.start_game()
	main.launch_with_pull(Vector2(-84.852814, 84.852814))
	main.advance(1.0 / 60.0)
	for i in 4:
		main.feedback.add_combo()
	assert_eq(main.feedback.best_combo_run, 4)
	main.feedback.tick_combo(2.0)
	main.feedback.add_combo()
	assert_eq(main.feedback.best_combo_run, 4, "the best of the shot stays")
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	assert_gt(main.progress.best_combo, 3)
	var saved = JSON.parse_string(FileAccess.get_file_as_string(SAVE))
	assert_gt(int(saved["best_combo"]), 3, "saved")
	main.continue_to_shop()
	main.leave_shop()
	assert_eq(main.feedback.best_combo_run, 0, "a new shot starts over")
