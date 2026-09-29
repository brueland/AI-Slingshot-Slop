extends GutTest
# Task 073: in the classic game, buying Aim Guide (level 1+) unlocks the last-aim line; the slingshot keeps
# remembering the previous launch between runs.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_073_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func _main():
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	return main


func _fly(main) -> void:
	for i in 20000:
		if main.state_name() != "FLIGHT":
			return
		main.advance(1.0 / 60.0)


func test_description_mentions_the_aim_line() -> void:
	var d: Dictionary = load("res://scripts/core/upgrade_catalog.gd").get_def("guide")
	assert_true(str(d.get("description", "")).contains("last aim"), "Aim Guide's description mentions the last aim")


func test_locked_without_aim_guide() -> void:
	var main = _main()
	main.start_game()
	assert_false(main.slingshot.show_last_aim)


func test_unlocked_with_aim_guide_and_remembered_between_runs() -> void:
	var main = _main()
	main.progress.levels = {"guide": 1}
	main.start_game()
	assert_true(main.slingshot.show_last_aim, "Aim Guide 1 shows the last aim")
	var anchor: Vector2 = main.slingshot.global_position
	main.slingshot.begin_drag(anchor)
	main.slingshot.update_drag(anchor + Vector2(-70, 50))
	main.slingshot.release()
	_fly(main)
	main.continue_to_shop()
	main.leave_shop()
	assert_eq(main.slingshot.last_pull, Vector2(-70, 50), "the next shot shows where the last one was aimed")
	assert_eq(main.slingshot.aim_line_points().size(), 2)
