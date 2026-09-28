extends GutTest
# Task 025: scripts/game/slingshot.gd, the drag-and-release API and drawing. The node's position is the
# pouch rest point (anchor); pull = drag point - anchor, in screen pixels.

const PATH := "res://scripts/game/slingshot.gd"


func _sling():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	var s = load(PATH).new()
	s.position = Vector2(0, -32)
	add_child_autofree(s)
	return s


func test_defaults() -> void:
	var s = _sling()
	if s == null:
		return
	assert_true(s is Node2D)
	assert_almost_eq(s.max_pull, 120.0, 0.0001)
	assert_eq(s.pull, Vector2.ZERO)
	assert_false(s.dragging)
	assert_true(s.enabled)
	assert_almost_eq(s.frame_height_px, 32.0, 0.0001, "BASE_LAUNCH_HEIGHT * PIXELS_PER_METER")
	assert_not_null(s.post_texture)
	assert_almost_eq(s.GRAB_RADIUS, 48.0, 0.0001)


func test_grab_only_near_the_pouch() -> void:
	var s = _sling()
	if s == null:
		return
	assert_false(s.begin_drag(Vector2(200, 0)), "too far from the anchor")
	assert_false(s.dragging)
	assert_true(s.begin_drag(Vector2(5, -30)))
	assert_true(s.dragging)


func test_drag_and_release_launches() -> void:
	var s = _sling()
	if s == null:
		return
	watch_signals(s)
	s.begin_drag(Vector2(0, -32))
	s.update_drag(Vector2(-60, 30))
	assert_eq(s.pull, Vector2(-60, 62), "point - anchor")
	assert_eq(s.pouch_position(), Vector2(-60, 30))
	s.update_drag(Vector2(-500, -32))
	assert_eq(s.pull, Vector2(-120, 0), "clamped to max_pull")
	var released: Vector2 = s.release()
	assert_eq(released, Vector2(-120, 0))
	assert_signal_emitted_with_parameters(s, "launched", [Vector2(-120, 0)])
	assert_false(s.dragging)
	assert_eq(s.pull, Vector2.ZERO)


func test_tiny_pulls_do_not_launch() -> void:
	var s = _sling()
	if s == null:
		return
	watch_signals(s)
	s.begin_drag(Vector2(0, -32))
	s.update_drag(Vector2(3, -30))
	assert_eq(s.release(), Vector2.ZERO)
	assert_signal_not_emitted(s, "launched")
	assert_eq(s.release(), Vector2.ZERO, "release without a drag does nothing")


func test_disabled_and_cancel() -> void:
	var s = _sling()
	if s == null:
		return
	s.enabled = false
	assert_false(s.begin_drag(Vector2(0, -32)))
	s.enabled = true
	s.begin_drag(Vector2(0, -32))
	s.update_drag(Vector2(-50, 0))
	s.cancel_drag()
	assert_false(s.dragging)
	assert_eq(s.pull, Vector2.ZERO)
	s.update_drag(Vector2(-80, 0))
	assert_eq(s.pull, Vector2.ZERO, "update_drag does nothing when not dragging")
