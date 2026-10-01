extends GutTest
# Checkpoint 30 (task 237c): with real frames, holding Space fires the rocket only while it is held and the gauge shows
# what is left; and a roguelike shot that would stop just short of the landing zone on flat ground rolls into the
# zone's dip and meets the goal.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_237c_save.json"
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


func _key(pressed: bool) -> InputEventAction:
	var e := InputEventAction.new()
	e.action = "boost"
	e.pressed = pressed
	return e


func test_rocket_with_real_frames() -> void:
	var main = _main()
	main.progress.levels = {"boosts": 3}
	main.start_game()
	main.launch_with_pull(PULL)
	await wait_seconds(0.3)
	main._unhandled_input(_key(true))
	await wait_seconds(0.4)
	main._unhandled_input(_key(false))
	var fuel: float = main.session.sim.boost_fuel
	assert_between(fuel, 0.5, 1.45, "some of the 1.5 s burned while Space was held")
	assert_false(main.session.sim.is_boosting())
	await wait_seconds(0.2)
	assert_eq(float(main.session.sim.boost_fuel), fuel, "nothing burns after the release")
	assert_eq(main.hud.boosts_label.text, "Rocket: %.1f s" % fuel)
	assert_almost_eq(main.hud.rocket_bar.value, fuel / 1.5, 0.01)


## The flat-ground result of `pull` with the rogue run's next shot (no dip: RunSession alone has none).
func _flat_distance(main, pull: Vector2) -> float:
	var s := RunSession.new(main.rogue.stats(), main.rogue.shot_seed())
	s.launch_from_pull(pull)
	while not s.is_finished():
		s.step(1.0 / 60.0)
	return s.sim.distance()


func test_a_near_miss_rolls_into_the_zone() -> void:
	var main = _main()
	main.start_rogue(5)
	main.rogue.goal = {"type": "zone", "target": 40.0, "round": 3, "text": "Stop between 40 and 60 m"}
	main._begin_aim()
	var pull := Vector2.ZERO
	var flat := 0.0
	for angle in [15.0, 25.0, 35.0, 45.0]:
		var dir := Vector2(-cos(deg_to_rad(angle)), sin(deg_to_rad(angle))) * Balance.MAX_PULL_PX
		var lo := 0.1
		var hi := 1.0
		for i in 24:
			var mid := (lo + hi) / 2.0
			if _flat_distance(main, dir * mid) < 39.3:
				lo = mid
			else:
				hi = mid
		flat = _flat_distance(main, dir * lo)
		if flat > 38.7 and flat < 39.9:
			pull = dir * lo
			break
	assert_ne(pull, Vector2.ZERO, "found a shot that stops just short on flat ground (%.2f m)" % flat)
	main.launch_with_pull(pull)
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	var d: float = main.session.sim.distance()
	assert_between(d, 40.0, 60.0, "the dip catches it (%.2f m on flat ground)" % flat)
	assert_true(RogueGoals.check({"type": "zone", "target": 40.0}, {"distance": d}))


func test_new_code_follows_the_conventions() -> void:
	var main_text := FileAccess.get_file_as_string("res://scripts/game/main.gd")
	assert_lt(main_text.split("\n").size(), 450, "main.gd stays under 450 lines")
	assert_lt(FileAccess.get_file_as_string("res://scripts/ui/hud.gd").split("\n").size(), 300, "hud.gd stays under 300 lines")
	var gauge := FileAccess.get_file_as_string("res://scripts/ui/rocket_gauge.gd")
	assert_true(gauge.contains("class_name RocketGauge"))
	for path in ["res://scripts/ui/rocket_gauge.gd", "res://scripts/core/flight_sim.gd", "res://scripts/game/zone_marker.gd"]:
		assert_false(FileAccess.get_file_as_string(path).contains("print("), path)


func test_progress_log_records_milestone_30() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 30: complete"), "add the line 'Milestone 30: complete' to docs/PROGRESS.md")
