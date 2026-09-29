extends GutTest
# Task 080: the roguelike is playable from the UI: a Roguelike button on the title, the HUD shows round, lives and
# goal, the perk panel appears after each shot (its buttons pick perks), and the run-over panel leads back to
# the title. Both panels are built by UiRoot, themed and centered.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_080_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


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


func test_ui_parts_exist() -> void:
	var main = _main()
	assert_true(main.title_panel.get("rogue_button") is Button, "title_panel.rogue_button")
	assert_true(main.ui_layer.get("rogue_panel") != null, "ui_layer.rogue_panel")
	assert_true(main.ui_layer.get("rogue_over_panel") != null, "ui_layer.rogue_over_panel")
	if main.ui_layer.get("rogue_panel") == null or main.ui_layer.get("rogue_over_panel") == null:
		return
	assert_eq(main.title_panel.rogue_button.text, "Roguelike")
	assert_eq(main.ui_layer.rogue_panel.theme, main.ui_theme)
	assert_eq(main.ui_layer.rogue_over_panel.theme, main.ui_theme)
	assert_false(main.ui_layer.rogue_panel.visible)
	assert_false(main.ui_layer.rogue_over_panel.visible)


func test_play_a_roguelike_run_from_the_ui() -> void:
	var main = _main()
	if main.title_panel.get("rogue_button") == null:
		fail_test("title_panel.rogue_button missing")
		return
	main.title_panel.rogue_button.pressed.emit()
	assert_eq(main.mode, "rogue")
	assert_eq(main.state_name(), "AIM")
	assert_eq(main.hud.best_label.text, "Round 1")
	assert_eq(main.hud.coins_label.text, "Lives: 3")
	assert_eq(main.hud.goal_label.text, "Goal: Fly at least 40 m")
	main.launch_with_pull(FULL_PULL_45)
	_fly(main)
	var panel = main.ui_layer.rogue_panel
	assert_true(panel.visible, "the perk panel after the shot")
	assert_false(main.results_panel.visible)
	assert_eq(panel.title_label.text, "Goal met!")
	await wait_process_frames(3)
	var screen: Rect2 = main.get_viewport().get_visible_rect()
	assert_true(screen.encloses(panel.get_global_rect()), "perk panel on screen")
	var pick: String = main.rogue.offer[1]
	panel.perk_buttons[1].pressed.emit()
	assert_eq(main.state_name(), "AIM")
	assert_true(main.rogue.has_perk(pick))
	assert_false(panel.visible)
	assert_eq(main.hud.best_label.text, "Round 2")


func test_run_over_leads_back_to_the_title() -> void:
	var main = _main()
	main.start_rogue(7)
	main.rogue.lives = 1
	main.rogue.rounds_cleared = 2
	main.launch_with_pull(Vector2(-12, 0))
	_fly(main)
	var over = main.ui_layer.rogue_over_panel
	assert_true(over.visible, "run over")
	assert_false(main.ui_layer.rogue_panel.visible)
	assert_eq(over.rounds_label.text, "Rounds cleared: 2")
	await wait_process_frames(3)
	assert_true(main.get_viewport().get_visible_rect().encloses(over.get_global_rect()), "over panel on screen")
	over.back_button.pressed.emit()
	assert_eq(main.state_name(), "TITLE")
	assert_eq(main.mode, "classic")
	assert_false(over.visible)
	assert_true(main.title_panel.visible)


func test_classic_results_do_not_show_rogue_panels() -> void:
	var main = _main()
	main.start_game()
	assert_eq(main.hud.coins_label.text, "Coins: 0", "classic HUD labels unchanged")
	assert_eq(main.hud.best_label.text, "Best: 0 m")
	main.launch_with_pull(FULL_PULL_45)
	_fly(main)
	assert_true(main.results_panel.visible)
	assert_false(main.ui_layer.rogue_panel.visible)
	assert_false(main.ui_layer.rogue_over_panel.visible)
