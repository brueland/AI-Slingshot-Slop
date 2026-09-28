extends GutTest
# Task 038: scripts/ui/title_panel.gd (game name, best distance, Play, Reset progress) and main.gd showing it
# on the title screen, with go_to_title() and reset_progress().

const PATH := "res://scripts/ui/title_panel.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_038_save.json"


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
	return main


func test_title_panel() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var t = load(PATH).new()
	add_child_autofree(t)
	watch_signals(t)
	assert_true(t is PanelContainer)
	assert_eq(t.title_label.text, "Slingshot Skies")
	assert_eq(t.play_button.text, "Play")
	assert_eq(t.reset_button.text, "Reset progress")
	t.show_progress(312.8, 9)
	assert_eq(t.best_label.text, "Best: 312 m in 9 runs")
	t.play_button.pressed.emit()
	assert_signal_emitted(t, "play_pressed")
	t.reset_button.pressed.emit()
	assert_signal_emitted(t, "reset_pressed")


func test_main_shows_the_title_and_play_starts() -> void:
	var main = _main()
	if main == null:
		return
	var tp = main.get("title_panel")
	assert_not_null(tp, "main.title_panel")
	if tp == null:
		return
	assert_eq(tp.get_parent(), main.ui_layer)
	assert_true(tp.visible)
	assert_false(main.hud.visible)
	tp.play_button.pressed.emit()
	assert_eq(main.state_name(), "AIM")
	assert_false(tp.visible)
	main.go_to_title()
	assert_eq(main.state_name(), "TITLE")
	assert_true(tp.visible)


func test_title_shows_progress_and_reset_clears_it() -> void:
	var main = _main()
	if main == null:
		return
	if main.get("title_panel") == null:
		fail_test("main.title_panel missing")
		return
	main.progress.coins = 500
	main.progress.best_distance = 120.0
	main.progress.total_runs = 3
	main.start_game()
	main.go_to_title()
	assert_eq(main.title_panel.best_label.text, "Best: 120 m in 3 runs")
	main.title_panel.reset_button.pressed.emit()
	assert_eq(main.progress.coins, 0)
	assert_eq(main.progress.total_runs, 0)
	assert_eq(main.title_panel.best_label.text, "Best: 0 m in 0 runs")
	var saved = JSON.parse_string(FileAccess.get_file_as_string(SAVE))
	assert_true(saved is Dictionary and int(saved.get("coins", -1)) == 0, "the reset is saved")
