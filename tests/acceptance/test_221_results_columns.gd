extends GutTest
# Task 221: the results are two columns (the shot on the left, the numbers on the right) above a big Continue, short
# enough to stay clear of the achievement pop-up at the top.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_221_save.json"
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


func test_results_columns() -> void:
	var main = _main()
	main.start_game()
	main.launch_with_pull(PULL)
	main.advance(1.0 / 60.0)
	main.session.balloons.popped_count = 2
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	var panel = main.results_panel
	var left = panel.title_label.get_parent()
	var right = panel.distance_label.get_parent()
	assert_ne(left, right, "two columns")
	assert_true(left.get_parent() is HBoxContainer and left.get_parent() == right.get_parent(), "side by side")
	for node in [panel.rating, panel.quip_label, panel.shot_map, panel.gap_label]:
		assert_eq(node.get_parent(), left, "the shot on the left")
	for node in [panel.stars_label, panel.bounces_label, panel.air_label, panel.coins_label, panel.hats_label, panel.balloons_label]:
		assert_eq(node.get_parent(), right, "the numbers on the right")
	assert_eq(panel.continue_button.theme_type_variation, "PrimaryButton")
	await wait_process_frames(3)
	_on_screen(main, panel, "the results")
	assert_lt(panel.get_global_rect().size.y, 520.0, "shorter than one long list")
	if main.toast.visible:
		assert_false(panel.get_global_rect().intersects(main.toast.get_global_rect()), "clear of the achievement pop-up")
