extends GutTest
# Checkpoint 19 (task 164c): the milestone 19 features work together with real frames: a lucky roguelike round with
# weather on the HUD earns a reroll, glowing flags mark reached milestones, and the shop points at the best buy.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_164c_save.json"


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


func test_variety_with_real_frames() -> void:
	var main = _main()
	await wait_process_frames(2)
	_rogue_at(main, 7, 9)
	main.rogue.weather = "springy"
	main.ui_layer.refresh(main)
	await wait_process_frames(2)
	assert_true(main.hud.lucky_label.visible)
	assert_eq(main.hud.weather_label.text, "Weather: Springy Ground")
	var rerolls: int = main.rogue.rerolls
	_fly(main, Vector2(-84.852814, 84.852814))
	await wait_process_frames(2)
	assert_eq(main.rogue.rerolls, rerolls + 1)
	assert_eq(main.ui_layer.rogue_panel.reroll_button.text, "Reroll perks (%d left)" % (rerolls + 1))
	main.go_to_title()
	main.progress.best_distance = float(Milestones.LIST[0]["distance"]) + 1.0
	main.progress.coins = 500
	main.start_game()
	assert_eq(main.course_view.flags[0].modulate, Color(1.0, 0.9, 0.4))
	_fly(main, Vector2(-84.852814, 84.852814))
	main.continue_to_shop()
	await wait_process_frames(2)
	assert_ne(main.shop_panel.best_buy, "")


func test_main_stays_small() -> void:
	var main_text := FileAccess.get_file_as_string("res://scripts/game/main.gd")
	assert_lt(main_text.split("\n").size(), 450, "main.gd stays under 450 lines")


func test_progress_log_records_milestone_19() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 19: complete"), "add the line 'Milestone 19: complete' to docs/PROGRESS.md")
