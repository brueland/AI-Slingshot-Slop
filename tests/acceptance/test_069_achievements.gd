extends GutTest
# Task 069: scripts/core/achievements.gd, six one-time achievements checked after every run; unlocked ids are
# saved in Progress.achievements, and main.gd puts this run's unlocks in last_result["achievements"].

const PATH := "res://scripts/core/achievements.gd"
const PROGRESS := "res://scripts/core/progress.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_069_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func _ach():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH)


func _ids(list: Array) -> Array:
	return list.map(func(a): return a["id"])


func test_list() -> void:
	var a = _ach()
	if a == null:
		return
	var want := [["liftoff", "Liftoff"], ["bouncy", "Bouncy Castle"], ["star_catcher", "Star Catcher"],
		["high_flyer", "High Flyer"], ["far_out", "Far Out"], ["big_spender", "Big Spender"]]
	assert_eq(a.LIST.size(), 6)
	for i in mini(a.LIST.size(), want.size()):
		assert_eq(a.LIST[i]["id"], want[i][0])
		assert_eq(a.LIST[i]["name"], want[i][1])
		assert_true(str(a.LIST[i]["description"]).length() > 0)


func test_conditions() -> void:
	var a = _ach()
	if a == null:
		return
	var p = load(PROGRESS).new()
	assert_false(a.is_earned("liftoff", {}, p), "no runs yet")
	p.total_runs = 1
	assert_true(a.is_earned("liftoff", {}, p))
	assert_true(a.is_earned("bouncy", {"bounces": 8}, p))
	assert_false(a.is_earned("bouncy", {"bounces": 7}, p))
	assert_true(a.is_earned("star_catcher", {"stars": 5}, p))
	assert_true(a.is_earned("high_flyer", {"max_height": 40.5}, p))
	assert_false(a.is_earned("high_flyer", {"max_height": 40.0}, p), "higher than 40 m")
	assert_true(a.is_earned("far_out", {"distance": 250.0}, p))
	assert_false(a.is_earned("big_spender", {}, p))
	p.levels = {"power": 6, "aero": 4}
	assert_true(a.is_earned("big_spender", {}, p), "10 levels owned in total")
	assert_false(a.is_earned("nope", {"bounces": 99}, p))


func test_unlock_only_once() -> void:
	var a = _ach()
	if a == null:
		return
	var p = load(PROGRESS).new()
	p.total_runs = 1
	var first: Array = a.unlock({"bounces": 9, "stars": 1}, p)
	assert_eq(_ids(first), ["liftoff", "bouncy"])
	assert_eq(p.achievements, ["liftoff", "bouncy"])
	assert_eq(a.unlock({"bounces": 12}, p), [], "already unlocked")


func test_saved_and_loaded() -> void:
	var script = load(PROGRESS)
	var p = script.new()
	assert_eq(p.get("achievements"), [])
	p.achievements.append("far_out")
	var q = script.from_dict(JSON.parse_string(JSON.stringify(p.to_dict())))
	assert_eq(q.achievements, ["far_out"])
	var bad = script.from_dict({"achievements": ["liftoff", "hacker", "liftoff", 5]})
	assert_eq(bad.achievements, ["liftoff"], "unknown ids and duplicates are dropped")
	assert_eq(script.from_dict({}).achievements, [], "old saves have none")


func test_main_unlocks_after_a_run() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	var unlocked: Array = main.last_result.get("achievements", [])
	assert_true(_ids(unlocked).has("liftoff"), "the first run unlocks Liftoff")
	assert_true(main.progress.achievements.has("liftoff"))
	var saved = JSON.parse_string(FileAccess.get_file_as_string(SAVE))
	assert_true(saved is Dictionary and saved.get("achievements", []).has("liftoff"), "saved")
