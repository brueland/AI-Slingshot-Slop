extends GutTest
# Checkpoint 13 (task 120c): the milestone 13 features work together with real frames: a roguelike run reaches the
# round-12 boss, the perk panel shows it in red, a planned shot beats it through the UI and earns an extra life; a
# classic shot draws its map on the results; the Wardrobe previews the hat; a UFO greets the alien.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_120c_save.json"
const GOALS := "res://scripts/core/rogue_goals.gd"
const RUN_SEED := 13
const ANGLES := [45.0, 35.0, 55.0, 25.0, 65.0, 15.0, 75.0, 30.0, 40.0, 50.0, 60.0, 20.0, 70.0, 10.0, 80.0]
const PERKS := ["power", "power", "power", "aero", "aero", "bounce", "bounce", "height", "heavy", "feather", "power"]


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


func _shoot(main, plan: Vector2) -> void:
	var anchor: Vector2 = main.slingshot.global_position
	main.slingshot.begin_drag(anchor)
	main.slingshot.update_drag(anchor + plan)
	await wait_process_frames(1)
	main.slingshot.release()
	_fly(main)


func test_beat_the_round_12_boss_with_real_frames() -> void:
	var main = _main()
	await wait_process_frames(2)
	main.start_rogue(RUN_SEED)
	main.rogue.perks.assign(PERKS)
	main.rogue.round_number = 11
	main.rogue.goal = {"type": "distance", "target": 10.0, "round": 11, "text": "Fly at least 10 m"}
	await _shoot(main, _pull(45.0, 1.0))
	assert_true(main.rogue_outcome.get("met"), "round 11 is met")
	var panel = main.ui_layer.rogue_panel
	await wait_process_frames(2)
	assert_eq(main.rogue.goal["type"], "boss", "round 12 is a boss round")
	assert_true(panel.goal_label.text.begins_with("Next goal: BOSS: "))
	assert_eq(panel.goal_label.modulate, Color(1.0, 0.6, 0.6))
	var lives: int = main.rogue.lives
	main.rogue.perks.append(main.rogue.offer[0])
	var plan := _search(main.rogue)
	main.rogue.perks.pop_back()
	assert_ne(plan, Vector2.ZERO, "the boss can be beaten with this run's perks")
	panel.perk_buttons[0].pressed.emit()
	assert_eq(main.state_name(), "AIM")
	assert_eq(main.hud.goal_label.text, "Goal: " + str(main.rogue.goal["text"]), "the HUD shows the boss goal")
	await _shoot(main, plan)
	assert_true(main.rogue_outcome.get("boss_beaten"), "the planned shot beats the boss")
	assert_eq(main.rogue.lives, lives + 1, "an extra life")
	await wait_process_frames(2)
	assert_eq(panel.title_label.text, "Boss beaten! +1 life")


func test_map_wardrobe_and_ufo_with_real_frames() -> void:
	var main = _main()
	main.progress.total_runs = 1
	main.choose_hat("party")
	main.title_panel.wardrobe_button.pressed.emit()
	assert_eq(main.wardrobe_panel.preview.decor.hat, "party", "the Wardrobe previews the hat")
	main.wardrobe_panel.close_button.pressed.emit()
	main.title_panel.play_button.pressed.emit()
	main.launch_with_pull(_pull(45.0, 1.0))
	main.advance(1.0 / 60.0)
	main.toggle_pause()
	main.projectile_view.position = main.ufo.ufo_position(0) + Vector2(0, 120)
	await wait_process_frames(2)
	assert_true(main.ufo.greeted[0], "the UFO says hello")
	main.toggle_pause()
	_fly(main)
	await wait_process_frames(2)
	assert_true(main.results_panel.visible)
	assert_gt(main.results_panel.shot_map.points.size(), 5, "the results draw the shot")


func test_new_scripts_follow_the_conventions() -> void:
	var scripts := {"res://scripts/ui/shot_map.gd": "ShotMap", "res://scripts/game/ufo.gd": "Ufo"}
	for path in scripts:
		if not ResourceLoader.exists(path):
			fail_test("missing file " + path)
			continue
		var text := FileAccess.get_file_as_string(path)
		assert_true(text.contains("class_name " + scripts[path]))
		assert_lt(text.split("
").size(), 300)
		assert_false(text.contains("print("))
	var main_text := FileAccess.get_file_as_string("res://scripts/game/main.gd")
	assert_lt(main_text.split("
").size(), 450, "main.gd stays under 450 lines")


func test_progress_log_records_milestone_13() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 13: complete"), "add the line 'Milestone 13: complete' to docs/PROGRESS.md")
