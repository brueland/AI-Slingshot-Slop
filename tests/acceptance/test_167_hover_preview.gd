extends GutTest
# Task 167: in the Wardrobe, hovering an unlocked hat's button shows it on the preview; leaving shows the worn hat again.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_167_save.json"


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


## A classic shot where two balloons count as popped and three sheep as woken, flown to the end.
func _busy_shot(main) -> void:
	main.launch_with_pull(Vector2(-84.852814, 84.852814))
	main.advance(1.0 / 60.0)
	main.session.balloons.popped_count = 2
	main.feedback.sheep_woken_run = 3
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)


func test_hover_preview() -> void:
	var main = _main()
	main.progress.total_runs = 1
	main.title_panel.wardrobe_button.pressed.emit()
	var panel = main.wardrobe_panel
	assert_eq(panel.worn, "none")
	panel.hat_buttons["party"].mouse_entered.emit()
	assert_eq(panel.preview.decor.hat, "party", "hovering tries the hat on")
	panel.hat_buttons["party"].mouse_exited.emit()
	assert_eq(panel.preview.decor.hat, "none", "leaving shows the worn hat again")
	panel.hat_buttons["crown"].mouse_entered.emit()
	assert_eq(panel.preview.decor.hat, "none", "a locked hat is not shown")
	panel.hat_buttons["party"].pressed.emit()
	assert_eq(panel.worn, "party")
	panel.hat_buttons["none"].mouse_entered.emit()
	panel.hat_buttons["none"].mouse_exited.emit()
	assert_eq(panel.preview.decor.hat, "party", "back to the newly worn hat")
