extends GutTest
# Task 147: a classic daily challenge: fly Daily.challenge_distance(today) (150-450 m) once a day for a
# "Daily challenge done!" toast.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_147_save.json"


func before_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func after_each() -> void:
	before_each()


func _main():
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	return main


func _fly(main, pull: Vector2) -> void:
	main.launch_with_pull(pull)
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)


func test_challenge_rules() -> void:
	var d = load("res://scripts/core/daily.gd")
	var day := {"year": 2026, "month": 9, "day": 30}
	assert_almost_eq(d.challenge_distance(day), 150.0 + (20260930 % 7) * 50.0, 0.0001)
	for k in 10:
		assert_between(d.challenge_distance({"year": 2026, "month": 10, "day": 1 + k}), 150.0, 450.0)
	var p = load("res://scripts/core/progress.gd").new()
	assert_eq(p.challenge_day, "")
	assert_false(p.try_challenge(10.0, day), "too short")
	assert_true(p.try_challenge(999.0, day))
	assert_eq(p.challenge_day, "2026-09-30")
	assert_false(p.try_challenge(999.0, day), "once a day")
	assert_true(p.try_challenge(999.0, {"year": 2026, "month": 10, "day": 1}), "a new day, a new challenge")


func test_challenge_in_the_game() -> void:
	var main = _main()
	main.progress.levels = {"power": 5, "aero": 5}
	main.progress.total_runs = 3
	main.start_game()
	_fly(main, Vector2(-84.852814, 84.852814))
	var d = load("res://scripts/core/daily.gd")
	var reached: bool = float(main.last_result["distance"]) >= d.challenge_distance(d.today())
	var titles := []
	if main.toast.visible:
		titles.append(main.toast.title_label.text)
	for item in main.toast.queue:
		titles.append(item[0])
	assert_eq(titles.has("Daily challenge done!"), reached, "toast only when today's distance was reached: %s" % [titles])
	assert_eq(main.progress.challenge_day == d.key_for(d.today()), reached)
	main.continue_to_shop()
	main.leave_shop()
	main.toast.queue.clear()
	main.toast.hide()
	_fly(main, Vector2(-84.852814, 84.852814))
	var again := []
	for item in main.toast.queue:
		again.append(item[0])
	if main.toast.visible:
		again.append(main.toast.title_label.text)
	assert_false(reached and again.has("Daily challenge done!"), "only once a day")
