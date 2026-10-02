extends GutTest
# Checkpoint 38 (task 274c): with real frames, classic mode keeps going: a player past the old upgrade maximums buys
# another level in the shop, and past 1000 m the HUD shows the next milestone.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_274c_save.json"
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



func test_no_limits_with_real_frames() -> void:
	var main = _main()
	await wait_process_frames(2)
	main.progress.add_coins(5000000)
	main.progress.levels = {"power": 10, "boosts": 3}
	main.progress.best_distance = 1200.0
	main.progress.goal_reached = true
	main.start_game()
	await wait_process_frames(2)
	assert_eq(main.hud.goal_label.text, "Next: Cloud Surfer at 2000 m")
	main.launch_with_pull(PULL)
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	main.continue_to_shop()
	await wait_process_frames(2)
	assert_eq(main.state_name(), "SHOP")
	assert_true(main.buy_upgrade("power"), "level 11 of Band Power")
	assert_true(main.buy_upgrade("boosts"), "a 4th rocket tank")
	assert_eq(main.progress.level_of("power"), 11)
	assert_true(main.shop_panel.buttons["power"].text.begins_with("Band Power  Lv 11  "))


func test_progress_log_records_milestone_38() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 37: complete"), "the earlier lines are kept")
	assert_true(text.contains("Milestone 38: complete"), "add the line 'Milestone 38: complete' to docs/PROGRESS.md")
