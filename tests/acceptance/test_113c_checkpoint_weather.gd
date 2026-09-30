extends GutTest
# Checkpoint 12 (task 113c): roguelike weather works with everything else. A bot plays a seeded run through the UI
# with real frames, reading the weather on the perk panel and picking the size and perk for the next goal (checked by
# simulating RunSession, weather included, exactly like the game). Every shot must play out as predicted, several
# weathers must come up, and the Stats screen shows the run afterwards.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_113c_save.json"
const GOALS := "res://scripts/core/rogue_goals.gd"
const RUN_SEED := 11
const ROUND_CAP := 8
const WEATHER := "res://scripts/core/rogue_weather.gd"
const ANGLES := [45.0, 35.0, 55.0, 25.0, 65.0, 15.0, 75.0, 30.0, 40.0, 50.0, 60.0, 20.0, 70.0, 10.0, 80.0]
const SIZE_ORDER := {
	"distance": ["small", "normal", "big"], "zone": ["normal", "small", "big"], "height": ["normal", "small", "big"],
	"bounces": ["normal", "small", "big"], "stars": ["big", "normal", "small"],
}
const PREFER := {
	"distance": ["power", "heavy", "aero", "feather"], "height": ["power", "heavy", "height", "feather"],
	"zone": ["steady", "aero", "power"], "bounces": ["bounce", "power", "height"], "stars": ["power", "heavy", "aero"],
}


func before_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func after_each() -> void:
	before_each()


func _pull(angle_deg: float, strength: float) -> Vector2:
	var r := deg_to_rad(angle_deg)
	return Vector2(-cos(r), sin(r)) * Balance.MAX_PULL_PX * strength


func _predict(run, pull: Vector2) -> Dictionary:
	var s := RunSession.new(run.stats(), run.shot_seed())
	s.launch_from_pull(pull)
	while not s.is_finished():
		s.step(1.0 / 60.0)
	return s.result()


## A pull that meets the run's goal with its current stats, or ZERO.
func _search(run) -> Vector2:
	var goals = load(GOALS)
	for si in range(20, 3, -1):
		for a in ANGLES:
			if goals.check(run.goal, _predict(run, _pull(a, si / 20.0))):
				return _pull(a, si / 20.0)
	if run.goal["type"] == "stars" or run.goal["type"] == "bounces":
		for si in range(20, 3, -1):
			for a in range(10, 81):
				if goals.check(run.goal, _predict(run, _pull(float(a), si / 20.0))):
					return _pull(float(a), si / 20.0)
	return Vector2.ZERO


## The first size (in the goal's preferred order) that can meet the next goal once `pick` is taken.
func _choose_size(run, pick: String) -> String:
	var old: String = run.size_id
	run.perks.append(pick)
	var chosen := "normal"
	for size in SIZE_ORDER[str(run.goal["type"])]:
		run.set_size(size)
		if _search(run) != Vector2.ZERO:
			chosen = size
			break
	run.perks.pop_back()
	run.set_size(old)
	return chosen


func test_weather_rounds_with_real_frames() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	await wait_process_frames(2)
	main.start_rogue(RUN_SEED)
	var goals = load(GOALS)
	var weather = load(WEATHER)
	var panel = main.ui_layer.rogue_panel
	var weathers := {}
	var shots := 0
	while not main.rogue.is_over() and main.rogue.rounds_cleared < ROUND_CAP and shots < 30:
		shots += 1
		assert_eq(main.state_name(), "AIM")
		assert_eq(main.rogue.weather, weather.for_round(main.rogue.round_number, RUN_SEED), "the round's weather")
		if main.rogue.weather != "calm":
			weathers[main.rogue.weather] = true
		var plan := _search(main.rogue)
		if plan == Vector2.ZERO:
			plan = _pull(45.0, 1.0)
		var goal: Dictionary = main.rogue.goal
		var anchor: Vector2 = main.slingshot.global_position
		main.slingshot.begin_drag(anchor)
		main.slingshot.update_drag(anchor + plan)
		await wait_process_frames(1)
		var pull: Vector2 = main.slingshot.pull
		var predicted: bool = goals.check(goal, _predict(main.rogue, pull))
		main.slingshot.release()
		for i in 20000:
			if main.state_name() != "FLIGHT":
				break
			main.advance(1.0 / 60.0)
		assert_eq(bool(main.rogue_outcome.get("met")), predicted,
			"shot %d ('%s', %s, %s): played exactly as predicted" % [shots, goal["text"], main.rogue.size_id, main.rogue.weather])
		if main.rogue.is_over():
			break
		await wait_process_frames(1)
		var w: Dictionary = weather.get_def(main.rogue.weather)
		assert_eq(panel.weather_label.text, "Weather: %s - %s" % [w["name"], w["description"]], "the panel shows the next weather")
		var index := 0
		for id in PREFER[str(main.rogue.goal["type"])]:
			if main.rogue.offer.has(id):
				index = main.rogue.offer.find(id)
				break
		var size := _choose_size(main.rogue, main.rogue.offer[index])
		panel.size_buttons[size].pressed.emit()
		panel.perk_buttons[index].pressed.emit()
	assert_gt(weathers.size(), 2, "several weathers came up: %s" % [weathers.keys()])
	assert_gt(main.rogue.rounds_cleared, 6, "cleared %d rounds" % main.rogue.rounds_cleared)
	main.go_to_title()
	main.progress.best_rogue_round = maxi(main.progress.best_rogue_round, main.rogue.rounds_cleared)
	main.title_panel.stats_button.pressed.emit()
	await wait_process_frames(2)
	assert_eq(main.stats_panel.rogue_label.text, "Best roguelike run: %d rounds" % main.progress.best_rogue_round)
	assert_true(main.get_viewport().get_visible_rect().encloses(main.stats_panel.get_global_rect()))


func test_new_scripts_follow_the_conventions() -> void:
	for path in {"res://scripts/game/birds.gd": "Birds", "res://scripts/core/rogue_weather.gd": "RogueWeather"}:
		if not ResourceLoader.exists(path):
			fail_test("missing file " + path)
			continue
		var text := FileAccess.get_file_as_string(path)
		assert_true(text.contains("class_name " + {"res://scripts/game/birds.gd": "Birds", "res://scripts/core/rogue_weather.gd": "RogueWeather"}[path]))
		assert_lt(text.split("
").size(), 300)
		assert_false(text.contains("print("))
	var main_text := FileAccess.get_file_as_string("res://scripts/game/main.gd")
	assert_lt(main_text.split("
").size(), 450, "main.gd stays under 450 lines")


func test_progress_log_records_milestone_12() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 12: complete"), "add the line 'Milestone 12: complete' to docs/PROGRESS.md")
