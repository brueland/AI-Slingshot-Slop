extends GutTest
# Task 066: Progress keeps lifetime totals (distance, stars, bounces, best height) and the last 10 run
# distances, saves them, and main.gd records every finished run.

const PATH := "res://scripts/core/progress.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_066_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func _run(distance: float, stars: int, bounces: int, height: float) -> Dictionary:
	return {"distance": distance, "stars": stars, "bounces": bounces, "max_height": height}


func test_defaults() -> void:
	var p = load(PATH).new()
	assert_eq(p.get("lifetime"), {"distance": 0.0, "stars": 0, "bounces": 0, "best_height": 0.0})
	assert_eq(p.get("recent_distances"), [])
	assert_eq(load(PATH).get_script_constant_map().get("RECENT_RUNS"), 10)


func test_record_lifetime_accumulates() -> void:
	var p = load(PATH).new()
	p.record_lifetime(_run(50.5, 2, 3, 8.0))
	p.record_lifetime(_run(70.0, 1, 4, 6.5))
	assert_almost_eq(float(p.lifetime["distance"]), 120.5, 0.0001)
	assert_eq(int(p.lifetime["stars"]), 3)
	assert_eq(int(p.lifetime["bounces"]), 7)
	assert_almost_eq(float(p.lifetime["best_height"]), 8.0, 0.0001, "the highest ever, not a sum")
	assert_eq(p.recent_distances.size(), 2)
	assert_almost_eq(p.recent_distances[1], 70.0, 0.0001, "newest last")


func test_recent_keeps_the_last_ten() -> void:
	var p = load(PATH).new()
	for i in 13:
		p.record_lifetime(_run(float(i), 0, 0, 0.0))
	assert_eq(p.recent_distances.size(), 10)
	assert_almost_eq(p.recent_distances[0], 3.0, 0.0001, "the oldest three are dropped")
	assert_almost_eq(p.recent_distances[9], 12.0, 0.0001)


func test_saved_and_loaded() -> void:
	var script = load(PATH)
	var p = script.new()
	p.record_lifetime(_run(88.0, 4, 5, 12.0))
	var q = script.from_dict(JSON.parse_string(JSON.stringify(p.to_dict())))
	assert_almost_eq(float(q.lifetime["distance"]), 88.0, 0.0001)
	assert_eq(q.lifetime["stars"], 4)
	assert_eq(typeof(q.lifetime["stars"]), TYPE_INT, "ints come back as ints")
	assert_eq(q.lifetime["bounces"], 5)
	assert_almost_eq(float(q.lifetime["best_height"]), 12.0, 0.0001)
	assert_eq(q.recent_distances.size(), 1)
	var old = script.from_dict({"coins": 3})
	assert_eq(old.lifetime, {"distance": 0.0, "stars": 0, "bounces": 0, "best_height": 0.0}, "old saves get zeros")
	var bad = script.from_dict({"lifetime": {"stars": -4, "distance": -1.0}, "recent_distances": range(15)})
	assert_eq(bad.lifetime["stars"], 0)
	assert_almost_eq(float(bad.lifetime["distance"]), 0.0, 0.0001)
	assert_eq(bad.recent_distances.size(), 10, "trimmed to the last 10")


func test_main_records_every_run() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	var r: Dictionary = main.last_result
	assert_almost_eq(float(main.progress.lifetime["distance"]), float(r["distance"]), 0.0001)
	assert_eq(int(main.progress.lifetime["bounces"]), int(r["bounces"]))
	assert_eq(main.progress.recent_distances.size(), 1)
	var saved = JSON.parse_string(FileAccess.get_file_as_string(SAVE))
	assert_true(saved is Dictionary and saved.has("lifetime"), "saved with the run")
