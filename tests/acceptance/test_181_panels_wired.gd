extends GutTest
# Task 181: UiRoot builds the How to play and Achievements panels and wires the title's new buttons to them.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_181_save.json"
const PULL := Vector2(-84.852814, 84.852814)


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


func test_panels_wired() -> void:
	var main = _main()
	var ui = main.ui_layer
	assert_true(ui.get("help_panel") is HelpPanel, "ui_layer.help_panel")
	assert_true(ui.get("achievements_panel") is AchievementsPanel, "ui_layer.achievements_panel")
	if not ui.get("help_panel") is HelpPanel or not ui.get("achievements_panel") is AchievementsPanel:
		return
	assert_eq(ui.help_panel.theme, ui.ui_theme, "themed like the other screens")
	main.title_panel.help_button.pressed.emit()
	assert_true(ui.help_panel.visible)
	await wait_process_frames(3)
	assert_true(main.get_viewport().get_visible_rect().encloses(ui.help_panel.get_global_rect()), "fits on screen")
	ui.help_panel.close_button.pressed.emit()
	assert_false(ui.help_panel.visible)
	main.progress.achievements.append("liftoff")
	main.title_panel.achievements_button.pressed.emit()
	assert_true(ui.achievements_panel.visible)
	assert_eq(ui.achievements_panel.count_label.text, "1 of %d earned" % Achievements.LIST.size(), "main's progress")
	await wait_process_frames(3)
	assert_true(main.get_viewport().get_visible_rect().encloses(ui.achievements_panel.get_global_rect()), "fits on screen")
	ui.achievements_panel.close_button.pressed.emit()
	assert_false(ui.achievements_panel.visible)
