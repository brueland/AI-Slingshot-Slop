extends GutTest
# Task 243: the roguelike panel tells how a boss fight shot went ("Boss hit for 5! 7 HP left, 3 shots to go", "No
# hit! ...", "Out of shots! The boss heals. ..."), the next goal is red like a boss goal, and the HUD shows the
# BOSS ROUND! banner during a fight.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_243_save.json"
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


## Round 10 of a roguelike run, a boss fight.
func _fight_round(main) -> void:
	main.start_rogue(5)
	main.rogue.round_number = 10
	main.rogue.fight = BossFight.make(10)
	main.rogue.goal = main.rogue.fight.goal()
	main._begin_aim()


func test_boss_panel() -> void:
	var main = _main()
	_fight_round(main)
	main.ui_layer.refresh(main)
	assert_true(main.hud.boss_label.visible, "the BOSS ROUND! banner during a fight")
	var panel = main.ui_layer.rogue_panel
	var run = main.rogue
	var out: Dictionary = run.finish_shot({"distance": 80.0, "boss_hp": 7, "boss_damage": 5})
	panel.show_outcome(out, run)
	assert_eq(panel.title_label.text, "Boss hit for 5! 7 HP left, 3 shots to go")
	assert_eq(panel.goal_label.text, "Next goal: Boss: 7 HP, 3 shots left")
	assert_eq(panel.goal_label.modulate, Color(1.0, 0.6, 0.6), "red like a boss goal")
	out = run.finish_shot({"distance": 80.0, "boss_hp": 7, "boss_damage": 0})
	panel.show_outcome(out, run)
	assert_eq(panel.title_label.text, "No hit! 7 HP left, 2 shots to go")
	out = run.finish_shot({"distance": 80.0, "boss_hp": 1, "boss_damage": 6})
	panel.show_outcome(out, run)
	assert_eq(panel.title_label.text, "Boss hit for 6! 1 HP left, 1 shot to go")
	out = run.finish_shot({"distance": 80.0, "boss_hp": 1, "boss_damage": 0})
	panel.show_outcome(out, run)
	assert_eq(panel.title_label.text, "Out of shots! The boss heals. Lives left: 2")
	out = run.finish_shot({"distance": 80.0, "boss_hp": 0, "boss_damage": 12})
	panel.show_outcome(out, run)
	assert_eq(panel.title_label.text, "Boss beaten! +1 life")
	assert_eq(panel.goal_label.modulate, Color.WHITE, "round 11 is a normal goal")
