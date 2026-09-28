extends GutTest
# Task 013: Progress.record_run() pays coins and milestone rewards and updates records
# (docs/DESIGN.md sections 5 and 9).

const PATH := "res://scripts/core/progress.gd"


func _progress():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH).new()


func test_first_run_pays_coins_and_first_milestone() -> void:
	var p = _progress()
	if p == null:
		return
	var reached: Array = p.record_run(60.0, 60)
	assert_eq(reached.size(), 1)
	if reached.size() == 1:
		assert_eq(reached[0]["name"], "First Flight")
	assert_eq(p.coins, 85, "60 earned + 25 First Flight reward")
	assert_eq(p.total_runs, 1)
	assert_almost_eq(p.best_distance, 60.0, 0.0001)
	assert_false(p.goal_reached)


func test_shorter_run_keeps_the_best() -> void:
	var p = _progress()
	if p == null:
		return
	p.record_run(60.0, 60)
	var reached: Array = p.record_run(40.0, 40)
	assert_eq(reached, [])
	assert_eq(p.coins, 125)
	assert_eq(p.total_runs, 2)
	assert_almost_eq(p.best_distance, 60.0, 0.0001)


func test_reaching_the_goal() -> void:
	var p = _progress()
	if p == null:
		return
	p.record_run(60.0, 0)
	var reached: Array = p.record_run(1000.5, 3000)
	assert_eq(reached.size(), 4, "Century, Sky Sprinter, Half-K Hero, Moon Shot")
	assert_eq(p.coins, 25 + 3000 + 50 + 150 + 300 + 1000)
	assert_true(p.goal_reached)
	assert_almost_eq(p.best_distance, 1000.5, 0.0001)


func test_negative_coins_are_ignored() -> void:
	var p = _progress()
	if p == null:
		return
	p.record_run(10.0, -50)
	assert_eq(p.coins, 0)
	assert_eq(p.total_runs, 1)
