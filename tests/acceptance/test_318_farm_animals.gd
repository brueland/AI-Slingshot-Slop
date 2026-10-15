extends GutTest
# Task 318: the alien can run into the meadow's sheep and cows (where they are drawn; the layouts repeat every 2000 m).
# A sheep is springy: the alien bounces up off it (at least 8 m/s). A cow kicks: the alien flies back (40% of its
# speed, 7 to 15 m/s) and up (5 m/s). Each animal counts once per shot, none in the landing zones, and flying over them
# is no hit.

const PATH := "res://scripts/core/farm_animals.gd"


func test_farm_animals() -> void:
	var a = load(PATH).new()
	assert_eq(a.sheep_xs, Critters.layout(Critters.SEED, Balance.COURSE_LENGTH), "where the sheep are drawn")
	assert_eq(a.cow_xs, Cows.layout(Cows.SEED, Balance.COURSE_LENGTH), "where the cows are drawn")
	watch_signals(a)
	var x: float = a.sheep_xs[0]
	var sim := FlightSim.new()
	sim.position = Vector2(x + 0.2, 0.0)
	sim.velocity = Vector2(6.0, 0.0)
	a.after_step(sim, Vector2(x - 0.5, 0.0))
	assert_gte(sim.velocity.y, 8.0, "a sheep bounces the alien up")
	assert_almost_eq(sim.position.y, 1.3, 0.001, "over its back")
	assert_signal_emitted_with_parameters(a, "sheep_hit", [x])
	sim.velocity = Vector2(6.0, -1.0)
	sim.position = Vector2(x + 0.2, 0.5)
	a.after_step(sim, Vector2(x - 0.5, 0.5))
	assert_eq(sim.velocity, Vector2(6.0, -1.0), "only once per shot")
	var far := FlightSim.new()
	far.position = Vector2(x + 2000.2, 0.0)
	far.velocity = Vector2(6.0, 0.0)
	a.after_step(far, Vector2(x + 1999.5, 0.0))
	assert_gte(far.velocity.y, 8.0, "the flock 2000 m on counts too")
	var c: float = a.cow_xs[0]
	var kicked := FlightSim.new()
	kicked.position = Vector2(c + 0.2, 1.0)
	kicked.velocity = Vector2(12.0, -2.0)
	a.after_step(kicked, Vector2(c - 0.4, 1.0))
	assert_almost_eq(kicked.velocity.x, -7.0, 0.001, "a cow kicks the alien back the way it came (at least 7 m/s)")
	assert_almost_eq(kicked.velocity.y, 5.0, 0.001, "and up")
	assert_signal_emitted(a, "cow_hit")
	var b = load(PATH).new()
	var from_right := FlightSim.new()
	from_right.position = Vector2(c - 0.2, 1.0)
	from_right.velocity = Vector2(-12.0, 0.0)
	b.after_step(from_right, Vector2(c + 0.4, 1.0))
	assert_eq(from_right.velocity, Vector2(7.0, 5.0), "from the other side, back the other way")
	var fast = load(PATH).new()
	var rush := FlightSim.new()
	rush.position = Vector2(c + 0.2, 1.0)
	rush.velocity = Vector2(100.0, 0.0)
	fast.after_step(rush, Vector2(c - 1.5, 1.0))
	assert_almost_eq(rush.velocity.x, -15.0, 0.001, "a fast alien is kicked back at most 15 m/s (40% of 100 is more)")
	var mid = load(PATH).new()
	var trot := FlightSim.new()
	trot.position = Vector2(c + 0.2, 1.0)
	trot.velocity = Vector2(25.0, 0.0)
	mid.after_step(trot, Vector2(c - 0.4, 1.0))
	assert_almost_eq(trot.velocity.x, -10.0, 0.001, "40% of its speed back")
	var over := FlightSim.new()
	over.position = Vector2(c + 0.2, 6.0)
	over.velocity = Vector2(12.0, 0.0)
	b.after_step(over, Vector2(c - 0.4, 6.0))
	assert_eq(over.velocity, Vector2(12.0, 0.0), "flying over a cow is no hit")
	var clear = load(PATH).new()
	var spans: Array[Vector2] = [Vector2(x - 5.0, x + 5.0)]
	clear.keep_clear = spans
	var zone := FlightSim.new()
	zone.position = Vector2(x + 0.2, 0.0)
	zone.velocity = Vector2(6.0, 0.0)
	clear.after_step(zone, Vector2(x - 0.5, 0.0))
	assert_eq(zone.velocity, Vector2(6.0, 0.0), "not in a landing zone")
	var s = load("res://scripts/core/run_session.gd").new(PlayerStats.new(), 5)
	assert_not_null(s.get("animals"), "every shot has the animals")
	assert_eq(s.result()["animals"], 0)
