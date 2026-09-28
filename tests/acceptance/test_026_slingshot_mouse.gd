extends GutTest
# Task 026: Slingshot reacts to the left mouse button in _unhandled_input (press near the pouch, drag,
# release). Mouse positions are viewport coordinates; convert them to the slingshot's canvas coordinates
# with get_canvas_transform().affine_inverse() * event.position.

const PATH := "res://scripts/game/slingshot.gd"


func _sling():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	var s = load(PATH).new()
	s.position = Vector2(0, -32)
	add_child_autofree(s)
	return s


## Viewport position of a canvas point (the inverse of what the slingshot must do).
func _vp(s, canvas_point: Vector2) -> Vector2:
	return s.get_canvas_transform() * canvas_point


func _button(pos: Vector2, pressed: bool, button: int = MOUSE_BUTTON_LEFT) -> InputEventMouseButton:
	var e := InputEventMouseButton.new()
	e.button_index = button
	e.pressed = pressed
	e.position = pos
	e.global_position = pos
	return e


func _motion(pos: Vector2) -> InputEventMouseMotion:
	var e := InputEventMouseMotion.new()
	e.position = pos
	e.global_position = pos
	return e


func test_press_drag_release_launches() -> void:
	var s = _sling()
	if s == null:
		return
	watch_signals(s)
	s._unhandled_input(_button(_vp(s, Vector2(0, -32)), true))
	assert_true(s.dragging, "pressing on the pouch starts a drag")
	s._unhandled_input(_motion(_vp(s, Vector2(-100, 0))))
	assert_almost_eq(s.pull.x, -100.0, 0.01)
	assert_almost_eq(s.pull.y, 32.0, 0.01)
	s._unhandled_input(_button(_vp(s, Vector2(-100, 0)), false))
	assert_false(s.dragging)
	assert_signal_emitted(s, "launched")


func test_press_away_from_the_pouch_is_ignored() -> void:
	var s = _sling()
	if s == null:
		return
	s._unhandled_input(_button(_vp(s, Vector2(400, 300)), true))
	assert_false(s.dragging)
	s._unhandled_input(_motion(_vp(s, Vector2(-100, 0))))
	assert_eq(s.pull, Vector2.ZERO)


func test_right_button_is_ignored() -> void:
	var s = _sling()
	if s == null:
		return
	s._unhandled_input(_button(_vp(s, Vector2(0, -32)), true, MOUSE_BUTTON_RIGHT))
	assert_false(s.dragging)


func test_disabled_slingshot_ignores_the_mouse() -> void:
	var s = _sling()
	if s == null:
		return
	s.enabled = false
	s._unhandled_input(_button(_vp(s, Vector2(0, -32)), true))
	assert_false(s.dragging)
