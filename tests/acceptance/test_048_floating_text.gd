extends GutTest
# Task 048: scripts/game/floating_text.gd, a "+15" popup that rises and fades; main.gd spawns one in
# main.popups when a star is collected.

const PATH := "res://scripts/game/floating_text.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_048_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func test_rises_fades_and_frees_itself() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var f = load(PATH).new()
	add_child_autoqfree(f)
	assert_true(f is Label)
	f.setup("+15", Color(1, 0.85, 0.2))
	assert_eq(f.text, "+15")
	f.advance(0.4)
	assert_almost_eq(f.position.y, -24.0, 0.001, "rises 60 px per second")
	assert_almost_eq(f.modulate.a, 0.5, 0.001, "half faded after half its 0.8 s life")
	assert_false(f.is_queued_for_deletion())
	f.advance(0.5)
	assert_true(f.is_queued_for_deletion(), "frees itself after 0.8 s")


func test_main_pops_up_star_points() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	var popups = main.get("popups")
	assert_true(popups is Node2D, "main.popups is a Node2D for popups")
	if not popups is Node2D:
		return
	main.progress.levels = {"star_value": 1}
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	main.session.tracker.star_collected.emit(0)
	var texts := []
	for c in popups.get_children():
		if c.get_script() != null and c.get_script().resource_path == PATH:
			texts.append(c.text)
	assert_eq(texts, ["+15"], "one popup with the star's value (10 + 5 for Star Polish 1)")
