extends GutTest
# Task 160: the total of roguelike rounds cleared (all runs) is saved and shown on the Stats screen.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_160_save.json"


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


## A roguelike run at `round_number` with an easy goal (fly 10 m), ready to shoot.
func _rogue_at(main, run_seed: int, round_number: int) -> void:
	main.start_rogue(run_seed)
	main.rogue.round_number = round_number
	main.rogue.goal = {"type": "distance", "target": 10.0, "round": round_number, "text": "Fly at least 10 m"}
	main.ui_layer.refresh(main)


func test_rogue_total() -> void:
	var main = _main()
	for rounds in [3, 4]:
		main.start_rogue(5)
		main.rogue.rounds_cleared = rounds
		main.rogue.lives = 1
		_fly(main, Vector2(-12, 0))
		main.go_to_title()
	assert_eq(main.progress.rogue_rounds_total, 7)
	var saved = JSON.parse_string(FileAccess.get_file_as_string(SAVE))
	assert_eq(int(saved["rogue_rounds_total"]), 7)
	main.title_panel.stats_button.pressed.emit()
	assert_eq(main.stats_panel.rogue_total_label.text, "Roguelike rounds cleared: 7")
	await wait_process_frames(3)
	assert_true(main.get_viewport().get_visible_rect().encloses(main.stats_panel.get_global_rect()), "the stats still fit")
