extends GutTest
# Task 081 (refactor): UiRoot.refresh(main) shows the screens for main's state and AudioManager.music_for_state
# picks the music, so main.gd gets shorter (room for milestone 9). Behavior must not change: every existing
# screen, HUD and music test keeps passing.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_081_save.json"
const AUDIO := "res://scripts/game/audio_manager.gd"


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func test_music_for_state() -> void:
	var a = load(AUDIO)
	assert_eq(a.music_for_state("TITLE"), "menu")
	assert_eq(a.music_for_state("AIM"), "flight")
	assert_eq(a.music_for_state("FLIGHT"), "flight")
	assert_eq(a.music_for_state("RESULTS"), "menu")
	assert_eq(a.music_for_state("SHOP"), "menu")
	assert_eq(a.music_for_state("VICTORY"), "victory")


func test_ui_root_refreshes_from_main() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	assert_true(main.ui_layer.has_method("refresh"), "UiRoot.refresh(main)")
	main.start_game()
	main.title_panel.visible = true
	main.hud.visible = false
	main.ui_layer.refresh(main)
	assert_false(main.title_panel.visible, "refresh hides the title while aiming")
	assert_true(main.hud.visible, "and shows the HUD")
	assert_eq(main.hud.coins_label.text, "Coins: 0")
	assert_eq(main.audio.current_music, "flight")
	main.go_to_title()
	assert_true(main.title_panel.visible)
	assert_eq(main.audio.current_music, "menu")


func test_main_is_shorter() -> void:
	var text := FileAccess.get_file_as_string("res://scripts/game/main.gd")
	for moved in ["func _update_music", "results_panel.show_result", "victory_panel.show_victory",
			"hud.update_progress", "hud.show_rogue", "title_panel.show_progress"]:
		assert_false(text.contains(moved), "main.gd must not contain '%s' (UiRoot/AudioManager do it)" % moved)
