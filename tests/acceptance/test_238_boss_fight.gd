extends GutTest
# Task 238: scripts/core/boss_fight.gd, the roguelike boss fight against the Grumblor: a giant standing on the field
# with six targets on and around its body. Every target the alien flies through deals its damage (each once per
# shot); 4 shots to knock its HP to 0, and running out of shots heals it.

const PATH := "res://scripts/core/boss_fight.gd"
const BODY := 1.125


func _sim_at(x: float, y: float):
	var sim := FlightSim.new()
	sim.position = Vector2(x, y)
	return sim


func test_the_grumblor() -> void:
	var b = load(PATH)
	assert_eq(b.SHOTS, 4)
	assert_eq(b.TARGETS.size(), 6)
	var f = b.make(10)
	assert_eq(f.x, 70.0, "the first boss stands at 70 m")
	assert_eq(f.max_hp, 12)
	assert_eq(f.hp, 12)
	assert_eq(f.shots_left, 4)
	var later = b.make(20)
	assert_eq(later.x, 80.0, "every fight 10 m farther")
	assert_eq(later.max_hp, 16, "and 4 more HP")
	assert_eq(f.target_position(0), Vector2(70.0, 11.5), "the crown floats over its head")
	assert_eq(f.target_position(5), Vector2(66.8, 0.5), "a toe on the ground in front")
	var g: Dictionary = f.goal()
	assert_eq(g["type"], "fight")
	assert_eq(g["target"], 12.0)
	assert_eq(g["text"], "Boss: 12 HP, 4 shots left")


func test_hits_deal_damage_once_per_shot() -> void:
	var f = load(PATH).make(10)
	watch_signals(f)
	var through_belly = _sim_at(80.0, 2.6 - BODY)
	f.after_step(through_belly, Vector2(60.0, 2.6 - BODY), BODY)
	assert_eq(f.hp, 10, "the belly deals 2")
	assert_eq(f.damage, 2)
	assert_signal_emitted_with_parameters(f, "target_hit", [2, 2])
	f.after_step(through_belly, Vector2(60.0, 2.6 - BODY), BODY)
	assert_eq(f.hp, 10, "each target once per shot")
	f.begin_shot()
	assert_eq(f.damage, 0)
	f.after_step(through_belly, Vector2(60.0, 2.6 - BODY), BODY)
	assert_eq(f.hp, 8, "and again on the next shot")
	var far = _sim_at(200.0, 30.0)
	f.after_step(far, Vector2(190.0, 30.0), BODY)
	assert_eq(f.hp, 8, "nothing far away")


func test_knock_out_copy_and_restart() -> void:
	var f = load(PATH).make(10)
	f.hp = 5
	f.begin_shot()
	var drop = _sim_at(69.6, -BODY)
	f.after_step(drop, Vector2(69.6, 18.0), BODY)
	assert_eq(f.hp, 0, "the crown and the eye knock it out")
	assert_eq(f.damage, 5, "no damage past 0 HP")
	var c = load(PATH).make(10).copy()
	c.hp = 3
	c.shots_left = 1
	var copy2 = c.copy()
	assert_eq(copy2.hp, 3)
	assert_eq(copy2.shots_left, 1)
	copy2.hp = 1
	assert_eq(c.hp, 3, "a copy is separate")
	c.restart()
	assert_eq(c.hp, 12, "out of shots: it heals")
	assert_eq(c.shots_left, 4)
	assert_eq(c.goal()["text"], "Boss: 12 HP, 4 shots left")
	c.shots_left = 1
	assert_eq(c.goal()["text"], "Boss: 12 HP, 1 shot left")
