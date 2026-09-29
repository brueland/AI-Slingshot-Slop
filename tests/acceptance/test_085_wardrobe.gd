extends GutTest
# Task 085: a Wardrobe screen (title button) lists the hats; unlocked ones can be worn, locked ones say how to
# unlock them. The chosen hat is saved and worn by the alien.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_085_save.json"
const PANEL := "res://scripts/ui/wardrobe_panel.gd"


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


func test_parts_exist() -> void:
	if not ResourceLoader.exists(PANEL):
		fail_test("missing file " + PANEL)
		return
	var main = _main()
	assert_true(main.title_panel.get("wardrobe_button") is Button, "title_panel.wardrobe_button")
	assert_eq(main.title_panel.wardrobe_button.text, "Wardrobe")
	var panel = main.get("wardrobe_panel")
	assert_not_null(panel, "main.wardrobe_panel")
	if panel == null:
		return
	assert_eq(panel, main.ui_layer.wardrobe_panel)
	assert_eq(panel.get_script().resource_path, PANEL)
	assert_eq(panel.theme, main.ui_theme)
	assert_false(panel.visible)
	assert_eq(panel.title_label.text, "Wardrobe")
	assert_eq(panel.hat_buttons.size(), 7)
	assert_eq(panel.close_button.text, "Done")


func test_choose_a_hat() -> void:
	if not ResourceLoader.exists(PANEL):
		fail_test("missing file " + PANEL)
		return
	var main = _main()
	main.title_panel.wardrobe_button.pressed.emit()
	var panel = main.wardrobe_panel
	assert_true(panel.visible)
	assert_eq(panel.hat_buttons["none"].text, "No hat (wearing)")
	assert_true(panel.hat_buttons["party"].disabled)
	assert_eq(panel.hat_buttons["party"].text, "Locked - Finish your first run")
	assert_false(main.choose_hat("party"), "locked hats cannot be worn")
	main.progress.total_runs = 1
	main.title_panel.wardrobe_button.pressed.emit()
	assert_false(panel.hat_buttons["party"].disabled)
	assert_eq(panel.hat_buttons["party"].text, "Party Hat")
	panel.hat_buttons["party"].pressed.emit()
	assert_eq(main.progress.hat, "party")
	assert_eq(main.projectile_view.decor.hat, "party", "the alien wears it")
	assert_eq(panel.hat_buttons["party"].text, "Party Hat (wearing)")
	assert_eq(panel.hat_buttons["none"].text, "No hat")
	var saved = JSON.parse_string(FileAccess.get_file_as_string(SAVE))
	assert_true(saved is Dictionary and saved.get("hat") == "party", "saved")
	await wait_process_frames(3)
	var screen: Rect2 = main.get_viewport().get_visible_rect()
	assert_true(screen.encloses(panel.get_global_rect()), "on screen")
	assert_lt((panel.get_global_rect().get_center() - screen.get_center()).length(), 4.0, "centered")
	panel.close_button.pressed.emit()
	assert_false(panel.visible)


func test_the_hat_survives_a_restart_and_a_reset() -> void:
	var first = _main()
	first.progress.total_runs = 1
	first.choose_hat("party")
	var second = _main()
	assert_eq(second.progress.hat, "party")
	assert_eq(second.projectile_view.decor.hat, "party", "worn right away after loading")
	second.reset_progress()
	assert_eq(second.projectile_view.decor.hat, "none", "a reset takes the hat off")
