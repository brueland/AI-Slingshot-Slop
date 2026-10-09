extends GutTest
# Task 313: the Wardrobe says what the worn hat gives, and what a hat gives while the mouse is over it.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_313_save.json"
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


func _fly(main, pull: Vector2) -> void:
	main.launch_with_pull(pull)
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)


func _on_screen(main, control: Control, what: String) -> void:
	assert_true(main.get_viewport().get_visible_rect().encloses(control.get_global_rect()), what + " is on screen")



func test_wardrobe_bonuses() -> void:
	var main = _main()
	var w = main.ui_layer.wardrobe_panel
	assert_true(w.get("bonus_label") is Label, "wardrobe_panel.bonus_label")
	if not w.get("bonus_label") is Label:
		return
	w.show_hats(main.progress)
	assert_eq(w.bonus_label.text, "No hat: no bonus")
	main.progress.total_runs = 1
	main.progress.best_distance = 150.0
	main.progress.hat = "party"
	w.show_hats(main.progress)
	assert_eq(w.bonus_label.text, "Party Hat: +2 points per bounce", "the worn hat's boost")
	w.hat_buttons["propeller"].mouse_entered.emit()
	assert_eq(w.bonus_label.text, "Propeller Cap: +3% launch speed", "the hat under the mouse")
	w.hat_buttons["propeller"].mouse_exited.emit()
	assert_eq(w.bonus_label.text, "Party Hat: +2 points per bounce")
	w.hat_buttons["crown"].mouse_entered.emit()
	assert_eq(w.bonus_label.text, "Party Hat: +2 points per bounce", "a locked hat shows nothing new")
	await wait_process_frames(2)
	assert_lte(w.size.y, 680.0, "the Wardrobe still fits the screen")
