extends GutTest
# Task 079: main.gd runs a roguelike run: start_rogue() from the title, each shot uses the run's perks and a new
# course, a finished shot is scored against the goal (RESULTS state), choose_rogue_perk() starts the next shot,
# and the best round is saved when the run ends. Classic progress (coins, runs) is not touched.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_079_save.json"
const RUN := "res://scripts/core/rogue_run.gd"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func _main():
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	return main


func _fly(main) -> void:
	for i in 20000:
		if main.state_name() != "FLIGHT":
			return
		main.advance(1.0 / 60.0)


func test_classic_is_the_default() -> void:
	var main = _main()
	assert_eq(main.get("mode"), "classic")
	main.start_game()
	assert_eq(main.mode, "classic")


func test_start_rogue() -> void:
	var main = _main()
	main.start_rogue(7)
	assert_eq(main.mode, "rogue")
	assert_eq(main.state_name(), "AIM")
	assert_true(main.rogue != null and main.rogue.get_script().resource_path == RUN)
	assert_eq(main.rogue.run_seed, 7)
	assert_eq(main.rogue.round_number, 1)
	assert_eq(main.session.course, load("res://scripts/core/course_generator.gd").generate(7001, 2000.0),
		"the shot uses the run's course seed")
	main.go_to_title()
	assert_eq(main.mode, "classic", "back to classic on the title")
	main.start_rogue()
	assert_gt(main.rogue.run_seed, 0, "a random seed when none is given")


func test_a_shot_is_scored_and_a_perk_starts_the_next() -> void:
	var main = _main()
	main.progress.levels = {"power": 5}
	main.start_rogue(7)
	assert_almost_eq(main.session.stats.max_speed, 22.0, 0.0001, "roguelike ignores classic upgrades")
	main.launch_with_pull(FULL_PULL_45)
	_fly(main)
	assert_eq(main.state_name(), "RESULTS")
	var out: Dictionary = main.rogue_outcome
	assert_true(out.get("met"), "a full shot flies past 40 m")
	assert_eq(main.rogue.round_number, 2)
	assert_eq(main.progress.total_runs, 0, "classic runs are not counted")
	assert_eq(main.progress.coins, 0, "no coins in the roguelike")
	assert_false(main.results_panel.visible, "not the classic results screen")
	assert_false(main.choose_rogue_perk("not-offered"))
	var pick: String = main.rogue.offer[0]
	assert_true(main.choose_rogue_perk(pick))
	assert_eq(main.state_name(), "AIM")
	assert_true(main.rogue.has_perk(pick))
	assert_eq(main.session.course, load("res://scripts/core/course_generator.gd").generate(7002, 2000.0),
		"a new course for the next shot")
	assert_almost_eq(main.session.stats.max_speed, main.rogue.stats().max_speed, 0.0001, "with the perk applied")


func test_steady_hand_shows_the_aim_line() -> void:
	var main = _main()
	main.start_rogue(7)
	assert_false(main.slingshot.show_last_aim)
	main.launch_with_pull(FULL_PULL_45)
	_fly(main)
	main.rogue.offer.assign(["steady", "power", "aero"])
	main.choose_rogue_perk("steady")
	assert_true(main.slingshot.show_last_aim, "Steady Hand unlocks the aim line in the roguelike")


func test_game_over_saves_the_best_round() -> void:
	var main = _main()
	main.progress.best_rogue_round = 0
	main.start_rogue(7)
	main.rogue.rounds_cleared = 3
	main.rogue.lives = 1
	main.launch_with_pull(Vector2(-12, 0))
	_fly(main)
	assert_true(main.rogue.is_over(), "a 12 px pull misses the 40 m goal and loses the last life")
	assert_eq(main.state_name(), "RESULTS")
	assert_eq(main.progress.best_rogue_round, 3)
	var saved = JSON.parse_string(FileAccess.get_file_as_string(SAVE))
	assert_true(saved is Dictionary and int(saved.get("best_rogue_round", 0)) == 3, "saved")
	assert_false(main.choose_rogue_perk("power"), "no perks after the run is over")
