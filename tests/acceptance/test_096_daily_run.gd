extends GutTest
# Task 096: scripts/core/daily.gd, the daily roguelike run's seed and key for a date, and the best rounds per day
# (last 30 days) saved in Progress.daily_best.

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
