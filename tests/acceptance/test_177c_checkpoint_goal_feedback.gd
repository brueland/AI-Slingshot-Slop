extends GutTest
# Checkpoint 21 (task 177c): the roguelike goal feedback works together with real frames: the live readout during a
# flight, the perk panel after a met goal, and the longest shot when the run ends.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_177c_save.json"
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


## A roguelike run at `round_number` with a distance goal of `target` m, ready to shoot.
func _rogue_at(main, run_seed: int, round_number: int, target: float = 10.0) -> void:
	main.start_rogue(run_seed)
	main.rogue.round_number = round_number
	main.rogue.goal = {"type": "distance", "target": target, "round": round_number, "text": "Fly at least %d m" % int(target)}
	main.ui_layer.refresh(main)


func test_goal_feedback_with_real_frames() -> void:
	var main = _main()
	_rogue_at(main, 5, 2)
	main.launch_with_pull(PULL)
	await wait_seconds(0.5)
	assert_true(main.hud.goal_progress_label.visible, "the live readout runs with real frames")
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	await wait_seconds(0.2)
	assert_true(main.ui_layer.rogue_panel.visible)
	assert_false(main.ui_layer.rogue_panel.close_label.visible, "the goal was met")
	main.go_to_title()
	_rogue_at(main, 9, 1, 1000.0)
	main.rogue.lives = 1
	_fly(main, PULL)
	await wait_seconds(0.3)
	assert_true(main.ui_layer.rogue_over_panel.visible)
	assert_eq(main.ui_layer.rogue_over_panel.longest_label.text, "Longest shot: %d m" % int(main.rogue.best_shot))
	assert_false(main.hud.visible)


func test_new_code_follows_the_conventions() -> void:
	var main_text := FileAccess.get_file_as_string("res://scripts/game/main.gd")
	assert_lt(main_text.split("\n").size(), 450, "main.gd stays under 450 lines")
	for path in ["res://scripts/core/rogue_goals.gd", "res://scripts/core/rogue_run.gd"]:
		assert_false(FileAccess.get_file_as_string(path).contains("print("), path)


func test_progress_log_records_milestone_21() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 21: complete"), "add the line 'Milestone 21: complete' to docs/PROGRESS.md")
