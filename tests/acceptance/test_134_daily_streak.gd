extends GutTest
# Task 134: daily runs count a streak of days in a row; the run-over screen of a daily run shows "Daily streak: N days".

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_134_save.json"


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


func _lose_a_run(main, run_seed: int, rounds: int) -> void:
	main.start_rogue(run_seed)
	main.rogue.rounds_cleared = rounds
	main.rogue.lives = 1
	main.launch_with_pull(Vector2(-12, 0))
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)


func test_streak() -> void:
	var d = load("res://scripts/core/daily.gd")
	var today := {"year": 2026, "month": 3, "day": 2}
	assert_eq(d.streak({}, today), 0)
	assert_eq(d.streak({"2026-03-02": 1}, today), 1)
	assert_eq(d.streak({"2026-03-02": 1, "2026-03-01": 4, "2026-02-28": 2, "2026-02-26": 9}, today), 3, "across a month end")
	assert_eq(d.streak({"2026-03-01": 4}, today), 0, "no run today, no streak")


func test_streak_on_the_over_panel() -> void:
	var d = load("res://scripts/core/daily.gd")
	var main = _main()
	var today: Dictionary = d.today()
	main.start_daily(today)
	main.rogue.lives = 1
	main.launch_with_pull(Vector2(-12, 0))
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	var over = main.ui_layer.rogue_over_panel
	assert_true(over.streak_label.visible)
	assert_eq(over.streak_label.text, "Daily streak: 1 day")
	main.go_to_title()
	_lose_a_run(main, 5, 1)
	assert_false(over.streak_label.visible, "normal runs hide it")
