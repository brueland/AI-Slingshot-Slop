extends GutTest
# Task 250: the far hills repeat without a seam (their wave fits the repeating width exactly: two waves in 1800 px),
# and the meadow's rocks and plants go on to 8000 m, past the 2000 m course.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_250_save.json"
const PULL := Vector2(-84.852814, 84.852814)


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


func _on_screen(main, control: Control, what: String) -> void:
	assert_true(main.get_viewport().get_visible_rect().encloses(control.get_global_rect()), what + " is on screen")



func test_seamless_hills() -> void:
	var h = load("res://scripts/game/hills.gd")
	for band in [[140.0, 90.0, 0.0], [60.0, 60.0, 2.0]]:
		var top: PackedVector2Array = h.outline(band[0], band[1], band[2])
		var n := top.size()
		assert_almost_eq(top[0].y, top[n - 1].y, 0.001, "the two ends meet")


func test_scenery_goes_on() -> void:
	var length = load("res://scripts/game/scenery.gd").get_script_constant_map().get("LENGTH")
	assert_eq(length, 8000.0)
	var main = _main()
	var far := 0.0
	for sprite in main.scenery.sprites:
		far = maxf(far, WorldView.screen_to_world(sprite.position).x)
	assert_gt(far, 7900.0, "rocks and plants all the way to 8000 m")
