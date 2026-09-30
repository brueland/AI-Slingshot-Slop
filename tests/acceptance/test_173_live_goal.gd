extends GutTest
# Task 173: in a roguelike flight the HUD shows live goal progress under the goal ("34/50 m"), green once it is met.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_173_save.json"
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


## A roguelike run at `round_number` with a distance goal of `target` m, ready to shoot.
func _rogue_at(main, run_seed: int, round_number: int, target: float = 10.0) -> void:
	main.start_rogue(run_seed)
	main.rogue.round_number = round_number
	main.rogue.goal = {"type": "distance", "target": target, "round": round_number, "text": "Fly at least %d m" % int(target)}
	main.ui_layer.refresh(main)


func test_live_goal_progress() -> void:
	var main = _main()
	_rogue_at(main, 5, 2)
	var label = main.hud.goal_progress_label
	assert_false(label.visible, "nothing before the shot")
	assert_eq(label.get_index(), main.hud.goal_label.get_index() + 1, "right under the goal")
	main.launch_with_pull(PULL)
	for i in 3:
		main.advance(1.0 / 60.0)
	assert_true(label.visible, "shown in flight")
	assert_eq(label.text, "%d/10 m" % int(main.session.sim.distance()))
	assert_eq(label.get_theme_color("font_color"), Color.WHITE, "not met yet")
	for i in 20000:
		if main.state_name() != "FLIGHT" or main.session.sim.distance() > 12.0:
			break
		main.advance(1.0 / 60.0)
	assert_eq(label.get_theme_color("font_color"), Color(0.5, 1.0, 0.5), "green once the goal is met")
	await wait_process_frames(2)
	assert_true(main.get_viewport().get_visible_rect().encloses(label.get_global_rect()), "on screen")
	main.go_to_title()
	main.start_game()
	main.launch_with_pull(PULL)
	main.advance(1.0 / 60.0)
	assert_false(label.visible, "never in classic")
