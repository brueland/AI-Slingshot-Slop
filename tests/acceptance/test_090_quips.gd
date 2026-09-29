extends GutTest
# Task 090: scripts/core/quips.gd, what the alien says after a shot (by kind of shot, the same line for the same
# shot), shown in quotes on the results screen.

const PATH := "res://scripts/core/quips.gd"
const PANEL := "res://scripts/ui/results_panel.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_090_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func _q():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH)


func test_kinds() -> void:
	var q = _q()
	if q == null:
		return
	assert_eq(q.LINES.keys(), ["best", "short", "stars", "bouncy", "high", "default"])
	assert_eq(q.kind_of({"new_best": true, "distance": 5.0}), "best", "a new best beats everything")
	assert_eq(q.kind_of({"distance": 14.9}), "short")
	assert_eq(q.kind_of({"distance": 40.0, "stars": 3, "bounces": 9}), "stars")
	assert_eq(q.kind_of({"distance": 40.0, "stars": 2, "bounces": 5}), "bouncy")
	assert_eq(q.kind_of({"distance": 40.0, "max_height": 25.0}), "high")
	assert_eq(q.kind_of({"distance": 40.0, "max_height": 10.0}), "default")


func test_pick() -> void:
	var q = _q()
	if q == null:
		return
	var r := {"distance": 42.37, "bounces": 6}
	assert_eq(q.pick(r), q.pick(r), "the same shot, the same line")
	assert_eq(q.pick(r), q.LINES["bouncy"][423 % 3])
	assert_true(q.LINES["default"].has(q.pick({"distance": 33.3})))
	for kind in q.LINES:
		assert_gt(q.LINES[kind].size(), 2, "%s has at least 3 lines" % kind)


func test_results_screen_quotes_the_alien() -> void:
	if _q() == null:
		return
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	var panel = main.results_panel
	assert_true(panel.get("quip_label") is Label, "results_panel.quip_label")
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	assert_true(panel.visible)
	var expected: String = _q().pick(main.last_result)
	assert_true(_q().LINES["best"].has(expected), "the first run is a new best")
	assert_eq(panel.quip_label.text, "\"%s\"" % expected)
	await wait_process_frames(3)
	assert_true(main.get_viewport().get_visible_rect().encloses(panel.get_global_rect()), "results still fit on screen")
