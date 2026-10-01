extends GutTest
# Checkpoint 11 (task 105c): alien sizes make roguelike star goals fair. A bot plays a seeded run through the UI with
# real frames: before every shot it picks, on the perk panel, the size that can meet the next goal (Big for stars,
# Small for distance), checked by simulating RunSession exactly like the game. It must meet star goals and clear
# most rounds, and every shot must play out as predicted.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_105c_save.json"
const GOALS := "res://scripts/core/rogue_goals.gd"
const RUN_SEED := 7
const ROUND_CAP := 10
const ANGLES := [45.0, 35.0, 55.0, 25.0, 65.0, 15.0, 75.0, 30.0, 40.0, 50.0, 60.0, 20.0, 70.0, 10.0, 80.0]
const SIZE_ORDER := {
	"distance": ["small", "normal", "big"], "zone": ["normal", "small", "big"], "height": ["normal", "small", "big"],
	"bounces": ["normal", "small", "big"], "stars": ["big", "normal", "small"],
	"fight": ["big", "normal", "small"],
}
const PREFER := {
	"distance": ["power", "heavy", "aero", "feather"], "height": ["power", "heavy", "height", "feather"],
	"zone": ["steady", "aero", "power"], "bounces": ["bounce", "power", "height"], "stars": ["power", "heavy", "aero"],
	"fight": ["power", "heavy", "aero"],
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


func test_sizes_make_star_goals_playable() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	await wait_process_frames(2)
	main.start_rogue(RUN_SEED)
	var goals = load(GOALS)
	var panel = main.ui_layer.rogue_panel
	var star_goals := 0
	var star_goals_met := 0
	var shots := 0
	while not main.rogue.is_over() and main.rogue.rounds_cleared < ROUND_CAP and shots < 30:
		shots += 1
		assert_eq(main.state_name(), "AIM")
		assert_almost_eq(main.projectile_view.size_scale, main.rogue.stats().size_scale, 0.0001, "the alien is drawn at its size")
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
		var met := bool(main.rogue_outcome.get("met"))
		assert_eq(met, predicted, "shot %d ('%s', %s): played exactly as predicted" % [shots, goal["text"], main.rogue.size_id])
		if goal["type"] == "stars":
			star_goals += 1
			if met:
				star_goals_met += 1
		if main.rogue.is_over():
			break
		await wait_process_frames(1)
		var index := 0
		for id in PREFER[str(main.rogue.goal["type"])]:
			if main.rogue.offer.has(id):
				index = main.rogue.offer.find(id)
				break
		var size := _choose_size(main.rogue, main.rogue.offer[index])
		panel.size_buttons[size].pressed.emit()
		assert_eq(main.rogue.size_id, size)
		panel.perk_buttons[index].pressed.emit()
	assert_gt(star_goals, 0, "the run had star goals")
	assert_eq(star_goals_met, star_goals, "every star goal was met with the right size")
	assert_gt(main.rogue.rounds_cleared, 7, "cleared %d rounds" % main.rogue.rounds_cleared)


func test_rolling_into_a_low_star_counts_in_the_roguelike_only() -> void:
	var run = load("res://scripts/core/rogue_run.gd").new()
	run.start(7)
	var rogue_stats = run.stats()
	var star := [{"type": "star", "x": 10.0, "y": 2.2}]
	var sim := FlightSim.new()
	sim.launch(Vector2(12, 0), Vector2(6, 0))
	var rogue_tracker := RunTracker.new(star, rogue_stats.pickup_offset, rogue_stats.pickup_radius)
	rogue_tracker.after_step(sim, Vector2(8, 0))
	assert_eq(rogue_tracker.stars_collected, 1, "roguelike: rolling into a star 2.2 m up collects it")
	var classic_tracker := RunTracker.new(star)
	classic_tracker.after_step(sim, Vector2(8, 0))
	assert_eq(classic_tracker.stars_collected, 0, "classic keeps its rule")


func test_new_scripts_follow_the_conventions() -> void:
	var path := "res://scripts/core/rogue_sizes.gd"
	if not ResourceLoader.exists(path):
		fail_test("missing file " + path)
		return
	var text := FileAccess.get_file_as_string(path)
	assert_true(text.contains("class_name RogueSizes"))
	assert_lt(text.split("\n").size(), 300)
	assert_false(text.contains("print("))
	var main_text := FileAccess.get_file_as_string("res://scripts/game/main.gd")
	assert_lt(main_text.split("\n").size(), 450, "main.gd stays under 450 lines")


func test_progress_log_records_milestone_11() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 11: complete"), "add the line 'Milestone 11: complete' to docs/PROGRESS.md")
