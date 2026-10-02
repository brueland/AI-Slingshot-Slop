extends GutTest
# Checkpoint 34 (task 256c): with real frames, a roguelike shot that collects stars gives the boosts StarBoosts says,
# the panel and the HUD show them, and the next shot flies with the boosted stats.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_256c_save.json"
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



func _predict(run, pull: Vector2) -> Dictionary:
	var s := RunSession.new(run.stats(), run.shot_seed())
	s.launch_from_pull(pull)
	while not s.is_finished():
		s.step(1.0 / 60.0)
	return s.result()


func test_star_power_with_real_frames() -> void:
	var main = _main()
	await wait_process_frames(2)
	main.start_rogue(77)
	main.rogue.perks.assign(["power", "power", "aero"])
	main._begin_aim()
	var plan := Vector2.ZERO
	var stars := 0
	for a in range(15, 75, 3):
		for si in range(20, 8, -2):
			var r := deg_to_rad(float(a))
			var pull := Vector2(-cos(r), sin(r)) * Balance.MAX_PULL_PX * si / 20.0
			var got := int(_predict(main.rogue, pull).get("stars", 0))
			if got > stars:
				stars = got
				plan = pull
	assert_gt(stars, 0, "some shot collects stars")
	main.launch_with_pull(plan)
	for i in 600:
		if main.state_name() != "FLIGHT":
			break
		await wait_physics_frames(1)
	while main.state_name() == "FLIGHT":
		main.advance(1.0 / 60.0)
	assert_eq(main.rogue.stars_total, stars, "the stars count for the run")
	var expected := []
	for n in range(1, stars + 1):
		expected.append(StarBoosts.roll(77, n))
	assert_eq(main.rogue_outcome["stars_gained"], expected)
	await wait_process_frames(2)
	assert_true(main.ui_layer.rogue_panel.stars_label.visible)
	main.ui_layer.rogue_panel.perk_buttons[0].pressed.emit()
	await wait_process_frames(2)
	assert_true(main.hud.perk_chips.chip_texts().has("Stars %d" % stars), "the HUD shows the run's stars")
	assert_almost_eq(main.session.stats.max_speed, main.rogue.stats().max_speed, 0.0001, "the next shot is boosted")


func test_progress_log_records_milestone_34() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 33: complete"), "the earlier lines are kept")
	assert_true(text.contains("Milestone 34: complete"), "add the line 'Milestone 34: complete' to docs/PROGRESS.md")
