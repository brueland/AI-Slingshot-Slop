extends GutTest
# Task 115: the Wardrobe shows the alien (a bobbing TitleMascot) wearing the hat that is on, under its title.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_115_save.json"


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func test_preview_wears_the_hat() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	var panel = main.wardrobe_panel
	assert_true(panel.get("preview") is TitleMascot, "wardrobe_panel.preview")
	if not panel.get("preview") is TitleMascot:
		return
	assert_eq(panel.preview.get_index(), panel.title_label.get_index() + 1, "right under the title")
	main.title_panel.wardrobe_button.pressed.emit()
	assert_eq(panel.preview.decor.hat, "none")
	main.progress.total_runs = 1
	main.title_panel.wardrobe_button.pressed.emit()
	panel.hat_buttons["party"].pressed.emit()
	assert_eq(panel.preview.decor.hat, "party", "the preview puts the new hat on")
	await wait_process_frames(3)
	assert_true(main.get_viewport().get_visible_rect().encloses(panel.get_global_rect()), "the wardrobe still fits on screen")
