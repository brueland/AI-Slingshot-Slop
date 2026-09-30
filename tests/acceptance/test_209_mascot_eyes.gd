extends GutTest
# Task 209: the title mascot's eyes follow the mouse, and poking it makes its "wow" face.


func test_mascot_eyes() -> void:
	var m = load("res://scripts/ui/title_mascot.gd").new()
	add_child_autofree(m)
	await wait_process_frames(2)
	assert_eq(m.decor.shown_face(), "happy")
	assert_lte(m.decor.look.length(), 1.0001, "the pupils stay in the eyes")
	m.poke()
	assert_eq(m.decor.shown_face(), "wow", "surprised when poked")
	await wait_seconds(0.8)
	assert_eq(m.decor.shown_face(), "happy", "then happy again")
