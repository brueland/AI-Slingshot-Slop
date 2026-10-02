extends GutTest
# Task 254: the HUD's boxes show the run's stars ("Stars 23") and each star boost ("Speed+ x4") in gold after the perks.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_254_save.json"
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



func test_star_boxes() -> void:
	var chips = load("res://scripts/ui/perk_chips.gd").new()
	add_child_autofree(chips)
	chips.show_perks(["power"], 5, {"speed": 2, "lift": 1})
	assert_eq(chips.chip_texts(), ["Stronger Bands x1", "Stars 5", "Speed+ x2", "Lift+ x1"])
	assert_eq(chips.get_child_count(), 4)
	chips.show_perks([], 2, {"glide": 2})
	assert_true(chips.visible, "stars alone show the boxes")
	assert_eq(chips.chip_texts(), ["Stars 2", "Glide+ x2"])
	chips.show_perks([])
	assert_false(chips.visible)
	var main = _main()
	main.start_rogue(9)
	main.rogue.stars_total = 4
	main.rogue.star_boosts = {"glide": 3, "bounce": 1}
	main.ui_layer.refresh(main)
	assert_eq(main.hud.perk_chips.chip_texts(), ["Stars 4", "Glide+ x3", "Bounce+ x1"])
