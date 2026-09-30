extends GutTest
# Task 176: a roguelike run remembers its longest shot (RogueRun.best_shot); the run-over screen shows it.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_176_save.json"
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


func test_longest_shot() -> void:
	var run = load("res://scripts/core/rogue_run.gd").new()
	run.start(3)
	run.finish_shot({"distance": 40.0})
	run.finish_shot({"distance": 25.0})
	assert_eq(run.best_shot, 40.0)
	run.start(4)
	assert_eq(run.best_shot, 0.0, "a new run starts over")
	var main = _main()
	_rogue_at(main, 5, 1, 100000.0)
	main.rogue.lives = 1
	_fly(main, PULL)
	var panel = main.ui_layer.rogue_over_panel
	assert_true(panel.visible)
	assert_eq(main.rogue.best_shot, float(main.last_result["distance"]))
	assert_gt(main.rogue.best_shot, 5.0)
	assert_eq(panel.longest_label.text, "Longest shot: %d m" % int(main.last_result["distance"]))
	assert_eq(panel.longest_label.get_index(), panel.best_label.get_index() + 1, "right under the best")
	await wait_process_frames(3)
	assert_true(main.get_viewport().get_visible_rect().encloses(panel.get_global_rect()), "the panel still fits on screen")
