extends GutTest
# Task 139: spotted cows stand in the meadow and say "Moo!" when the alien lands within 5 m.

const PATH := "res://scripts/game/cows.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_139_save.json"


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


func _main_in_flight():
	var main = _main()
	main.start_game()
	main.launch_with_pull(Vector2(-84.852814, 84.852814))
	main.advance(1.0 / 60.0)
	return main


func test_cows() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var c = load(PATH)
	var xs: Array = c.layout(31, 2000.0)
	assert_eq(xs, c.layout(31, 2000.0))
	var previous := 60.0
	for x in xs:
		assert_between(x - previous, 120.0, 260.0)
		previous = x
	var cows = c.new()
	add_child_autofree(cows)
	assert_eq(cows.xs, xs)
	assert_eq(cows.react(xs[0] + 4.0), 0)
	assert_eq(cows.react(xs[0] + 20.0), -1)
	await wait_process_frames(2)
	pass_test("cows draw without errors")


func test_cows_moo() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var main = _main_in_flight()
	assert_eq(main.feedback.cows, main.cows)
	main.session.sim.position = Vector2(main.cows.xs[0] + 1.0, 0.0)
	main.session.sim.bounced.emit(6.0)
	var texts := []
	for p in main.popups.get_children():
		texts.append(p.text)
	assert_true(texts.has("Moo!"), "popups: %s" % [texts])
