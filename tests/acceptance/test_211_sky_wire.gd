extends GutTest
# Task 211: the gradient replaces the painted sky picture (whose green hills showed across the top of the screen),
# follows the flight height, and the clouds fade out instead of turning purple.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_211_save.json"
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


func test_sky_in_the_game() -> void:
	var main = _main()
	var bg = main.background
	assert_true(bg.sky_gradient is SkyGradient)
	assert_eq(bg.sky_gradient.get_parent(), bg.layers[0])
	for child in bg.layers[0].get_children():
		assert_false(child is Sprite2D, "no painted sky picture any more")
	bg.set_altitude(90.0)
	assert_almost_eq(bg.layers[1].modulate.a, 0.5, 0.0001)
	bg.set_altitude(10.0)
	assert_eq(bg.layers[1].modulate.a, 1.0)
	assert_eq(bg.modulate, Color.WHITE, "no purple tint")
	main.start_game()
	main.launch_with_pull(PULL)
	for i in 30:
		main.advance(1.0 / 60.0)
	assert_almost_eq(bg.sky_gradient.height, main.session.sim.position.y, 0.0001)
