extends GutTest
# Task 068: a Stats button on the title screen opens the stats panel (built by UiRoot, themed, centered) with the
# player's current progress; Close hides it.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_068_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func test_stats_button_opens_the_stats() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	var tp = main.title_panel
	assert_true(tp.get("stats_button") is Button, "title_panel.stats_button")
	assert_true(main.get("stats_panel") != null, "main.stats_panel")
	if not tp.get("stats_button") is Button or main.get("stats_panel") == null:
		return
	assert_eq(tp.stats_button.text, "Stats")
	assert_eq(main.stats_panel, main.ui_layer.stats_panel, "built by UiRoot")
	assert_eq(main.stats_panel.theme, main.ui_theme, "themed like every panel")
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	main.go_to_title()
	assert_false(main.stats_panel.visible)
	tp.stats_button.pressed.emit()
	assert_true(main.stats_panel.visible)
	assert_eq(main.stats_panel.runs_label.text, "Runs: 1")
	assert_eq(main.stats_panel.chart.values.size(), 1, "the chart shows the run")
	await wait_process_frames(3)
	var screen: Rect2 = main.get_viewport().get_visible_rect()
	var r: Rect2 = main.stats_panel.get_global_rect()
	assert_true(screen.encloses(r), "on screen: %s" % r)
	assert_lt((r.get_center() - screen.get_center()).length(), 4.0, "centered")
	assert_true(r.size.y <= 720.0, "fits a 720 px screen")
	main.stats_panel.close_button.pressed.emit()
	assert_false(main.stats_panel.visible)
