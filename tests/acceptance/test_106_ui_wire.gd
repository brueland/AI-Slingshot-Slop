extends GutTest
# Task 106 (refactor): UiRoot.wire(main) connects every screen's buttons to main.gd, so main.gd gets shorter (room
# for milestone 12). Behavior must not change: every existing button test keeps passing.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_106_save.json"


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func test_ui_root_wires_main() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	var ui = main.ui_layer
	assert_true(ui.has_method("wire"), "UiRoot.wire(main)")
	assert_true(ui.title_panel.play_pressed.is_connected(Callable(main, "start_game")))
	assert_true(ui.title_panel.daily_pressed.is_connected(Callable(main, "start_daily")))
	assert_true(ui.shop_panel.purchase_requested.is_connected(Callable(main, "buy_upgrade")))
	assert_true(ui.rogue_panel.perk_chosen.is_connected(Callable(main, "choose_rogue_perk")))
	assert_true(ui.pause_menu.quit_pressed.is_connected(Callable(main, "go_to_title")))
	assert_true(ui.options_panel.volume_changed.is_connected(Callable(main, "_on_volume_changed")))
	main.reset_progress()
	main.progress.total_runs = 1
	ui.title_panel.wardrobe_pressed.emit()
	assert_false(ui.wardrobe_panel.hat_buttons["party"].disabled, "the wardrobe uses main's current progress")
	ui.title_panel.play_button.pressed.emit()
	assert_eq(main.state_name(), "AIM", "Play still starts a game")


func test_main_is_shorter() -> void:
	var text := FileAccess.get_file_as_string("res://scripts/game/main.gd")
	for moved in ["continue_pressed.connect", "purchase_requested.connect", "play_pressed.connect",
			"perk_chosen.connect", "pause_menu.resume_pressed", "volume_changed.connect"]:
		assert_false(text.contains(moved), "main.gd must not contain '%s' (UiRoot.wire does it)" % moved)
	assert_true(text.contains("ui_layer.wire(self)"))
