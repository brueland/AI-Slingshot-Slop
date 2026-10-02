extends GutTest
# Task 277: the alien can wear the three balloon hats: a brown cowboy hat, a horned viking helmet and a green bobble
# beanie.


func test_new_hats() -> void:
	var text := FileAccess.get_file_as_string("res://scripts/game/projectile_decor.gd")
	for id in ["cowboy", "viking", "beanie"]:
		assert_true(text.contains("\"%s\":" % id), id + " is drawn")
	var d = load("res://scripts/game/projectile_decor.gd").new()
	add_child_autofree(d)
	for id in ["cowboy", "viking", "beanie"]:
		d.set_hat(id)
		assert_eq(d.hat, id)
		d.queue_redraw()
		await wait_process_frames(2)
