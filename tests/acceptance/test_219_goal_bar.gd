extends GutTest
# Task 219: a bar in the HUD's right panel fills toward the next milestone (classic) or the goal (roguelike).

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_219_save.json"
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


func test_goal_bar() -> void:
	var main = _main()
	var hud = main.hud
	assert_eq(hud.goal_bar.get_index(), hud.goal_progress_label.get_index() + 1, "under the goal lines")
	hud.update_progress(30.0, 0)
	assert_almost_eq(hud.goal_bar.value, 0.6, 0.001, "the best is 30 of the 50 m to First Flight")
	hud.update_flight(25.0, 3.0, 0, 0)
	assert_almost_eq(hud.goal_bar.value, 0.5, 0.001, "this flight's distance toward the next milestone")
	hud.update_progress(5000.0, 0)
	assert_almost_eq(hud.goal_bar.value, 5000.0 / 6000.0, 0.001, "on the way to the next endless milestone (task 273)")
	hud.show_goal_progress("5/10 m", false, 0.5)
	assert_almost_eq(hud.goal_bar.value, 0.5, 0.001)
	hud.show_goal_progress("", false)
	assert_almost_eq(hud.goal_bar.value, 0.5, 0.001, "no ratio: unchanged")
	main.start_rogue(5)
	main.rogue.goal = {"type": "distance", "target": 1000.0, "round": 1, "text": "Fly at least 1000 m"}
	main.ui_layer.refresh(main)
	assert_eq(hud.goal_bar.value, 0.0, "a new round starts empty")
	main.launch_with_pull(PULL)
	for i in 30:
		main.advance(1.0 / 60.0)
	assert_almost_eq(hud.goal_bar.value, RogueGoals.progress_ratio(main.rogue.goal, main.session.result()), 0.0001)
	await wait_process_frames(3)
	_on_screen(main, hud.goal_bar, "the goal bar")
