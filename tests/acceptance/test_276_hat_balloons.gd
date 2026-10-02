extends GutTest
# Task 276: about one balloon in six carries a hat hanging from its string; popping that balloon finds the hat, and the
# shot's result lists it under "found".


func test_hat_balloons() -> void:
	var balloons_total := 0
	var hats_total := 0
	var course_seed := -1
	var carrying := []
	for k in 200:
		var c = load("res://scripts/core/balloons.gd").new(Balloons.layout(k, Balance.COURSE_LENGTH))
		c.carry_hats(k)
		assert_eq(c.hats.size(), c.points.size())
		balloons_total += c.points.size()
		for i in c.hats.size():
			if c.hats[i] != "":
				hats_total += 1
				assert_true(c.hats[i] in ["cowboy", "viking", "beanie"])
				if course_seed == -1:
					course_seed = k
				if course_seed == k:
					carrying.append(i)
	assert_between(float(hats_total) / balloons_total, 0.1, 0.25, "about one balloon in six")
	var pts := Balloons.layout(course_seed, Balance.COURSE_LENGTH)
	var b = load("res://scripts/core/balloons.gd").new(pts)
	b.carry_hats(course_seed)
	var again = load("res://scripts/core/balloons.gd").new(pts)
	again.carry_hats(course_seed)
	assert_eq(again.hats, b.hats, "the same course seed, the same hats")
	var i: int = carrying[0]
	var sim := FlightSim.new()
	sim.position = b.points[i] + Vector2(0.2, 0.0)
	b.after_step(sim, b.points[i] - Vector2(0.2, 0.0))
	assert_eq(b.found_hats, [b.hats[i]], "popping it finds the hat")
	var s := RunSession.new(PlayerStats.new(), course_seed)
	assert_eq(s.balloons.hats, b.hats, "every session's balloons carry their course's hats")
	assert_eq(s.result()["found"], [], "nothing found yet")
	var view = load("res://scripts/game/balloon_view.gd").new()
	add_child_autofree(view)
	view.build(s.balloons)
	assert_eq(view.hats, s.balloons.hats, "the view draws the hats")
	await wait_process_frames(2)
