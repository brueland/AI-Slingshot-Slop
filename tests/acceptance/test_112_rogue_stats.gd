extends GutTest
# Task 112: the Stats screen also shows the best roguelike run, how many daily runs were played and how many hats are
# unlocked.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_112_save.json"


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func test_rogue_stats() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	var panel = main.stats_panel
	assert_true(panel.get("rogue_label") is Label, "stats_panel.rogue_label")
	if not panel.get("rogue_label") is Label:
		return
	main.title_panel.stats_button.pressed.emit()
	assert_eq(panel.rogue_label.text, "Best roguelike run: 0 rounds")
	assert_eq(panel.daily_label.text, "Daily runs played: 0")
	assert_eq(panel.hats_label.text, "Hats: 0 / 6")
	main.progress.best_rogue_round = 7
	main.progress.daily_best = {"2026-09-28": 3, "2026-09-29": 5}
	main.progress.total_runs = 1
	main.progress.best_distance = 150.0
	panel.show_stats(main.progress)
	assert_eq(panel.rogue_label.text, "Best roguelike run: 7 rounds")
	assert_eq(panel.daily_label.text, "Daily runs played: 2")
	assert_eq(panel.hats_label.text, "Hats: 3 / 6", "party, propeller and wizard")
	await wait_process_frames(3)
	assert_true(main.get_viewport().get_visible_rect().encloses(panel.get_global_rect()), "the stats still fit on screen")
