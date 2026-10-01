extends GutTest
# Task 239: a shot fired at a boss (PlayerStats.boss) fights a copy of it: the targets the alien's drawn body flies
# through deal damage, and the result has the boss's HP after the shot and the damage dealt. The real boss is never
# hurt by a session (RogueRun applies the result), and shots without a boss are unchanged.


func _fly(stats, angle: float, strength: float) -> Dictionary:
	var s := RunSession.new(stats, 3)
	var r := deg_to_rad(angle)
	s.launch_from_pull(Vector2(-cos(r), sin(r)) * Balance.MAX_PULL_PX * strength)
	while not s.is_finished():
		s.step(1.0 / 60.0)
	return s.result()


func test_shots_fight_a_copy_of_the_boss() -> void:
	var stats = PlayerStats.from_levels({"power": 4})
	var boss := BossFight.make(10)
	stats.boss = boss
	var hits := 0
	for a in range(10, 80, 4):
		for strength in [1.0, 0.85, 0.7]:
			var r := _fly(stats, float(a), strength)
			assert_true(r.has("boss_hp"), "the result has the boss's HP")
			assert_eq(int(r["boss_hp"]), 12 - int(r["boss_damage"]))
			if int(r["boss_damage"]) > 0:
				hits += 1
	assert_gt(hits, 3, "some shots hit the boss")
	assert_eq(boss.hp, 12, "the real boss is never hurt by a session")
	var plain := _fly(PlayerStats.from_levels({"power": 4}), 45.0, 1.0)
	assert_false(plain.has("boss_hp"), "no boss, no boss keys")
