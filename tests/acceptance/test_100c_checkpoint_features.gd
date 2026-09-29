extends GutTest
# Checkpoint 10 (task 100c): the milestone 10 features work together with real frames: a strong classic shot pops
# a balloon, the next shot shows its ghost and R repeats it exactly, the pause menu resumes a flight, a daily run
# can reroll its perks, and the title mascot bobs with its hat.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_100c_save.json"
const DAY := {"year": 2026, "month": 9, "day": 29}
const NEW_SCRIPTS := {
	"res://scripts/core/balloons.gd": "Balloons",
	"res://scripts/game/balloon_view.gd": "BalloonView",
	"res://scripts/game/ghost_path.gd": "GhostPath",
	"res://scripts/core/daily.gd": "Daily",
	"res://scripts/ui/pause_menu.gd": "PauseMenu",
	"res://scripts/ui/title_mascot.gd": "TitleMascot",
	"res://scripts/game/star_field.gd": "StarField",
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


## A full-strength pull whose shot pops at least one balloon with these stats and course seed.
func _balloon_pull(stats, course_seed: int) -> Vector2:
	for a in range(10, 80):
		var r := deg_to_rad(float(a))
		var pull := Vector2(-cos(r), sin(r)) * Balance.MAX_PULL_PX
		var s := RunSession.new(stats, course_seed)
		s.launch_from_pull(pull)
		while not s.is_finished():
			s.step(1.0 / 60.0)
		if int(s.result().get("balloons", 0)) > 0:
			return pull
	return Vector2.ZERO


func test_classic_features_with_real_frames() -> void:
	var main = _main()
	main.progress.levels = {"power": 5, "aero": 3, "guide": 1}
	main.progress.total_runs = 1
	await wait_process_frames(2)
	main.title_panel.play_button.pressed.emit()
	var pull := _balloon_pull(main.session.stats, main.progress.total_runs + 1)
	assert_ne(pull, Vector2.ZERO, "some shot pops a balloon")
	var anchor: Vector2 = main.slingshot.global_position
	main.slingshot.begin_drag(anchor)
	main.slingshot.update_drag(anchor + pull)
	await wait_process_frames(2)
	main.slingshot.release()
	var launch_velocity: Vector2 = main.session.sim.velocity
	main.advance(1.0 / 60.0)
	main.toggle_pause()
	assert_true(main.ui_layer.pause_menu.visible, "the pause menu")
	await wait_process_frames(2)
	main.ui_layer.pause_menu.resume_button.pressed.emit()
	assert_false(main.is_paused)
	_fly(main)
	assert_gt(int(main.last_result.get("balloons", 0)), 0, "popped a balloon")
	assert_lt(main.balloon_view.visible_count(), main.balloon_view.points.size(), "the popped balloon is gone")
	main.continue_to_shop()
	main.leave_shop()
	assert_gt(main.ghost.points.size(), 5, "the ghost of the best run")
	assert_eq(main.hud.hint_label.text, "Press R to repeat your last shot")
	await wait_process_frames(2)
	var key := InputEventKey.new()
	key.keycode = KEY_R
	key.pressed = true
	main.slingshot._unhandled_input(key)
	assert_eq(main.state_name(), "FLIGHT", "R repeated the shot")
	assert_eq(main.session.sim.velocity, launch_velocity, "with exactly the same launch")
	_fly(main)


func test_daily_run_with_a_reroll() -> void:
	var main = _main()
	main.start_daily(DAY)
	assert_eq(main.rogue.run_seed, 20260929)
	main.launch_with_pull(Vector2(-84.852814, 84.852814))
	_fly(main)
	var panel = main.ui_layer.rogue_panel
	await wait_process_frames(2)
	assert_true(panel.visible)
	var before: Array = main.rogue.offer.duplicate()
	panel.reroll_button.pressed.emit()
	assert_ne(main.rogue.offer, before)
	var pick: String = main.rogue.offer[2]
	panel.perk_buttons[2].pressed.emit()
	assert_true(main.rogue.has_perk(pick))
	assert_eq(main.state_name(), "AIM")
	assert_eq(main.ghost.points.size(), 0, "no ghost in the roguelike")


func test_title_mascot_with_real_frames() -> void:
	var first = _main()
	first.progress.total_runs = 1
	first.choose_hat("party")
	var main = _main()
	var mascot = main.title_panel.mascot
	assert_eq(mascot.decor.hat, "party")
	var y0: float = mascot.center().y
	await wait_seconds(0.3)
	assert_ne(mascot.center().y, y0, "it bobs")
	assert_true(main.get_viewport().get_visible_rect().encloses(main.title_panel.get_global_rect()))


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


func test_progress_log_records_milestone_10() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 10: complete"), "add the line 'Milestone 10: complete' to docs/PROGRESS.md")
