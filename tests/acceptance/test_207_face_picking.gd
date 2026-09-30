extends GutTest
# Task 207: in flight the alien picks its face (wee, scared, happy, ouch after a hard bounce) and looks where it flies.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_207_save.json"
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


func test_pick_and_look() -> void:
	var f = load("res://scripts/game/alien_face.gd")
	assert_eq(f.pick(Vector2(20, 5), true, 0.0), "wee", "zooming")
	assert_eq(f.pick(Vector2(3, -16), true, 0.0), "scared", "falling fast")
	assert_eq(f.pick(Vector2(3, 2), true, 0.0), "happy")
	assert_eq(f.pick(Vector2(20, 5), false, 0.0), "happy", "rolling on the ground")
	assert_eq(f.pick(Vector2(3, -16), true, 0.2), "ouch", "a hard bounce wins")
	assert_eq(f.look_for(Vector2.ZERO), Vector2(0.5, 0.0), "ahead when still")
	assert_almost_eq(f.look_for(Vector2(0, -10)), Vector2(0, 1), Vector2(0.001, 0.001), "falling: looks down the screen")
	var main = _main()
	main.start_game()
	main.launch_with_pull(PULL)
	for i in 3:
		main.advance(1.0 / 60.0)
	var decor = main.projectile_view.decor
	assert_eq(decor.face, "wee", "launched fast")
	assert_almost_eq(decor.look, f.look_for(main.session.sim.velocity), Vector2(0.06, 0.06))
	main.projectile_view.ouch()
	assert_eq(decor.face, "ouch")
	main.advance(1.0 / 60.0)
	assert_eq(decor.face, "ouch", "for a moment")
	await wait_seconds(0.5)
	assert_ne(decor.face, "ouch", "then back to flying faces")
