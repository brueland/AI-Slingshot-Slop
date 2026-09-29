extends GutTest
# Checkpoint 7 (task 070c): the player-experience features work together with real frames: fades, hints, the
# best flag, lifetime stats, the stats screen, achievements and toasts, and everything survives a restart.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_070c_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)
const NEW_SCRIPTS := {
	"res://scripts/ui/ui_root.gd": "UiRoot",
	"res://scripts/ui/fader.gd": "Fader",
	"res://scripts/ui/distance_chart.gd": "DistanceChart",
	"res://scripts/ui/stats_panel.gd": "StatsPanel",
	"res://scripts/ui/toast.gd": "Toast",
	"res://scripts/core/achievements.gd": "Achievements",
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


func test_first_session_with_real_frames() -> void:
	var main = _main()
	await wait_process_frames(2)
	main.title_panel.play_button.pressed.emit()
	assert_true(main.hud.hint_label.visible, "the first shot explains how to aim")
	await wait_seconds(0.5)
	assert_almost_eq(main.fader.alpha(), 0.0, 0.001, "the fade finished on its own")
	var anchor: Vector2 = main.slingshot.global_position
	main.slingshot.begin_drag(anchor)
	main.slingshot.update_drag(anchor + FULL_PULL_45)
	await wait_process_frames(2)
	main.slingshot.release()
	_fly(main)
	assert_eq(main.state_name(), "RESULTS")
	assert_true(main.toast.visible, "Liftoff is announced")
	await wait_seconds(3.3)
	assert_false(main.toast.visible, "the toast went away by itself")
	main.go_to_title()
	main.title_panel.stats_button.pressed.emit()
	await wait_process_frames(2)
	assert_true(main.stats_panel.visible)
	assert_eq(main.stats_panel.runs_label.text, "Runs: 1")
	main.stats_panel.close_button.pressed.emit()
	main.title_panel.play_button.pressed.emit()
	assert_true(main.course_view.best_marker.visible, "the second shot shows the best flag")
	assert_false(main.hud.hint_label.visible, "no aim hint after the first run")


func test_everything_survives_a_restart() -> void:
	var first = _main()
	first.start_game()
	first.launch_with_pull(FULL_PULL_45)
	_fly(first)
	var distance: float = first.progress.lifetime["distance"]
	var second = _main()
	assert_almost_eq(float(second.progress.lifetime["distance"]), distance, 0.001)
	assert_eq(second.progress.recent_distances.size(), 1)
	assert_true(second.progress.achievements.has("liftoff"))
	second.start_game()
	assert_true(second.course_view.best_marker.visible)


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


func test_progress_log_records_milestone_7() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 7: complete"), "add the line 'Milestone 7: complete' to docs/PROGRESS.md")
