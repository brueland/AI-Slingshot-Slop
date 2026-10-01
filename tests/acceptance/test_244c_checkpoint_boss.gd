extends GutTest
# Checkpoint 31 (task 244c): a roguelike run reaches round 10 and fights the Grumblor: a player who aims for the
# targets (searching shots like the game plays them) knocks out its 12 HP within 4 shots without losing a life,
# the panel reports every hit, beating it gives an extra life, and round 11 has no boss.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_244c_save.json"
const PULL := Vector2(-84.852814, 84.852814)


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


func _fly(main, pull: Vector2) -> void:
	main.launch_with_pull(pull)
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)


func _on_screen(main, control: Control, what: String) -> void:
	assert_true(main.get_viewport().get_visible_rect().encloses(control.get_global_rect()), what + " is on screen")


const PERKS := ["power", "power", "power", "aero", "aero", "bounce", "height", "heavy", "power"]
const RUN_SEED := 4040


func _pull(angle: float, strength: float) -> Vector2:
	var r := deg_to_rad(angle)
	return Vector2(-cos(r), sin(r)) * Balance.MAX_PULL_PX * strength


## The result of `pull` exactly like the game plays it: the run's stats (with the boss) and course.
func _predict(run, pull: Vector2) -> Dictionary:
	var s := RunSession.new(run.stats(), run.shot_seed())
	s.launch_from_pull(pull)
	while not s.is_finished():
		s.step(1.0 / 60.0)
	return s.result()


## The pull that deals the most damage to the boss (ties: the stronger, flatter one first).
func _best(run) -> Vector2:
	var best := Vector2.ZERO
	var most := 0
	for si in range(20, 9, -1):
		for a in range(10, 80, 5):
			var d := int(_predict(run, _pull(float(a), si / 20.0)).get("boss_damage", 0))
			if d > most:
				most = d
				best = _pull(float(a), si / 20.0)
	return best


func test_beat_the_grumblor() -> void:
	var main = _main()
	await wait_process_frames(2)
	main.start_rogue(RUN_SEED)
	main.rogue.perks.assign(PERKS)
	main.rogue.round_number = 9
	main.rogue.goal = {"type": "distance", "target": 10.0, "round": 9, "text": "Fly at least 10 m"}
	_fly(main, _pull(45.0, 1.0))
	assert_true(main.rogue_outcome.get("met"), "round 9 is met")
	assert_eq(main.rogue.goal["type"], "fight", "round 10 is a boss fight")
	var panel = main.ui_layer.rogue_panel
	await wait_process_frames(2)
	assert_eq(panel.goal_label.text, "Next goal: Boss: 12 HP, 4 shots left")
	panel.perk_buttons[0].pressed.emit()
	assert_eq(main.state_name(), "AIM")
	assert_true(main.hud.boss_label.visible)
	assert_true(main.feedback.boss_view.visible, "the Grumblor is on the field")
	var lives: int = main.rogue.lives
	var shots := 0
	while str(main.rogue.goal.get("type", "")) == "fight" and shots < 4:
		var plan := _best(main.rogue)
		assert_ne(plan, Vector2.ZERO, "some shot hits the boss")
		var predicted := _predict(main.rogue, plan)
		_fly(main, plan)
		shots += 1
		assert_eq(int(main.rogue_outcome.get("boss_damage")), int(predicted["boss_damage"]),
			"shot %d: the game plays the shot exactly like RunSession" % shots)
		assert_gt(int(main.rogue_outcome.get("boss_damage")), 0, "an aimed shot hits")
		await wait_process_frames(2)
		if main.rogue_outcome.get("met"):
			break
		assert_eq(main.rogue.lives, lives, "no life lost while there are shots left")
		assert_true(panel.title_label.text.begins_with("Boss hit for "), panel.title_label.text)
		panel.perk_buttons[0].pressed.emit()
	assert_true(main.rogue_outcome.get("boss_beaten"), "the Grumblor is beaten in %d shots" % shots)
	assert_eq(main.rogue.lives, lives + 1, "an extra life")
	assert_eq(main.rogue.round_number, 11)
	assert_eq(panel.title_label.text, "Boss beaten! +1 life")
	panel.perk_buttons[0].pressed.emit()
	assert_false(main.feedback.boss_view.visible, "no boss in round 11")


func test_new_code_follows_the_conventions() -> void:
	var main_text := FileAccess.get_file_as_string("res://scripts/game/main.gd")
	assert_lt(main_text.split("\n").size(), 450, "main.gd stays under 450 lines")
	for path in ["res://scripts/core/boss_fight.gd", "res://scripts/game/boss_view.gd"]:
		var text := FileAccess.get_file_as_string(path)
		assert_false(text.contains("print("), path)
		assert_lt(text.split("\n").size(), 300, path + " stays under 300 lines")
	assert_lt(FileAccess.get_file_as_string("res://scripts/game/feedback.gd").split("\n").size(), 300)


func test_progress_log_records_milestone_31() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 31: complete"), "add the line 'Milestone 31: complete' to docs/PROGRESS.md")
