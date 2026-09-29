extends GutTest
# Task 103: ProjectileView draws the alien (and its hat) at the shot's size; main sets it from the session's stats
# every shot (classic shots are always size 1).

const VIEW := "res://scripts/game/projectile_view.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_103_save.json"


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func test_view_size() -> void:
	var v = load(VIEW).new()
	add_child_autofree(v)
	assert_almost_eq(float(v.get("size_scale")), 1.0, 0.0001)
	var normal: Vector2 = v.base_scale
	v.set_size(2.5)
	assert_almost_eq(v.base_scale.x, normal.x * 2.5, 0.0001)
	assert_eq(v.scale, v.base_scale)
	assert_almost_eq(v.decor.scale.x, 2.5, 0.0001, "the hat grows too")
	v.show_at(Vector2(10.0, 0.0))
	assert_almost_eq(v.position.y, WorldView.world_to_screen(Vector2(10.0, 0.75 * 2.5)).y, 0.001, "a big alien sits on the ground")
	v.set_tier(2)
	assert_almost_eq(v.base_scale.x, 24.0 / v.texture.get_width() * 2.5, 0.0001, "a new tier keeps the size")
	v.set_size(0.0)
	assert_almost_eq(v.size_scale, 0.1, 0.0001, "never vanishes")


func test_main_uses_the_shot_size() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	main.start_game()
	assert_almost_eq(main.projectile_view.size_scale, 1.0, 0.0001, "classic is size 1")
	main.go_to_title()
	main.start_rogue(7)
	main.launch_with_pull(Vector2(-84.852814, 84.852814))
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	main.rogue.set_size("big")
	main.choose_rogue_perk(main.rogue.offer[0])
	assert_almost_eq(main.session.stats.size_scale, 2.5, 0.0001)
	assert_almost_eq(main.projectile_view.size_scale, 2.5, 0.0001, "the next shot's alien is big")
	main.go_to_title()
	main.start_game()
	assert_almost_eq(main.projectile_view.size_scale, 1.0, 0.0001, "back to normal in classic")
