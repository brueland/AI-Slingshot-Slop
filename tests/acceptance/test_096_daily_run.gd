extends GutTest
# Task 096: a Daily Run on the title: a roguelike run whose seed is the date (the same run for everyone that day).
# The best rounds per day are saved (last 30 days) and shown on the run-over screen.

const PATH := "res://scripts/core/daily.gd"
const PROGRESS := "res://scripts/core/progress.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_096_save.json"
const DAY := {"year": 2026, "month": 9, "day": 29}


func before_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func after_each() -> void:
	before_each()


func _d():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH)


func _main():
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	return main


func test_keys_and_seeds() -> void:
	var d = _d()
	if d == null:
		return
	assert_eq(d.key_for(DAY), "2026-09-29")
	assert_eq(d.key_for({"year": 2027, "month": 1, "day": 5}), "2027-01-05")
	assert_eq(d.seed_for(DAY), 20260929)
	var today: Dictionary = d.today()
	assert_true(today.has("year") and today.has("month") and today.has("day"))


func test_record_keeps_the_best_of_the_last_30_days() -> void:
	var d = _d()
	if d == null:
		return
	var bests := {}
	d.record(bests, "2026-09-29", 4)
	d.record(bests, "2026-09-29", 2)
	assert_eq(bests["2026-09-29"], 4, "the best of the day")
	for day in range(1, 32):
		d.record(bests, "2026-08-%02d" % day, day)
	assert_eq(bests.size(), 30)
	assert_false(bests.has("2026-08-01"), "the oldest days are dropped")
	assert_true(bests.has("2026-09-29"))


func test_progress_saves_daily_bests() -> void:
	if _d() == null:
		return
	var script = load(PROGRESS)
	var p = script.new()
	assert_eq(p.get("daily_best"), {})
	p.daily_best = {"2026-09-29": 6}
	var q = script.from_dict(JSON.parse_string(JSON.stringify(p.to_dict())))
	assert_eq(q.daily_best, {"2026-09-29": 6})
	assert_eq(typeof(q.daily_best["2026-09-29"]), TYPE_INT)
	assert_eq(script.from_dict({}).daily_best, {})


func test_daily_run_in_the_game() -> void:
	if _d() == null:
		return
	var main = _main()
	assert_true(main.title_panel.get("daily_button") is Button, "title_panel.daily_button")
	assert_eq(main.title_panel.daily_button.text, "Daily Run")
	main.start_daily(DAY)
	assert_eq(main.mode, "rogue")
	assert_eq(main.rogue.run_seed, 20260929)
	assert_eq(main.daily_key, "2026-09-29")
	main.rogue.rounds_cleared = 3
	main.rogue.lives = 1
	main.launch_with_pull(Vector2(-12, 0))
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	assert_true(main.rogue.is_over())
	assert_eq(main.progress.daily_best.get("2026-09-29"), 3)
	var over = main.ui_layer.rogue_over_panel
	assert_true(over.daily_label.visible)
	assert_eq(over.daily_label.text, "Daily run 2026-09-29 - best today: 3 rounds")
	var saved = JSON.parse_string(FileAccess.get_file_as_string(SAVE))
	assert_eq(int(saved["daily_best"]["2026-09-29"]), 3, "saved")
	over.back_button.pressed.emit()
	assert_eq(main.daily_key, "")
	main.start_rogue(5)
	assert_eq(main.daily_key, "", "a normal run is not a daily run")
	main.go_to_title()
	main.title_panel.daily_button.pressed.emit()
	assert_eq(main.rogue.run_seed, _d().seed_for(_d().today()), "the button plays today's run")


func test_normal_runs_hide_the_daily_line() -> void:
	var main = _main()
	main.start_rogue(7)
	main.rogue.lives = 1
	main.launch_with_pull(Vector2(-12, 0))
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	assert_true(main.ui_layer.rogue_over_panel.visible)
	assert_false(main.ui_layer.rogue_over_panel.daily_label.visible)
