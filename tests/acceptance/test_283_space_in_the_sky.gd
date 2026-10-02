extends GutTest
# Task 283: the sky has a space layer (in front of the stars, scrolling slowly) whose things show as the alien
# climbs toward space.


func test_space_in_the_sky() -> void:
	var bg = load("res://scripts/game/background.gd").new()
	add_child_autofree(bg)
	assert_eq(bg.layers.size(), 2, "the sky and cloud layers are unchanged")
	assert_true(bg.get("space_layer") is Parallax2D)
	assert_eq(bg.space.get_parent(), bg.space_layer)
	assert_gt(bg.space_layer.get_index(), bg.stars_layer.get_index(), "in front of the stars")
	bg.set_altitude(10.0)
	assert_false(bg.space.visible, "no space things near the ground")
	bg.set_altitude(260.0)
	assert_true(bg.space.visible)
	assert_eq(bg.space.height_m, 260.0)
	await wait_process_frames(3)
