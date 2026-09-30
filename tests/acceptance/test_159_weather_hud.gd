extends GutTest
# Task 159: the roguelike HUD shows the round's weather ("Weather: Tailwind"); calm and classic hide it.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_159_save.json"


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


func test_weather_on_the_hud() -> void:
	var main = _main()
	main.start_rogue(7)
	assert_false(main.hud.weather_label.visible, "round 1 is calm")
	main.rogue.weather = "tailwind"
	main.ui_layer.refresh(main)
	assert_true(main.hud.weather_label.visible)
	assert_eq(main.hud.weather_label.text, "Weather: Tailwind")
	main.go_to_title()
	main.start_game()
	assert_false(main.hud.weather_label.visible, "classic has no weather")
