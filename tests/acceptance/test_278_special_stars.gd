extends GutTest
# Task 278: about one course in three has a purple special star holding a special perk (Star Magnet, Super Ball or
# Jet Pack); collecting it finds the perk, and the shot's result lists it under "found".

const PATH := "res://scripts/core/special_stars.gd"


func test_special_stars() -> void:
	var ss = load(PATH)
	assert_eq(ss.PERKS.size(), 3)
	assert_true(ss.is_perk("magnet"))
	assert_false(ss.is_perk("power"))
	var with_one := 0
	for seed in 300:
		var course := CourseGenerator.generate(seed, Balance.COURSE_LENGTH)
		ss.mark(course, seed)
		var specials := 0
		for item in course:
			if item.has("special"):
				specials += 1
				assert_eq(item["type"], "star")
				assert_true(ss.is_perk(item["special"]))
		assert_lte(specials, 1, "never more than one")
		with_one += specials
	assert_between(with_one, 70, 140, "about one course in three")
	var seed := 0
	while true:
		var c := CourseGenerator.generate(seed, Balance.COURSE_LENGTH)
		ss.mark(c, seed)
		var found := c.filter(func(it): return it.has("special"))
		if not found.is_empty():
			break
		seed += 1
	var s := RunSession.new(PlayerStats.new(), seed)
	var index := -1
	for i in s.course.size():
		if s.course[i].has("special"):
			index = i
	assert_ne(index, -1, "the session's course has it too")
	var star: Dictionary = s.course[index]
	var sim := FlightSim.new()
	sim.position = Vector2(float(star["x"]) + 0.3, float(star["y"]) - s.stats.pickup_offset)
	s.tracker.after_step(sim, sim.position - Vector2(0.6, 0.0))
	assert_eq(s.tracker.found_specials, [star["special"]], "collecting it finds the perk")
	assert_true(s.result()["found"].has(star["special"]))
