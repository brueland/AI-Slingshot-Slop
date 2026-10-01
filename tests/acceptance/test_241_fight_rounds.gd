extends GutTest
# Task 241: a roguelike run fights the Grumblor on every fight round: its shots are fired at the run's boss, a shot
# that doesn't finish it costs no life (the boss keeps the damage and there is one shot less), running out of shots
# costs a life and heals it, and beating it gives an extra life like a boss goal.


func test_fight_rounds() -> void:
	var run = load("res://scripts/core/rogue_run.gd").new()
	run.start(7)
	assert_null(run.fight)
	assert_null(run.stats().boss, "no boss in round 1")
	run.round_number = 9
	run.goal = {"type": "distance", "target": 10.0, "round": 9, "text": "Fly at least 10 m"}
	run.finish_shot({"distance": 50.0})
	assert_eq(run.round_number, 10)
	assert_eq(run.goal["type"], "fight", "round 10 is a boss fight")
	assert_not_null(run.fight)
	assert_eq(run.stats().boss, run.fight, "every shot this round is fired at the boss")
	assert_eq(run.goal["text"], "Boss: 12 HP, 4 shots left")
	var lives: int = run.lives
	var out: Dictionary = run.finish_shot({"distance": 80.0, "boss_hp": 7, "boss_damage": 5})
	assert_false(out["met"])
	assert_true(out["fight"])
	assert_eq(out["boss_damage"], 5)
	assert_eq(out["boss_hp"], 7)
	assert_eq(out["shots_left"], 3)
	assert_eq(run.lives, lives, "a boss shot that doesn't finish it costs no life")
	assert_eq(run.round_number, 10)
	assert_eq(run.fight.hp, 7, "the boss keeps the damage")
	assert_eq(run.goal["text"], "Boss: 7 HP, 3 shots left")
	assert_false(run.offer.is_empty(), "a perk after every shot")
	run.finish_shot({"distance": 80.0, "boss_hp": 7, "boss_damage": 0})
	run.finish_shot({"distance": 80.0, "boss_hp": 4, "boss_damage": 3})
	assert_eq(run.goal["text"], "Boss: 4 HP, 1 shot left")
	out = run.finish_shot({"distance": 80.0, "boss_hp": 2, "boss_damage": 2})
	assert_eq(out["shots_left"], 0)
	assert_eq(run.lives, lives - 1, "out of shots: a life")
	assert_eq(run.fight.hp, 12, "and the boss heals")
	assert_eq(run.fight.shots_left, 4)
	assert_eq(run.goal["text"], "Boss: 12 HP, 4 shots left")
	out = run.finish_shot({"distance": 80.0, "boss_hp": 0, "boss_damage": 12})
	assert_true(out["met"])
	assert_true(out["boss_beaten"])
	assert_eq(run.lives, lives, "+1 life for beating the boss")
	assert_eq(run.round_number, 11)
	assert_ne(run.goal["type"], "fight")
	assert_null(run.fight)
	assert_null(run.stats().boss)
