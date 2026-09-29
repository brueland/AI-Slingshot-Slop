extends GutTest
# Regression: every menu and HUD element is fully on screen, and the menus are centered, in every state.
# (Centered panels must use set_anchors_and_offsets_preset; set_anchors_preset keeps the old top-left
# position and pushed the menus off the screen.)

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_ui_on_screen_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func _main():
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	return main


func _screen(main) -> Rect2:
	return main.get_viewport().get_visible_rect()


func _assert_on_screen(main, control: Control, what: String) -> void:
	var screen := _screen(main)
	var r := control.get_global_rect()
	assert_true(control.is_visible_in_tree(), what + " is visible")
	assert_true(screen.encloses(r), "%s must be fully on screen: %s not inside %s" % [what, r, screen])
	var design := Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height"))
	assert_true(r.size.x <= design.x and r.size.y <= design.y,
		"%s (%s) must fit the %s design resolution" % [what, r.size, design])


func _assert_centered(main, control: Control, what: String) -> void:
	_assert_on_screen(main, control, what)
	var d := control.get_global_rect().get_center() - _screen(main).get_center()
	assert_lt(d.length(), 4.0, "%s must be centered (off by %s)" % [what, d])


func test_title_options_and_credits() -> void:
	var main = _main()
	await wait_process_frames(3)
	_assert_centered(main, main.title_panel, "title panel")
	main.title_panel.options_button.pressed.emit()
	await wait_process_frames(2)
	_assert_centered(main, main.options_panel, "options panel")
	main.options_panel.close_button.pressed.emit()
	main.title_panel.credits_button.pressed.emit()
	await wait_process_frames(2)
	_assert_centered(main, main.credits_panel, "credits panel")


func test_hud_and_pause_while_flying() -> void:
	var main = _main()
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	await wait_process_frames(3)
	for key in ["distance_label", "height_label", "stars_label", "boosts_label", "best_label", "coins_label", "goal_label"]:
		_assert_on_screen(main, main.hud.get(key), "HUD " + key)
	assert_gt(main.hud.best_label.get_global_rect().position.x, _screen(main).size.x * 0.5,
		"best/coins/next goal sit on the right side")
	main.toggle_pause()
	await wait_process_frames(2)
	_assert_centered(main, main.pause_label, "pause label")


func test_results_shop_and_victory() -> void:
	var main = _main()
	var levels := {}
	for id in load("res://scripts/core/upgrade_catalog.gd").ids():
		levels[id] = 99
	main.progress.levels = levels
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	for i in 30000:
		if main.state_name() != "FLIGHT":
			break
		if main.session.sim.velocity.y < 0.0:
			main.request_boost()
		main.advance(1.0 / 60.0)
	await wait_process_frames(3)
	_assert_centered(main, main.victory_panel, "victory panel")
	main.victory_panel.continue_button.pressed.emit()
	await wait_process_frames(3)
	_assert_centered(main, main.shop_panel, "shop panel")
	main.shop_panel.launch_button.pressed.emit()
	main.launch_with_pull(FULL_PULL_45)
	for i in 30000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	await wait_process_frames(3)
	_assert_centered(main, main.results_panel, "results panel")
