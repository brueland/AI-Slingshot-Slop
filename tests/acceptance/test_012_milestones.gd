extends GutTest
# Task 012: scripts/core/milestones.gd, one-time distance rewards (docs/DESIGN.md section 5).

const PATH := "res://scripts/core/milestones.gd"


func _ms():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH)


func _names(list: Array) -> Array:
	var out := []
	for m in list:
		out.append(m["name"])
	return out


func test_list_matches_the_design() -> void:
	var ms = _ms()
	if ms == null:
		return
	var want := [[50.0, 25, "First Flight"], [100.0, 50, "Century"], [250.0, 150, "Sky Sprinter"],
		[500.0, 300, "Half-K Hero"], [1000.0, 1000, "Moon Shot"]]
	assert_eq(ms.LIST.size(), 5)
	for i in mini(ms.LIST.size(), want.size()):
		var m: Dictionary = ms.LIST[i]
		assert_almost_eq(float(m["distance"]), want[i][0], 0.0001)
		assert_eq(int(m["reward"]), want[i][1])
		assert_eq(m["name"], want[i][2])


func test_newly_reached() -> void:
	var ms = _ms()
	if ms == null:
		return
	assert_eq(_names(ms.newly_reached(0.0, 120.0)), ["First Flight", "Century"])
	assert_eq(_names(ms.newly_reached(60.0, 60.0)), [], "nothing new")
	assert_eq(_names(ms.newly_reached(99.9, 100.0)), ["Century"], "reaching exactly 100 counts")
	assert_eq(_names(ms.newly_reached(100.0, 240.0)), [], "100 was already reached")
	assert_eq(_names(ms.newly_reached(500.0, 499.0)), [], "a shorter run reaches nothing")
	assert_eq(_names(ms.newly_reached(0.0, 5000.0)).size(), 5)


func test_next_milestone() -> void:
	var ms = _ms()
	if ms == null:
		return
	assert_eq(ms.next_milestone(0.0).get("name"), "First Flight")
	assert_eq(ms.next_milestone(100.0).get("name"), "Sky Sprinter")
	assert_eq(ms.next_milestone(999.0).get("name"), "Moon Shot")
	assert_eq(ms.next_milestone(1000.0), {}, "all reached")
