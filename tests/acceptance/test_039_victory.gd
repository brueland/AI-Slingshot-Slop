extends GutTest
# Task 039: the first run that reaches GOAL_DISTANCE (1000 m) goes to the VICTORY state with
# scripts/ui/victory_panel.gd; its button leads to the shop. Later long runs go to RESULTS as usual.

const PATH := "res://scripts/ui/victory_panel.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_039_save.json"
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
	return main


func _max_levels() -> Dictionary:
	var levels := {}
	for id in load("res://scripts/core/upgrade_catalog.gd").ids():
		levels[id] = 99
	return levels


## Full-strength shot with boosts when falling. Returns the state after the run.
func _long_run(main) -> String:
	main.launch_with_pull(FULL_PULL_45)
	for i in 30000:
		if main.state_name() != "FLIGHT":
			break
		if main.session.sim.velocity.y < 0.0:
			main.request_boost()
		main.advance(1.0 / 60.0)
	return main.state_name()


func test_victory_panel() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var v = load(PATH).new()
	add_child_autofree(v)
	watch_signals(v)
	assert_true(v is PanelContainer)
	assert_false(v.visible)
	v.show_victory(37)
	assert_true(v.visible)
	assert_eq(v.message_label.text, "You reached 1000 m in 37 runs!")
	v.continue_button.pressed.emit()
	assert_signal_emitted(v, "continue_pressed")


func test_first_goal_run_is_a_victory() -> void:
	var main = _main()
	if main == null:
		return
	main.progress.levels = _max_levels()
	main.progress.total_runs = 36
	main.start_game()
	assert_eq(_long_run(main), "VICTORY")
	assert_true(main.progress.goal_reached)
	var vp = main.get("victory_panel")
	assert_not_null(vp, "main.victory_panel")
	if vp == null:
		return
	assert_true(vp.visible)
	assert_eq(vp.message_label.text, "You reached 1000 m in 37 runs!")
	vp.continue_button.pressed.emit()
	assert_eq(main.state_name(), "SHOP")
	assert_false(vp.visible)
	main.leave_shop()
	assert_eq(_long_run(main), "RESULTS", "only the first goal run is a victory")
