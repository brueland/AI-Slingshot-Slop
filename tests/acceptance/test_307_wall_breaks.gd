extends GutTest
# Task 307: a secret: hitting the brick wall at 50 m/s or faster (sideways) breaks through it; the alien flies on (60%
# of its speed) into the secret behind it, where the world ends at -260 m. Slower, it bounces off as before. A shot
# that broke through has found "secret_wall".

const FLIGHT := "res://scripts/core/flight_sim.gd"


func test_wall_breaks() -> void:
	var b: Dictionary = load("res://scripts/core/balance.gd").get_script_constant_map()
	assert_eq(b.get("WALL_BREAK_SPEED"), 50.0)
	assert_eq(b.get("SECRET_END_X"), -260.0)
	var sim = load(FLIGHT).new()
	watch_signals(sim)
	sim.launch(Vector2(-110.0, 5.0), Vector2(-60.0, 0.0))
	for i in 30:
		sim.step(1.0 / 60.0)
	assert_signal_emitted(sim, "wall_broken")
	assert_true(sim.wall_down)
	assert_lt(sim.position.x, -120.0, "through the wall")
	assert_signal_not_emitted(sim, "wall_hit")
	sim.simulate(1.0 / 60.0, 20000)
	assert_gte(sim.position.x, -260.0, "the world ends at -260 m")
	var soft = load(FLIGHT).new()
	watch_signals(soft)
	soft.launch(Vector2(-110.0, 5.0), Vector2(-30.0, 0.0))
	for i in 60:
		soft.step(1.0 / 60.0)
	assert_signal_emitted(soft, "wall_hit", "slower: it bounces off as before")
	assert_false(soft.wall_down)
	assert_gte(soft.position.x, -120.0)
	var s = load("res://scripts/core/run_session.gd").new(PlayerStats.new(), 5)
	assert_false(s.result()["found"].has("secret_wall"))
	s.sim.wall_down = true
	assert_true(s.result()["found"].has("secret_wall"), "breaking through finds the secret")
