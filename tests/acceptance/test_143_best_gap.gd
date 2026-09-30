extends GutTest
# Task 143: the results say how the run compares to the best: "New best by 12 m!" or "23 m short of your best (140 m)".

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_143_save.json"


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


func _main_in_flight():
	var main = _main()
	main.start_game()
	main.launch_with_pull(Vector2(-84.852814, 84.852814))
	main.advance(1.0 / 60.0)
	return main


func _fly(main, pull: Vector2) -> void:
	main.launch_with_pull(pull)
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)


func test_best_gap() -> void:
	var main = _main()
	main.start_game()
	_fly(main, Vector2(-84.852814, 84.852814))
	var gap = main.results_panel.get("gap_label")
	assert_true(gap is Label, "results_panel.gap_label")
	if not gap is Label:
		return
	assert_false(gap.visible, "nothing to compare on the first run")
	var best: float = main.progress.best_distance
	main.continue_to_shop()
	main.leave_shop()
	_fly(main, Vector2(-40, 30))
	var short := roundi(best - float(main.last_result["distance"]))
	assert_true(gap.visible)
	assert_eq(gap.text, "%d m short of your best (%d m)" % [short, roundi(best)])
	main.continue_to_shop()
	main.progress.levels = {"power": 3}
	main.leave_shop()
	_fly(main, Vector2(-84.852814, 84.852814))
	assert_true(main.last_result["new_best"])
	assert_eq(gap.text, "New best by %d m!" % roundi(float(main.last_result["distance"]) - best))
