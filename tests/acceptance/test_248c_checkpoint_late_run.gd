extends GutTest
# Checkpoint 32 (task 248c): with real frames and real mouse input, the big alien is grabbed by its head and
# launched, and a long run's HUD (round 18, a boss goal, 17 perks) stays on screen with the perks as boxes.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_248c_save.json"
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


const PERKS := ["power", "power", "aero", "power", "bounce", "height", "power", "heavy", "aero", "feather",
	"boost", "bounce", "steady", "power", "boost", "height", "aero"]
const CHIPS := ["Stronger Bands x5", "Sleek Shell x3", "Rubber Coat x2", "Taller Frame x2", "Heavy Core x1",
	"Feather Shell x1", "Rocket x2", "Steady Hand x1"]


## Round 18 of a long run: a boss goal, 17 perks and weather.
func _late_run(main) -> void:
	main.start_rogue(2024)
	main.rogue.perks.assign(PERKS)
	main.rogue.round_number = 18
	main.rogue.weather = "thick_air"
	main.rogue.goal = RogueGoals.make_boss_goal(18, 2024)
	main._begin_aim()
	main.ui_layer.refresh(main)


func _mouse(main, at: Vector2, pressed: bool) -> void:
	var e := InputEventMouseButton.new()
	e.button_index = MOUSE_BUTTON_LEFT
	e.pressed = pressed
	e.position = main.slingshot.get_canvas_transform() * at
	main.get_viewport().push_input(e, true)


func _move(main, at: Vector2) -> void:
	var e := InputEventMouseMotion.new()
	e.position = main.slingshot.get_canvas_transform() * at
	main.get_viewport().push_input(e, true)


func test_grab_the_big_alien_with_the_mouse() -> void:
	var main = _main()
	await wait_process_frames(2)
	main.start_rogue(7)
	main.rogue.set_size("big")
	main._begin_aim()
	await wait_frames(3)
	var head: Vector2 = main.projectile_view.global_position + Vector2(0, -30)
	_mouse(main, head, true)
	await wait_frames(2)
	assert_true(main.slingshot.dragging, "the mouse grabbed the big alien by its head")
	_move(main, head + Vector2(-80, 40))
	await wait_frames(2)
	assert_eq(main.slingshot.pull, Vector2(-80, 40))
	_mouse(main, head + Vector2(-80, 40), false)
	await wait_frames(2)
	assert_eq(main.state_name(), "FLIGHT", "released: launched")


func test_late_run_hud_with_real_frames() -> void:
	var main = _main()
	await wait_process_frames(2)
	_late_run(main)
	await wait_seconds(0.3)
	var screen: Rect2 = main.get_viewport().get_visible_rect()
	var panel: Control = main.hud.goal_label.get_parent().get_parent()
	assert_true(screen.encloses(panel.get_global_rect()), "the right panel fits")
	assert_eq(main.hud.perk_chips.chip_texts(), CHIPS)
	for chip in main.hud.perk_chips.get_children():
		assert_true(panel.get_global_rect().encloses(chip.get_global_rect()), "every box is inside the panel")
	main.launch_with_pull(PULL)
	await wait_seconds(0.5)
	assert_true(screen.encloses(panel.get_global_rect()), "and in flight")


func test_new_code_follows_the_conventions() -> void:
	var main_text := FileAccess.get_file_as_string("res://scripts/game/main.gd")
	assert_lt(main_text.split("\n").size(), 450, "main.gd stays under 450 lines")
	assert_lt(FileAccess.get_file_as_string("res://scripts/ui/hud.gd").split("\n").size(), 300, "hud.gd stays under 300 lines")
	var chips := FileAccess.get_file_as_string("res://scripts/ui/perk_chips.gd")
	assert_true(chips.contains("class_name PerkChips"))
	assert_false(chips.contains("print("))


func test_progress_log_records_milestone_32() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 31: complete"), "the earlier lines are kept")
	assert_true(text.contains("Milestone 32: complete"), "add the line 'Milestone 32: complete' to docs/PROGRESS.md")
