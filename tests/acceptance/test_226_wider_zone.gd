extends GutTest
# Task 226: "Stop between" landing zones are 20 m wide (they were 12 m and too punishing).


func test_wider_zone() -> void:
	assert_eq(RogueGoals.ZONE_WIDTH, 20.0)
	assert_eq(RogueGoals.describe("zone", 30.0), "Stop between 30 and 50 m")
	assert_true(RogueGoals.check({"type": "zone", "target": 30.0}, {"distance": 49.0}), "49 m is inside 30..50")
	assert_false(RogueGoals.check({"type": "zone", "target": 30.0}, {"distance": 51.0}))
