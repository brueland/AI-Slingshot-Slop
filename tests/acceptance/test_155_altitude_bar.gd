extends GutTest
# Task 155: a thin height bar on the HUD fills up as the alien climbs (full at 60 m).

const PATH := "res://scripts/ui/altitude_bar.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_155_save.json"


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


func test_altitude_bar() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var bar = load(PATH).new()
	add_child_autofree(bar)
	bar.set_height(30.0)
	assert_almost_eq(bar.value, 0.5, 0.0001)
	bar.set_height(200.0)
	assert_eq(bar.value, 1.0)
	bar.set_height(-5.0)
	assert_eq(bar.value, 0.0)
	var main = _main()
	main.start_game()
	main.launch_with_pull(Vector2(-10, 119))
	for i in 60:
		main.advance(1.0 / 60.0)
	assert_gt(main.hud.altitude_bar.value, 0.0, "the bar rises in flight")
	await wait_process_frames(2)
	assert_true(main.get_viewport().get_visible_rect().encloses(main.hud.altitude_bar.get_global_rect()), "on screen")
