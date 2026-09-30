extends GutTest
# Task 154: the title mascot does a little 12 px hop every 4 seconds.


func test_mascot_hop() -> void:
	var m = load("res://scripts/ui/title_mascot.gd").new()
	add_child_autofree(m)
	m.time = 0.2
	assert_almost_eq(m.hop_offset(), -12.0, 0.001, "the top of the hop")
	m.time = 1.0
	assert_eq(m.hop_offset(), 0.0, "resting between hops")
	m.time = 4.1
	assert_lt(m.hop_offset(), 0.0, "hops again every 4 seconds")
	assert_almost_eq(m.center().y, 66.0 + m.bob_offset() + m.hop_offset(), 0.001)
