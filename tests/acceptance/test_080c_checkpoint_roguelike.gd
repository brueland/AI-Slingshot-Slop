extends GutTest
# Checkpoint 8 (task 080c): the roguelike works end to end with real frames. A bot plays a seeded run through the
# UI: for every goal it searches for an aim that meets it (simulating RunSession exactly like the game does), drags
# the slingshot, and picks the perk that helps most with the next goal. A thoughtful player must be able to clear
# several rounds; the run-over screen, the saved best round, the last-aim line and classic mode must all work.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_080c_save.json"
const GOALS := "res://scripts/core/rogue_goals.gd"
const RUN_SEED := 2024
const ROUND_CAP := 8
const ANGLES := [45.0, 35.0, 55.0, 25.0, 65.0, 15.0, 75.0, 30.0, 40.0, 50.0, 60.0, 20.0, 70.0, 10.0, 80.0]
const PREFER := {
	"distance": ["power", "heavy", "aero", "feather"],
	"height": ["power", "heavy", "height", "feather"],
	"zone": ["steady", "aero", "power"],
	"bounces": ["bounce", "power", "height"],
	"stars": ["power", "heavy", "aero", "feather"],
}
const NEW_SCRIPTS := {
	"res://scripts/game/feedback.gd": "Feedback",
	"res://scripts/core/rogue_goals.gd": "RogueGoals",
	"res://scripts/core/rogue_perks.gd": "RoguePerks",
	"res://scripts/core/rogue_run.gd": "RogueRun",
	"res://scripts/ui/rogue_panel.gd": "RoguePanel",
	"res://scripts/ui/rogue_over_panel.gd": "RogueOverPanel",
}


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


func _fly(main) -> void:
	for i in 20000:
		if main.state_name() != "FLIGHT":
			return
		main.advance(1.0 / 60.0)


func _pull(angle_deg: float, strength: float) -> Vector2:
	var r := deg_to_rad(angle_deg)
	return Vector2(-cos(r), sin(r)) * Balance.MAX_PULL_PX * strength


## What the game will do with this pull: the same stats and course as main's next shot.
func _predict(run, pull: Vector2) -> Dictionary:
	var s := RunSession.new(run.stats(), run.shot_seed())
	s.launch_from_pull(pull)
	while not s.is_finished():
		s.step(1.0 / 60.0)
	return s.result()


## A pull whose predicted result meets (or, with want_met false, misses) the current goal; ZERO when none does.
func _plan(run, want_met: bool = true) -> Vector2:
	var goals = load(GOALS)
	for si in range(20, 3, -1):
		for a in ANGLES:
			var pull := _pull(a, si / 20.0)
			if goals.check(run.goal, _predict(run, pull)) == want_met:
				return pull
	if want_met and (run.goal["type"] == "stars" or run.goal["type"] == "bounces"):
		for si in range(20, 3, -1):
			for a in range(10, 81):
				var pull := _pull(float(a), si / 20.0)
				if goals.check(run.goal, _predict(run, pull)):
					return pull
	return Vector2.ZERO


## Drags the real slingshot (with frames in between) and returns the pull it launched with.
func _shoot(main, pull: Vector2) -> Vector2:
	var anchor: Vector2 = main.slingshot.global_position
	assert_true(main.slingshot.begin_drag(anchor), "the slingshot can be grabbed")
	main.slingshot.update_drag(anchor + pull)
	await wait_process_frames(1)
	var actual: Vector2 = main.slingshot.pull
	main.slingshot.release()
	return actual


func _preferred_button(main) -> int:
	var offer: Array = main.rogue.offer
	for id in PREFER.get(str(main.rogue.goal["type"]), []):
		if offer.has(id):
			return offer.find(id)
	return 0


func test_a_bot_clears_rounds_by_choosing_perks_for_the_next_goal() -> void:
	var main = _main()
	await wait_process_frames(2)
	main.start_rogue(RUN_SEED)
	assert_eq(main.mode, "rogue")
	var goals = load(GOALS)
	var panel = main.ui_layer.rogue_panel
	var shots := 0
	while not main.rogue.is_over() and main.rogue.rounds_cleared < ROUND_CAP and shots < 40:
		shots += 1
		assert_eq(main.state_name(), "AIM")
		assert_eq(main.hud.goal_label.text, "Goal: " + str(main.rogue.goal["text"]), "the HUD shows the goal")
		var plan := _plan(main.rogue)
		if plan == Vector2.ZERO:
			plan = _pull(45.0, 1.0)
		var goal: Dictionary = main.rogue.goal
		var pull: Vector2 = await _shoot(main, plan)
		var predicted: bool = goals.check(goal, _predict(main.rogue, pull))
		assert_eq(main.state_name(), "FLIGHT")
		_fly(main)
		assert_eq(main.state_name(), "RESULTS")
		assert_eq(bool(main.rogue_outcome.get("met")), predicted,
			"shot %d ('%s'): the game plays the shot exactly like RunSession with the run's stats and course" % [shots, goal["text"]])
		if main.rogue.is_over():
			break
		await wait_process_frames(2)
		assert_true(panel.visible, "the perk panel after every shot")
		assert_true(main.get_viewport().get_visible_rect().encloses(panel.get_global_rect()), "perk panel on screen")
		var index := _preferred_button(main)
		var pick: String = main.rogue.offer[index]
		panel.perk_buttons[index].pressed.emit()
		assert_true(main.rogue.has_perk(pick), "the button took the perk")
		if pick == "steady":
			assert_true(main.slingshot.show_last_aim, "Steady Hand shows the last aim")
			var line: PackedVector2Array = main.slingshot.aim_line_points()
			assert_true(line.size() == 2 and line[0] == pull, "the line starts at the last pull")
	assert_gt(main.rogue.rounds_cleared, 4, "a thoughtful player clears at least 5 rounds (cleared %d, perks %s)" % [main.rogue.rounds_cleared, main.rogue.perks])


func test_losing_every_life_ends_the_run_and_saves_the_best_round() -> void:
	var main = _main()
	main.start_rogue(RUN_SEED)
	for i in 3:
		assert_eq(main.state_name(), "AIM")
		var miss := _plan(main.rogue, false)
		assert_ne(miss, Vector2.ZERO, "some aim misses the goal")
		await _shoot(main, miss)
		_fly(main)
		assert_false(main.rogue_outcome.get("met"))
		if not main.rogue.is_over():
			main.ui_layer.rogue_panel.perk_buttons[0].pressed.emit()
	assert_true(main.rogue.is_over())
	var over = main.ui_layer.rogue_over_panel
	await wait_process_frames(2)
	assert_true(over.visible, "the run-over screen")
	assert_false(main.ui_layer.rogue_panel.visible)
	assert_true(main.get_viewport().get_visible_rect().encloses(over.get_global_rect()), "run-over panel on screen")
	assert_eq(over.rounds_label.text, "Rounds cleared: 0")
	over.back_button.pressed.emit()
	assert_eq(main.state_name(), "TITLE")
	assert_eq(main.mode, "classic")
	main.progress.best_rogue_round = 0
	main.start_rogue(RUN_SEED)
	var win := _plan(main.rogue)
	await _shoot(main, win)
	_fly(main)
	assert_true(main.rogue_outcome.get("met"), "round 1 can be met")
	main.rogue.lives = 1
	main.ui_layer.rogue_panel.perk_buttons[0].pressed.emit()
	await _shoot(main, _plan(main.rogue, false))
	_fly(main)
	assert_true(main.rogue.is_over())
	assert_eq(main.progress.best_rogue_round, 1)
	var again = _main()
	assert_eq(again.progress.best_rogue_round, 1, "the best round survives a restart")


func test_classic_mode_is_unchanged_after_a_roguelike_run() -> void:
	var main = _main()
	main.start_rogue(RUN_SEED)
	await _shoot(main, _pull(45.0, 1.0))
	_fly(main)
	main.go_to_title()
	assert_eq(main.progress.total_runs, 0, "roguelike shots are not classic runs")
	assert_eq(main.progress.coins, 0)
	main.title_panel.play_button.pressed.emit()
	assert_eq(main.mode, "classic")
	assert_eq(main.session.course, CourseGenerator.generate(1, Balance.COURSE_LENGTH), "the classic course")
	assert_eq(main.hud.coins_label.text, "Coins: 0")
	assert_false(main.slingshot.show_last_aim, "no last-aim line without Aim Guide")
	await _shoot(main, _pull(45.0, 1.0))
	_fly(main)
	await wait_process_frames(2)
	assert_true(main.results_panel.visible, "the classic results screen")
	assert_false(main.ui_layer.rogue_panel.visible)
	assert_false(main.ui_layer.rogue_over_panel.visible)
	assert_eq(main.progress.total_runs, 1)


func test_new_scripts_follow_the_conventions() -> void:
	for path in NEW_SCRIPTS:
		if not ResourceLoader.exists(path):
			fail_test("missing file " + path)
			continue
		var text := FileAccess.get_file_as_string(path)
		assert_true(text.contains("class_name " + NEW_SCRIPTS[path]), "%s declares class_name %s" % [path, NEW_SCRIPTS[path]])
		assert_lt(text.split("\n").size(), 300, path + " stays under 300 lines")
		assert_false(text.contains("print("), path + " must not print")
	var main_text := FileAccess.get_file_as_string("res://scripts/game/main.gd")
	assert_lt(main_text.split("\n").size(), 450, "main.gd stays under 450 lines")


func test_progress_log_records_milestone_8() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 8: complete"), "add the line 'Milestone 8: complete' to docs/PROGRESS.md")
