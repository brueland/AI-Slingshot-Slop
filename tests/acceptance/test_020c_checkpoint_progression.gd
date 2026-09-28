extends GutTest
# Checkpoint 2 (task 020c): the whole progression loop works headlessly. A simple bot plays runs,
# earns coins, buys the cheapest upgrade, and must reach the 1000 m goal in a sensible number of runs.
# Also checks saving, conventions, and the docs/PROGRESS.md entry.

const CORE := {
	"res://scripts/core/progress.gd": "Progress",
	"res://scripts/core/milestones.gd": "Milestones",
	"res://scripts/core/save_system.gd": "SaveSystem",
	"res://scripts/core/course_generator.gd": "CourseGenerator",
	"res://scripts/core/run_tracker.gd": "RunTracker",
	"res://scripts/core/run_session.gd": "RunSession",
}
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)
const DT := 1.0 / 30.0
const SAVE := "user://test_020c_save.json"


func _ready_to_test() -> bool:
	for path in CORE:
		if not ResourceLoader.exists(path):
			fail_test("missing file " + path)
			return false
	return true


## Plays one full-strength 45 degree run, boosting whenever falling. Returns the result dictionary.
func _play_run(progress) -> Dictionary:
	var session = load("res://scripts/core/run_session.gd").new(progress.stats(), progress.total_runs + 1)
	session.launch_from_pull(FULL_PULL_45)
	for i in 5000:
		if session.is_finished():
			break
		if session.sim.velocity.y < 0.0 and session.sim.position.y > 0.0:
			session.boost()
		session.step(DT)
	return session.result()


func _buy_cheapest(progress) -> void:
	var catalog = load("res://scripts/core/upgrade_catalog.gd")
	while true:
		var best_id := ""
		var best_cost := -1
		for id in catalog.ids():
			if id == "guide":
				continue
			var c: int = progress.next_cost(id)
			if c >= 0 and (best_cost < 0 or c < best_cost):
				best_id = id
				best_cost = c
		if best_id == "" or not progress.can_buy(best_id):
			return
		progress.buy(best_id)


func test_bot_reaches_the_goal_in_a_sensible_number_of_runs() -> void:
	if not _ready_to_test():
		return
	var progress = load("res://scripts/core/progress.gd").new()
	var runs := 0
	var milestones_paid := 0
	var first_distance := -1.0
	while not progress.goal_reached and runs < 100:
		_buy_cheapest(progress)
		var r: Dictionary = _play_run(progress)
		if runs == 0:
			first_distance = float(r.get("distance", 0.0))
		milestones_paid += progress.record_run(r["distance"], r["coins"]).size()
		runs += 1
	assert_between(first_distance, 40.0, 75.0, "first run distance")
	assert_true(progress.goal_reached, "the bot must reach 1000 m within 100 runs (best %.0f m)" % progress.best_distance)
	assert_between(runs, 12, 90, "runs needed to reach the goal (design target is about 35, took %d)" % runs)
	assert_eq(milestones_paid, 5, "each of the 5 milestones is paid exactly once")
	assert_eq(progress.total_runs, runs)


func test_progress_survives_save_and_load() -> void:
	if not _ready_to_test():
		return
	var progress = load("res://scripts/core/progress.gd").new()
	for i in 3:
		var r: Dictionary = _play_run(progress)
		progress.record_run(r["distance"], r["coins"])
		_buy_cheapest(progress)
	var ss = load("res://scripts/core/save_system.gd")
	assert_true(ss.save_progress(progress, SAVE))
	var loaded = ss.load_progress(SAVE)
	ss.delete_save(SAVE)
	assert_eq(loaded.coins, progress.coins)
	assert_eq(loaded.levels, progress.levels)
	assert_almost_eq(loaded.best_distance, progress.best_distance, 0.001)
	assert_eq(loaded.total_runs, 3)


func test_core_files_follow_the_conventions() -> void:
	for path in CORE:
		if not ResourceLoader.exists(path):
			fail_test("missing file " + path)
			continue
		var text := FileAccess.get_file_as_string(path)
		assert_true(text.contains("class_name " + CORE[path]), "%s must declare class_name %s" % [path, CORE[path]])
		assert_true(text.contains("extends RefCounted"), path + " must extend RefCounted")
		assert_lt(text.split("\n").size(), 300, path + " must stay under 300 lines")
		assert_false(text.contains("print("), path + " must not print")


func test_progress_log_records_milestone_2() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 2: complete"),
		"add the line 'Milestone 2: complete' to docs/PROGRESS.md")
