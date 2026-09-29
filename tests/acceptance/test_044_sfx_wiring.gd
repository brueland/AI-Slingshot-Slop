extends GutTest
# Task 044: main.gd plays sound effects for game events: launch, bounce, star, spring, boost, buy, milestone.
# The test fires the session's signals directly, as the flight would.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_044_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func _main():
	if not ResourceLoader.exists(SCENE):
		fail_test("missing " + SCENE)
		return null
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	if main.get("audio") == null:
		fail_test("main.audio missing (task 043)")
		return null
	return main


func test_launch_and_flight_events() -> void:
	var main = _main()
	if main == null:
		return
	main.progress.levels = {"boosts": 1}
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	assert_eq(main.audio.last_sfx, "launch")
	main.session.sim.bounced.emit(6.0)
	assert_eq(main.audio.last_sfx, "bounce")
	main.session.tracker.star_collected.emit(0)
	assert_eq(main.audio.last_sfx, "star")
	assert_false(main.course_view.sprites[0].visible, "the star sprite still hides")
	main.session.tracker.spring_hit.emit(1)
	assert_eq(main.audio.last_sfx, "spring")
	main.advance(1.0 / 60.0)
	main.request_boost()
	assert_eq(main.audio.last_sfx, "boost")


func test_milestone_and_buy() -> void:
	var main = _main()
	if main == null:
		return
	main.progress.levels = {"power": 2}
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	assert_false(main.last_result.get("milestones", []).is_empty(), "an 80 m first run reaches First Flight")
	assert_eq(main.audio.last_sfx, "milestone")
	main.continue_to_shop()
	main.progress.add_coins(1000)
	main.buy_upgrade("height")
	assert_eq(main.audio.last_sfx, "buy")


func test_each_run_wires_its_own_session() -> void:
	var main = _main()
	if main == null:
		return
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	main.continue_to_shop()
	main.leave_shop()
	var before: int = main.audio.sfx_played
	main.session.tracker.spring_hit.emit(0)
	assert_eq(main.audio.sfx_played, before + 1, "exactly one sound per event on the new session")
