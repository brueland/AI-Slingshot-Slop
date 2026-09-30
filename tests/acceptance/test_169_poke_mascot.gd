extends GutTest
# Task 169: clicking the title mascot makes it jump and say "Hi!".


func _his(m) -> int:
	var count := 0
	for child in m.get_children():
		if child is FloatingText and child.text == "Hi!":
			count += 1
	return count


func test_poke() -> void:
	var m = load("res://scripts/ui/title_mascot.gd").new()
	add_child_autofree(m)
	assert_eq(m.poke_offset(), 0.0, "not poked")
	m.poke()
	assert_eq(m.poke_left, 0.4)
	assert_eq(_his(m), 1, "says Hi!")
	m.poke_left = 0.2
	assert_almost_eq(m.poke_offset(), -16.0, 0.001, "the top of the jump")
	m.time = 1.0
	assert_almost_eq(m.center().y, 66.0 + m.bob_offset() + m.poke_offset(), 0.001)
	m.poke_left = 0.0
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	m._gui_input(click)
	assert_gt(m.poke_left, 0.0, "a click pokes")
	await wait_seconds(0.5)
	assert_eq(m.poke_left, 0.0, "the jump ends")
	await wait_seconds(0.6)
	assert_eq(_his(m), 0, "the Hi!s fade away")
