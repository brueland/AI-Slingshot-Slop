extends GutTest
# Task 255: after a roguelike shot the panel says what its stars gave: "+2 stars: Speed+ x1, Lift+ x1 (2 this run)".

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_255_save.json"
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



func test_star_results() -> void:
	var main = _main()
	main.start_rogue(5)
	var run = main.rogue
	var panel = main.ui_layer.rogue_panel
	var out: Dictionary = run.finish_shot({"distance": 50.0, "stars": 2})
	panel.show_outcome(out, run)
	assert_true(panel.stars_label.visible)
	assert_eq(panel.stars_label.text, "+2 stars: %s (2 this run)" % StarBoosts.summary(out["stars_gained"]))
	assert_eq(panel.stars_label.get_index(), panel.close_label.get_index() + 1, "under the title lines")
	out = run.finish_shot({"distance": 50.0, "stars": 1})
	panel.show_outcome(out, run)
	assert_eq(panel.stars_label.text, "+1 star: %s (3 this run)" % StarBoosts.summary(out["stars_gained"]))
	out = run.finish_shot({"distance": 50.0})
	panel.show_outcome(out, run)
	assert_false(panel.stars_label.visible, "no stars this shot")
