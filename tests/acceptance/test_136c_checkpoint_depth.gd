extends GutTest
# Checkpoint 15 (task 136c): the roguelike depth features work together with real frames: a daily run ends on a
# run-over screen with history, streak and "Play this seed again"; the replayed run shows its perks on the HUD; a
# boss round shows the banner; the title shows the roguelike best.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_136c_save.json"


func before_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func after_each() -> void:
	before_each()


func _fly(main) -> void:
	for i in 20000:
		if main.state_name() != "FLIGHT":
			return
		main.advance(1.0 / 60.0)


func test_roguelike_depth_with_real_frames() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	await wait_process_frames(2)
	main.title_panel.daily_button.pressed.emit()
	var run_seed: int = main.rogue.run_seed
	main.launch_with_pull(Vector2(-84.852814, 84.852814))
	_fly(main)
	assert_true(main.rogue_outcome.get("met"), "round 1 is met")
	main.ui_layer.rogue_panel.perk_buttons[0].pressed.emit()
	await wait_process_frames(2)
	assert_true(main.hud.perk_chips.visible, "the HUD shows the perk (boxes since task 246)")
	main.rogue.lives = 1
	# a goal the tiny shot surely misses (a daily round 2 can be "Bounce 1 time", which it would meet)
	main.rogue.goal = {"type": "distance", "target": 500.0, "round": 2, "text": "Fly at least 500 m"}
	main.launch_with_pull(Vector2(-12, 0))
	_fly(main)
	var over = main.ui_layer.rogue_over_panel
	await wait_process_frames(2)
	assert_true(over.visible)
	assert_eq(over.history_label.text, "Last runs: 1 rounds")
	assert_eq(over.streak_label.text, "Daily streak: 1 day")
	assert_true(main.get_viewport().get_visible_rect().encloses(over.get_global_rect()), "the run-over panel fits")
	over.replay_button.pressed.emit()
	assert_eq(main.rogue.run_seed, run_seed, "the same seed again")
	assert_false(main.hud.perk_chips.visible, "a new run has no perks")
	main.rogue.round_number = 11
	main.rogue.goal = {"type": "distance", "target": 10.0, "round": 11, "text": "Fly at least 10 m"}
	main.launch_with_pull(Vector2(-84.852814, 84.852814))
	_fly(main)
	main.ui_layer.rogue_panel.perk_buttons[0].pressed.emit()
	await wait_process_frames(2)
	assert_true(main.hud.boss_label.visible, "round 12 is a boss round")
	main.go_to_title()
	await wait_process_frames(2)
	assert_true(main.title_panel.rogue_best_label.visible)
	assert_eq(main.title_panel.rogue_best_label.text, "Roguelike best: 1 rounds")


func test_main_stays_small() -> void:
	var main_text := FileAccess.get_file_as_string("res://scripts/game/main.gd")
	assert_lt(main_text.split("\n").size(), 450, "main.gd stays under 450 lines")


func test_progress_log_records_milestone_15() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 15: complete"), "add the line 'Milestone 15: complete' to docs/PROGRESS.md")
