extends GutTest
# Task 205: the alien is drawn 1.5 times its physical size (ProjectileView.LOOK_SCALE) so its face reads; it still
# sits on the ground, and its hat and face grow with it.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_205_save.json"
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


func test_look_size() -> void:
	var v = load("res://scripts/game/projectile_view.gd").new()
	add_child_autofree(v)
	assert_eq(v.LOOK_SCALE, 1.5)
	assert_almost_eq(v.scale.x, 36.0 / v.texture.get_width(), 0.001, "36 px wide (256 px textures since task 225)")
	assert_almost_eq(v.decor.scale.x, 1.5, 0.0001, "the hat and face grow too")
	v.show_at(Vector2(10, 0))
	assert_almost_eq(v.position.y, -18.0, 0.001, "still sits on the ground")
	v.set_size(2.0)
	assert_almost_eq(v.decor.scale.x, 3.0, 0.0001)
	assert_almost_eq(v.base_scale.x, 36.0 / v.texture.get_width() * 2.0, 0.0001)
	var main = _main()
	main.start_game()
	main.launch_with_pull(PULL)
	for i in 10:
		main.advance(1.0 / 60.0)
	var expected := WorldView.world_to_screen(main.session.sim.position + Vector2(0.0, 0.75 * 1.5))
	assert_almost_eq(main.projectile_view.position.y, expected.y, 0.001, "in flight too")
