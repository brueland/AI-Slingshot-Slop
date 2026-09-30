extends GutTest
# Task 229: the face is drawn with smooth (antialiased) edges when the alien is small, and with sharp edges when it is
# big (drawn at 2x or more), where scaled-up soft edges looked blurry.


func test_sharp_face() -> void:
	var text := FileAccess.get_file_as_string("res://scripts/game/alien_face.gd")
	assert_false(text.contains(", true)"), "every face edge follows AlienFace.smooth")
	assert_gt(text.count("smooth)"), 15)
	var face = load("res://scripts/game/alien_face.gd")
	var d = load("res://scripts/game/projectile_decor.gd").new()
	add_child_autofree(d)
	d.scale = Vector2.ONE * 3.75
	d.queue_redraw()
	await wait_process_frames(2)
	assert_false(face.smooth, "a big alien's face has sharp edges")
	d.scale = Vector2.ONE * 1.5
	d.queue_redraw()
	await wait_process_frames(2)
	assert_true(face.smooth, "a normal alien's face is smooth")
