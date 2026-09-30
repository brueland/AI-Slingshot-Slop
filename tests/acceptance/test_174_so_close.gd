extends GutTest
# Task 174: a roguelike goal missed by a little (85% or closer) gets a "So close!" popup.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_174_save.json"
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


func _popups(main, text: String) -> int:
	var count := 0
	for child in main.popups.get_children():
		if child is FloatingText and child.text == text:
			count += 1
	return count


func test_so_close() -> void:
	var run = load("res://scripts/core/rogue_run.gd").new()
	run.start(7)
	run.goal = {"type": "distance", "target": 100.0, "round": 1, "text": "Fly at least 100 m"}
	var outcome: Dictionary = run.finish_shot({"distance": 90.0})
	assert_false(outcome["met"])
	assert_almost_eq(float(outcome.get("ratio", -1.0)), 0.9, 0.0001, "how close the shot came to its goal")
	run.goal = {"type": "distance", "target": 100.0, "round": 1, "text": "Fly at least 100 m"}
	outcome = run.finish_shot({"distance": 120.0})
	assert_eq(outcome.get("ratio"), 1.0, "the goal the shot was for, not the next one")
	var main = _main()
	main.start_game()
	assert_eq(main.feedback.celebrate({"goal_met": false, "goal_ratio": 0.9}), "So close!")
	assert_eq(_popups(main, "So close!"), 1)
	assert_eq(main.feedback.celebrate({"goal_met": false, "goal_ratio": 0.5}), "", "not close enough")
	assert_eq(main.feedback.celebrate({"goal_met": true, "goal_ratio": 1.0}), "Goal!")
	main.go_to_title()
	_rogue_at(main, 5, 2, 100000.0)
	_fly(main, PULL)
	assert_eq(_popups(main, "So close!"), 1, "a far miss is not close")
