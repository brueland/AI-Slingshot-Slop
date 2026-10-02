extends GutTest
# Task 246: late in a roguelike run the HUD's right panel stays on screen: long goal lines (boss goals) wrap inside
# the panel, and the perks are boxes with counts (PerkChips) instead of a long line of text.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_246_save.json"
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


func _panel_on_screen(main, what: String) -> void:
	var panel: Control = main.hud.goal_label.get_parent().get_parent()
	var screen: Rect2 = main.get_viewport().get_visible_rect()
	assert_true(screen.encloses(panel.get_global_rect()), what + ": the right panel is on screen " + str(panel.get_global_rect()))
	assert_lt(panel.size.x, 340.0, what + ": it keeps its width")


func test_late_run_hud() -> void:
	var main = _main()
	_late_run(main)
	var hud = main.hud
	assert_true(hud.perk_chips is PerkChips)
	assert_eq(hud.perk_chips.get_parent(), hud.goal_label.get_parent(), "in the right panel")
	assert_true(hud.perk_chips.visible)
	assert_eq(hud.perk_chips.chip_texts(), CHIPS)
	assert_eq(hud.goal_label.autowrap_mode, TextServer.AUTOWRAP_WORD_SMART, "long goals wrap")
	await wait_frames(3)
	_panel_on_screen(main, "aiming")
	assert_gt(hud.goal_label.get_line_count(), 1, "the boss goal takes two lines")
	main.launch_with_pull(PULL)
	for i in 30:
		main.advance(1.0 / 60.0)
	await wait_frames(3)
	assert_true(hud.goal_progress_label.visible)
	_panel_on_screen(main, "flying")
	main.go_to_title()
	main.start_game()
	assert_false(hud.perk_chips.visible, "classic has no perks")
