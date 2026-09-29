extends GutTest
# Task 087: little mood effects above the alien: a surprised "!" on a star, dizzy stars after 3 bounces in a run,
# and sleepy "z"s once it stops. Timed moods end by themselves; a new shot starts with no mood.

const DECOR := "res://scripts/game/projectile_decor.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_087_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func _main():
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	return main


func test_decor_moods() -> void:
	var d = load(DECOR).new()
	add_child_autofree(d)
	assert_eq(d.MOODS, ["", "dizzy", "wow", "sleepy"])
	assert_eq(d.mood, "")
	d.set_mood("wow", 0.8)
	assert_eq(d.mood, "wow")
	d.advance(0.5)
	assert_eq(d.mood, "wow")
	d.advance(0.4)
	assert_eq(d.mood, "", "a timed mood ends by itself")
	d.set_mood("sleepy")
	d.advance(10.0)
	assert_eq(d.mood, "sleepy", "0 seconds means until changed")
	d.set_mood("grumpy", 1.0)
	assert_eq(d.mood, "sleepy", "unknown moods are ignored")
	for m in ["dizzy", "wow", "sleepy"]:
		d.set_mood(m, 1.0)
		await wait_process_frames(2)
	pass_test("every mood draws without errors")


func test_flight_events_set_moods() -> void:
	var main = _main()
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	main.advance(1.0 / 60.0)
	var decor = main.projectile_view.decor
	main.session.tracker.star_collected.emit(0)
	assert_eq(decor.mood, "wow", "a star surprises the alien")
	main.session.sim.bounced.emit(5.0)
	main.session.sim.bounced.emit(5.0)
	assert_eq(decor.mood, "wow", "two bounces are fine")
	main.session.sim.bounced.emit(5.0)
	assert_eq(decor.mood, "dizzy", "the third bounce makes it dizzy")
	assert_almost_eq(decor.mood_left, 2.0, 0.0001)


func test_sleepy_after_the_run_and_fresh_next_shot() -> void:
	var main = _main()
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	assert_eq(main.state_name(), "RESULTS")
	assert_eq(main.projectile_view.decor.mood, "sleepy", "resting after the run")
	main.continue_to_shop()
	main.leave_shop()
	assert_eq(main.projectile_view.decor.mood, "", "a new shot starts with no mood")
