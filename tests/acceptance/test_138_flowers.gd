extends GutTest
# Task 138: flowers sprout wherever the alien bounces (the meadow blooms as you play; at most 80 flowers).

const PATH := "res://scripts/game/flowers.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_138_save.json"


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


func test_flowers() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var f = load(PATH).new()
	add_child_autofree(f)
	f.grow_at(12.0)
	assert_eq(f.xs, [12.0])
	assert_eq(f.growth(0), 0.0, "just sprouted")
	f.advance(0.3)
	assert_almost_eq(f.growth(0), 0.5, 0.0001)
	f.advance(1.0)
	assert_eq(f.growth(0), 1.0, "fully grown")
	for i in 100:
		f.grow_at(float(i))
	assert_eq(f.xs.size(), 80, "at most 80 flowers")
	assert_eq(f.xs[0], 20.0, "the oldest ones go first")
	await wait_process_frames(2)
	pass_test("flowers draw without errors")


func test_bounces_grow_flowers() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var main = _main_in_flight()
	assert_not_null(main.get("flowers"), "main.flowers")
	if main.get("flowers") == null:
		return
	assert_eq(main.feedback.flowers, main.flowers)
	main.session.sim.position = Vector2(33.0, 0.0)
	main.session.sim.bounced.emit(6.0)
	assert_eq(main.flowers.xs, [33.0], "a flower where the alien bounced")
