extends GutTest
# Task 076: scripts/core/rogue_run.gd, one roguelike run: goal per round, 3 lives, a perk offer after every shot.
# Meeting the goal advances to a harder round; missing costs a life and keeps the goal (so you can pick a perk
# that helps with it).

const PATH := "res://scripts/core/rogue_run.gd"
const GOALS := "res://scripts/core/rogue_goals.gd"
const PERKS := "res://scripts/core/rogue_perks.gd"


func _run(seed_value: int = 7):
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	var r = load(PATH).new()
	r.start(seed_value)
	return r


func test_start() -> void:
	var r = _run(7)
	if r == null:
		return
	assert_eq(load(PATH).get_script_constant_map().get("START_LIVES"), 3)
	assert_eq(r.run_seed, 7)
	assert_eq(r.round_number, 1)
	assert_eq(r.lives, 3)
	assert_eq(r.rounds_cleared, 0)
	assert_eq(r.shots, 0)
	assert_eq(r.perks, [])
	assert_eq(r.offer, [])
	assert_eq(r.goal, load(GOALS).make_goal(1, 7))
	assert_false(r.is_over())
	assert_eq(r.shot_seed(), 7001)
	assert_almost_eq(r.stats().max_speed, 22.0, 0.0001, "no perks: base stats")


func test_meeting_the_goal_advances() -> void:
	var r = _run(7)
	if r == null:
		return
	var out: Dictionary = r.finish_shot({"distance": 45.0})
	assert_true(out.get("met"))
	assert_eq(out.get("lives"), 3)
	assert_eq(out.get("round"), 2)
	assert_false(out.get("over"))
	assert_eq(r.rounds_cleared, 1)
	assert_eq(r.shots, 1)
	assert_eq(r.goal, load(GOALS).make_goal(2, 7), "a new, harder goal")
	assert_eq(out.get("goal"), r.goal)
	assert_eq(r.offer, load(PERKS).offer(7 * 100 + 1, []), "the offer is seeded by run seed and shot count")
	assert_eq(out.get("offer"), r.offer)
	assert_eq(r.shot_seed(), 7002, "a new course for the next shot")


func test_choosing_a_perk() -> void:
	var r = _run(7)
	if r == null:
		return
	r.finish_shot({"distance": 45.0})
	var pick: String = r.offer[1]
	assert_false(r.choose_perk("not-offered"))
	assert_true(r.choose_perk(pick))
	assert_eq(r.perks, [pick])
	assert_true(r.has_perk(pick))
	assert_eq(r.offer, [], "one pick per shot")
	assert_false(r.choose_perk(pick), "the offer is used up")
	var expected = load(PERKS).apply(load("res://scripts/core/player_stats.gd").from_levels({}), [pick])
	assert_almost_eq(r.stats().max_speed, expected.max_speed, 0.0001, "stats include the perk")


func test_missing_costs_a_life_and_keeps_the_goal() -> void:
	var r = _run(7)
	if r == null:
		return
	var goal: Dictionary = r.goal
	var out: Dictionary = r.finish_shot({"distance": 10.0})
	assert_false(out.get("met"))
	assert_eq(r.lives, 2)
	assert_eq(r.round_number, 1)
	assert_eq(r.goal, goal, "same goal again")
	assert_eq(r.shot_seed(), 7001, "and the same course, to try again")
	assert_eq(r.offer.size(), 3, "a perk after a miss too")
	r.finish_shot({"distance": 10.0})
	out = r.finish_shot({"distance": 10.0})
	assert_true(out.get("over"))
	assert_true(r.is_over())
	assert_eq(r.lives, 0)
	assert_eq(r.offer, [], "no offer when the run is over")
	assert_false(r.choose_perk("power"))


func test_restart_resets_everything() -> void:
	var r = _run(7)
	if r == null:
		return
	r.finish_shot({"distance": 45.0})
	r.choose_perk(r.offer[0])
	r.start(9)
	assert_eq(r.round_number, 1)
	assert_eq(r.lives, 3)
	assert_eq(r.perks, [])
	assert_eq(r.shots, 0)
	assert_eq(r.rounds_cleared, 0)
