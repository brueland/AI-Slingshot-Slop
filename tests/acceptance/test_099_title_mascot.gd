extends GutTest
# Task 099: the title screen has the alien at the top (scripts/ui/title_mascot.gd), bobbing and wearing the
# player's hat.

const PATH := "res://scripts/ui/title_mascot.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_099_save.json"


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


func test_mascot_on_the_title() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var main = _main()
	var mascot = main.title_panel.get("mascot")
	assert_not_null(mascot, "title_panel.mascot")
	if mascot == null:
		return
	assert_eq(mascot.get_script().resource_path, PATH)
	assert_eq(mascot.get_parent(), main.title_panel.box)
	assert_eq(mascot.get_index(), main.title_panel.title_label.get_index() - 1, "right above the game name (task 217)")
	assert_false(mascot.decor.top_level, "the hat is drawn inside the title panel")
	var y0: float = mascot.center().y
	await wait_seconds(0.3)
	assert_ne(mascot.center().y, y0, "it bobs")
	assert_between(mascot.bob_offset(), -6.0, 6.0)
	assert_eq(mascot.decor.position, mascot.center(), "the hat follows the bob")
	var screen: Rect2 = main.get_viewport().get_visible_rect()
	assert_true(screen.encloses(main.title_panel.get_global_rect()), "the title still fits on screen")


func test_mascot_wears_the_hat() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var first = _main()
	first.progress.total_runs = 1
	first.choose_hat("party")
	assert_eq(first.title_panel.mascot.decor.hat, "party", "a new hat shows on the title right away")
	var second = _main()
	assert_eq(second.title_panel.mascot.decor.hat, "party", "and after a restart")
	second.reset_progress()
	assert_eq(second.title_panel.mascot.decor.hat, "none")
