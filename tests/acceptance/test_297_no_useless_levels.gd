extends GutTest
# Task 297: no upgrade sells levels that change nothing: Aim Guide stops at 12 (its 78 dots already cover every
# aim the screen can show) and Bouncy Shell at 8 (bounciness reaches its 0.9 cap there).

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_297_save.json"
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



func test_no_useless_levels() -> void:
	assert_eq(UpgradeCatalog.max_level("guide"), 12)
	assert_eq(UpgradeCatalog.max_level("bounce"), 8)
	assert_eq(UpgradeCatalog.max_level("power"), 25, "the others still go to 25")
	assert_lt(PlayerStats.from_levels({"bounce": 7}).restitution, PlayerStats.from_levels({"bounce": 8}).restitution, "level 8 still adds")
	assert_eq(PlayerStats.from_levels({"guide": 12}).guide_points, 78)
	var p := Progress.new()
	p.add_coins(99999999)
	p.levels["guide"] = 12
	p.levels["bounce"] = 8
	assert_false(p.can_buy("guide"), "maxed")
	assert_false(p.can_buy("bounce"))
	var q := Progress.from_dict({"levels": {"guide": 20, "bounce": 15}})
	assert_eq(q.level_of("guide"), 12, "old saves are capped")
	assert_eq(q.level_of("bounce"), 8)
	var main = _main()
	main.progress.add_coins(99999999)
	main.progress.levels = {"guide": 12, "bounce": 8}
	main.start_game()
	main.continue_to_shop()
	main.shop_panel.refresh(main.progress)
	assert_eq(main.shop_panel.buttons["guide"].text, "Aim Guide  Lv 12  MAX")
	assert_eq(main.shop_panel.buttons["bounce"].text, "Bouncy Shell  Lv 8  MAX")
