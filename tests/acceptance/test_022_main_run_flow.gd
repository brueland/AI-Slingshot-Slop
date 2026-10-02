extends GutTest
# Task 022: main.gd runs a shot and the shop loop: launch_with_pull, advance, results, shop, next aim
# (docs/DESIGN.md sections 1 and 9, main.gd).

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_022_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func _main():
	if not ResourceLoader.exists(SCENE):
		fail_test("missing " + SCENE)
		return null
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	return main


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func _fly_until_done(main, max_steps: int = 20000) -> void:
	for i in max_steps:
		if main.state_name() != "FLIGHT":
			return
		main.advance(1.0 / 60.0)


func test_short_pulls_and_wrong_states_do_not_launch() -> void:
	var main = _main()
	if main == null:
		return
	assert_false(main.launch_with_pull(FULL_PULL_45), "cannot launch from the title screen")
	main.start_game()
	assert_false(main.launch_with_pull(Vector2(-5, 0)), "pulls shorter than MIN_PULL_PX are ignored")
	assert_eq(main.state_name(), "AIM")
	main.advance(1.0 / 60.0)
	assert_false(main.session.launched, "advance does not launch")


func test_a_full_run_ends_in_results() -> void:
	var main = _main()
	if main == null:
		return
	main.start_game()
	assert_true(main.launch_with_pull(FULL_PULL_45))
	assert_eq(main.state_name(), "FLIGHT")
	assert_true(main.session.launched)
	_fly_until_done(main)
	assert_eq(main.state_name(), "RESULTS")
	var r: Dictionary = main.last_result
	assert_between(float(r.get("distance", 0.0)), 40.0, 75.0)
	assert_true(r.get("milestones") is Array, "last_result['milestones'] lists the milestones this run reached")
	var rewards := 0
	for m in r.get("milestones", []):
		rewards += int(m["reward"])
	assert_eq(main.progress.total_runs, 1)
	assert_eq(main.progress.coins, int(r.get("coins", 0)) + rewards)
	assert_almost_eq(main.progress.best_distance, float(r.get("distance", 0.0)), 0.0001)


func test_boost_requests() -> void:
	var main = _main()
	if main == null:
		return
	main.progress.levels = {"boosts": 1}
	main.start_game()
	assert_false(main.request_boost(), "no boosting while aiming")
	main.launch_with_pull(FULL_PULL_45)
	main.advance(1.0 / 60.0)
	assert_true(main.request_boost())
	assert_false(main.request_boost(), "only one charge")


func test_shop_loop() -> void:
	var main = _main()
	if main == null:
		return
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	_fly_until_done(main)
	assert_false(main.buy_upgrade("power"), "cannot buy on the results screen")
	main.continue_to_shop()
	assert_eq(main.state_name(), "SHOP")
	main.progress.add_coins(1000)
	assert_true(main.buy_upgrade("power"))
	assert_eq(main.progress.level_of("power"), 1)
	main.leave_shop()
	assert_eq(main.state_name(), "AIM")
	assert_false(main.session.launched, "a fresh session for the next run")
	assert_almost_eq(main.session.stats.max_speed, 27.5, 0.0001, "the new session uses the upgraded stats")
	assert_eq(main.session.course, RunSession.new(main.progress.stats(), 2).course,
		"the second run's seed is 2")
