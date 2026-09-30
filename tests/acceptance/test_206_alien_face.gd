extends GutTest
# Task 206: AlienFace draws the alien's cartoon faces; ProjectileDecor draws the face (under the hat).

const PATH := "res://scripts/game/alien_face.gd"


func test_faces() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var faces: Array = load(PATH).FACES
	assert_eq(faces, ["happy", "focus", "wee", "scared", "wow", "ouch", "dizzy", "sleepy"])
	var d = load("res://scripts/game/projectile_decor.gd").new()
	add_child_autofree(d)
	assert_eq(d.face, "happy")
	d.set_face("scared", Vector2(0, 1))
	assert_eq(d.face, "scared")
	assert_eq(d.look, Vector2(0, 1))
	d.set_face("grumpy", Vector2.ZERO)
	assert_eq(d.face, "happy", "unknown faces are happy")
	d.set_mood("dizzy")
	assert_eq(d.shown_face(), "dizzy", "a mood shows its own face")
	d.set_mood("")
	assert_eq(d.shown_face(), "happy")
	for id in faces:
		d.set_face(id, Vector2(0.6, -0.3))
		await wait_process_frames(1)
	pass_test("every face draws without errors")
