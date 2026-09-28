extends GutTest
# Checkpoint 4 (task 040c): the whole game loop works through the UI, with real frames: title -> aim -> flight
# -> results -> shop -> next run, saving and reloading, pause, and victory. Also checks UI conventions.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_040c_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)
const UI_SCRIPTS := {
	"res://scripts/ui/hud.gd": "Hud",
	"res://scripts/ui/results_panel.gd": "ResultsPanel",
	"res://scripts/ui/shop_panel.gd": "ShopPanel",
	"res://scripts/ui/title_panel.gd": "TitlePanel",
	"res://scripts/ui/victory_panel.gd": "VictoryPanel",
	"res://scripts/game/background.gd": "SkyBackground",
}


func _remove() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func before_each() -> void:
	_remove()


func after_each() -> void:
	_remove()


func _main():
	if not ResourceLoader.exists(SCENE):
		fail_test("missing " + SCENE)
		return null
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	return main


## Drags the slingshot like a player and flies until the run ends. Returns the final state name.
func _shoot(main, boost: bool = false) -> String:
	var anchor: Vector2 = main.slingshot.global_position
	main.slingshot.begin_drag(anchor)
	main.slingshot.update_drag(anchor + FULL_PULL_45)
	main.advance(1.0 / 60.0)
	main.slingshot.release()
	for i in 30000:
		if main.state_name() != "FLIGHT":
			break
		if boost and main.session.sim.velocity.y < 0.0:
			main.request_boost()
		main.advance(1.0 / 60.0)
	return main.state_name()


func test_two_runs_through_the_ui_with_real_frames() -> void:
	var main = _main()
	if main == null:
		return
	await wait_process_frames(2)
	assert_true(main.title_panel.visible)
	main.title_panel.play_button.pressed.emit()
	await wait_process_frames(2)
	assert_eq(_shoot(main), "RESULTS")
	await wait_process_frames(2)
	main.results_panel.continue_button.pressed.emit()
	assert_eq(main.state_name(), "SHOP")
	await wait_process_frames(2)
	var coins_before: int = main.progress.coins
	assert_gt(coins_before, 25, "the first run pays coins")
	main.shop_panel.buttons["guide"].pressed.emit()
	assert_eq(main.progress.level_of("guide"), 1, "Aim Guide costs 25")
	assert_eq(main.progress.coins, coins_before - 25)
	main.shop_panel.launch_button.pressed.emit()
	assert_eq(main.state_name(), "AIM")
	assert_eq(main.session.stats.guide_points, 12)
	assert_eq(_shoot(main), "RESULTS")
	assert_eq(main.progress.total_runs, 2)


func test_progress_survives_a_restart() -> void:
	var first = _main()
	if first == null:
		return
	first.start_game()
	_shoot(first)
	first.continue_to_shop()
	first.progress.add_coins(500)
	first.buy_upgrade("power")
	var coins: int = first.progress.coins
	var best: float = first.progress.best_distance
	var second = load(SCENE).instantiate()
	second.save_path = SAVE
	add_child_autofree(second)
	assert_eq(second.progress.coins, coins)
	assert_eq(second.progress.level_of("power"), 1)
	assert_eq(second.progress.total_runs, 1)
	assert_almost_eq(second.progress.best_distance, best, 0.001)
	assert_eq(second.state_name(), "TITLE", "a restart begins on the title screen")


func test_pause_and_victory() -> void:
	var main = _main()
	if main == null:
		return
	var levels := {}
	for id in load("res://scripts/core/upgrade_catalog.gd").ids():
		levels[id] = 99
	main.progress.levels = levels
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	main.toggle_pause()
	var x: float = main.session.sim.position.x
	await wait_physics_frames(5)
	assert_eq(main.session.sim.position.x, x, "paused: real frames don't move the flight")
	main.toggle_pause()
	for i in 30000:
		if main.state_name() != "FLIGHT":
			break
		if main.session.sim.velocity.y < 0.0:
			main.request_boost()
		main.advance(1.0 / 60.0)
	assert_eq(main.state_name(), "VICTORY")
	await wait_process_frames(2)
	main.victory_panel.continue_button.pressed.emit()
	assert_eq(main.state_name(), "SHOP")


func test_hud_never_blocks_the_slingshot() -> void:
	var main = _main()
	if main == null:
		return
	assert_eq(main.hud.mouse_filter, Control.MOUSE_FILTER_IGNORE)


func test_ui_scripts_follow_the_conventions() -> void:
	for path in UI_SCRIPTS:
		if not ResourceLoader.exists(path):
			fail_test("missing file " + path)
			continue
		var text := FileAccess.get_file_as_string(path)
		assert_true(text.contains("class_name " + UI_SCRIPTS[path]), "%s must declare class_name %s" % [path, UI_SCRIPTS[path]])
		assert_lt(text.split("\n").size(), 300, path + " must stay under 300 lines")
		assert_false(text.contains("print("), path + " must not print")
	var main_text := FileAccess.get_file_as_string("res://scripts/game/main.gd")
	assert_lt(main_text.split("\n").size(), 450, "main.gd must stay under 450 lines")
	assert_false(main_text.contains("get_tree().paused"), "pause with is_paused, not the scene tree")


func test_progress_log_records_milestone_4() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 4: complete"),
		"add the line 'Milestone 4: complete' to docs/PROGRESS.md")
