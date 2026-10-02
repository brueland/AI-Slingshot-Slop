extends GutTest
# Task 270: with Steady Hand the roguelike shows the previous shot's whole path as a faint ghost (like classic's best
# shot), and the last-aim line is only drawn while aiming, so it no longer slides across the screen in flight.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_270_save.json"
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



func _shoot(main) -> void:
	main.launch_with_pull(PULL)
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)


func test_steady_ghost() -> void:
	var main = _main()
	main.start_rogue(7)
	main.rogue.perks.assign(["steady"])
	main._begin_aim()
	assert_eq(main.ghost.points.size(), 0, "no ghost before the first shot")
	_shoot(main)
	main.ui_layer.rogue_panel.perk_buttons[0].pressed.emit()
	assert_gt(main.rogue.last_path.size(), 3)
	assert_eq(main.ghost.points, main.rogue.last_path, "Steady Hand shows the last shot's path")
	main.rogue.perks.clear()
	main._begin_aim()
	assert_eq(main.ghost.points.size(), 0, "no Steady Hand, no ghost")
	assert_true(str(RoguePerks.get_def("steady")["description"]).contains("path"))


func test_aim_line_only_while_aiming() -> void:
	var s = load("res://scripts/game/slingshot.gd").new()
	add_child_autofree(s)
	s.show_last_aim = true
	s.last_pull = Vector2(-60, 40)
	assert_eq(s.shown_aim_line().size(), 2, "shown while aiming")
	s.enabled = false
	assert_eq(s.shown_aim_line().size(), 0, "hidden in flight")
	assert_eq(s.aim_line_points().size(), 2, "the line itself is still remembered")
	s.enabled = true
	assert_eq(s.shown_aim_line().size(), 2)
