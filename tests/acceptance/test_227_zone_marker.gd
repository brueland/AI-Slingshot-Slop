extends GutTest
# Task 227: ZoneMarker shows the roguelike's landing zone on the field (a band with a flag at each end).

const PATH := "res://scripts/game/zone_marker.gd"


func test_zone_marker() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var script = load(PATH)
	assert_eq(script.zones_for({"type": "zone", "target": 40.0}), [Vector2(40, 60)])
	var boss := {"type": "boss", "parts": [{"type": "height", "target": 10.0}, {"type": "zone", "target": 70.0}]}
	assert_eq(script.zones_for(boss), [Vector2(70, 90)], "a boss goal's zone part")
	assert_eq(script.zones_for({"type": "distance", "target": 40.0}), [], "no zone")
	var m = script.new()
	add_child_autofree(m)
	m.show_goal({"type": "zone", "target": 40.0})
	assert_true(m.visible)
	m.show_goal({"type": "height", "target": 8.0})
	assert_false(m.visible, "hidden without a zone")
	m.show_goal(boss)
	await wait_process_frames(2)
	pass_test("the marker draws without errors")
