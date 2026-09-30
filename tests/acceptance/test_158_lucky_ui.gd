extends GutTest
# Task 158: a lucky round shows "Lucky round! Beat it for a reroll" on the HUD, and the perk panel says
# "Lucky! Goal met, +1 reroll" after it.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_158_save.json"


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


## A roguelike run at `round_number` with an easy goal (fly 10 m), ready to shoot.
func _rogue_at(main, run_seed: int, round_number: int) -> void:
	main.start_rogue(run_seed)
	main.rogue.round_number = round_number
	main.rogue.goal = {"type": "distance", "target": 10.0, "round": round_number, "text": "Fly at least 10 m"}
	main.ui_layer.refresh(main)


func test_lucky_ui() -> void:
	var main = _main()
	_rogue_at(main, 7, 9)
	assert_true(main.hud.lucky_label.visible, "the lucky banner is up")
	await wait_process_frames(2)
	assert_true(main.get_viewport().get_visible_rect().encloses(main.hud.lucky_label.get_global_rect()))
	_fly(main, Vector2(-84.852814, 84.852814))
	assert_eq(main.ui_layer.rogue_panel.title_label.text, "Lucky! Goal met, +1 reroll")
	main.go_to_title()
	_rogue_at(main, 7, 8)
	assert_false(main.hud.lucky_label.visible)
	main.go_to_title()
	main.start_game()
	assert_false(main.hud.lucky_label.visible, "never in classic")
