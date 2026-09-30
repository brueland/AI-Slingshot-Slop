extends GutTest
# Task 118: the roguelike run uses a boss goal on boss rounds; beating one gives an extra life, and finish_shot()
# reports it as "boss_beaten". A miss keeps the boss for the retry.

const RUN := "res://scripts/core/rogue_run.gd"
const GOALS := "res://scripts/core/rogue_goals.gd"


func _run_at_round_11():
	var r = load(RUN).new()
	r.start(7)
	r.round_number = 11
	r.goal = {"type": "distance", "target": 10.0, "round": 11, "text": "Fly at least 10 m"}
	return r


func test_boss_round_after_round_11() -> void:
	var r = _run_at_round_11()
	var out: Dictionary = r.finish_shot({"distance": 50.0})
	assert_eq(r.round_number, 12)
	assert_eq(r.goal, load(GOALS).make_boss_goal(12, 7), "round 12 is a boss")
	assert_false(out.get("boss_beaten"), "a normal goal is not a boss")
	assert_eq(r.lives, 3)


func test_beating_a_boss_gives_a_life() -> void:
	var r = _run_at_round_11()
	r.finish_shot({"distance": 50.0})
	var lives: int = r.lives
	var miss: Dictionary = r.finish_shot({"distance": 0.0})
	assert_false(miss.get("boss_beaten"))
	assert_eq(r.lives, lives - 1)
	assert_eq(r.goal["type"], "boss", "the retry is the same boss")
	var everything := {"distance": 99999.0, "max_height": 999.0, "bounces": 99, "stars": 99}
	for part in r.goal["parts"]:
		if part["type"] == "zone":
			everything["distance"] = float(part["target"]) + 1.0
	var out: Dictionary = r.finish_shot(everything)
	assert_true(out.get("met"))
	assert_true(out.get("boss_beaten"))
	assert_eq(r.lives, lives, "+1 life for the boss")
	assert_eq(out.get("lives"), lives)
	assert_eq(r.round_number, 13)
	assert_ne(r.goal["type"], "boss", "round 13 is normal again")
