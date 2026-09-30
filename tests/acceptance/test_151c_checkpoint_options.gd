extends GutTest
# Checkpoint 17 (task 151c): options and classic extras work together with real frames: turning screen shake off in
# Options survives a restart, the title shows today's challenge above the tip, and a combo lands on the Stats screen.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_151c_save.json"


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


func test_options_and_extras_with_real_frames() -> void:
	var main = _main()
	await wait_process_frames(2)
	assert_true(main.ui_layer.challenge_label.visible)
	assert_true(main.ui_layer.challenge_label.text.begins_with("Today's challenge: "))
	main.title_panel.options_button.pressed.emit()
	main.options_panel.shake_check.toggled.emit(false)
	main.options_panel.close_button.pressed.emit()
	main.start_game()
	main.launch_with_pull(Vector2(-84.852814, 84.852814))
	main.advance(1.0 / 60.0)
	main.session.tracker.spring_hit.emit(0)
	assert_false(main.camera.is_shaking(), "no shake with the option off")
	main.feedback.add_combo()
	main.feedback.add_combo()
	await wait_process_frames(2)
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	assert_gt(main.progress.best_combo, 2)
	main.go_to_title()
	main.title_panel.stats_button.pressed.emit()
	await wait_process_frames(2)
	assert_eq(main.stats_panel.combo_label.text, "Best combo: x%d" % main.progress.best_combo)
	var again = _main()
	assert_false(again.camera.shake_enabled, "the option survives a restart")


func test_main_stays_small() -> void:
	var main_text := FileAccess.get_file_as_string("res://scripts/game/main.gd")
	assert_lt(main_text.split("\n").size(), 450, "main.gd stays under 450 lines")


func test_progress_log_records_milestone_17() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 17: complete"), "add the line 'Milestone 17: complete' to docs/PROGRESS.md")
