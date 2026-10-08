extends GutTest
# Task 295: the Wardrobe shows its hats in two columns, so with all ten hats it still fits on a 1280 x 720 screen.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_295_save.json"
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



func test_wardrobe_fits() -> void:
	var main = _main()
	var w = main.ui_layer.wardrobe_panel
	main.progress.found.assign(["cowboy", "viking", "beanie"])
	main.progress.goal_reached = true
	w.show_hats(main.progress)
	await wait_process_frames(3)
	var grid = w.hat_buttons["none"].get_parent()
	assert_true(grid is GridContainer, "the hat buttons sit in a grid")
	if grid is GridContainer:
		assert_eq(grid.columns, 2)
	assert_eq(w.hat_buttons.size(), 10)
	assert_lte(w.size.y, 680.0, "fits a 720 px tall screen")
	assert_lte(w.size.x, 1240.0, "and a 1280 px wide one")
	w.show_hats(Progress.new())
	await wait_process_frames(3)
	assert_lte(w.size.y, 680.0, "also with the long 'Locked' texts")
	assert_lte(w.size.x, 1240.0)
