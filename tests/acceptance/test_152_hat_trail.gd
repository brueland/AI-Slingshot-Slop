extends GutTest
# Task 152: the trail's colors follow the hat: rainbow for the party hat, purple for the wizard hat, gold for the crown.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_152_save.json"


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


func test_trail_styles() -> void:
	var t = load("res://scripts/game/trail.gd").new()
	add_child_autofree(t)
	t.set_style("party")
	assert_eq(t.style, "party")
	assert_eq(t.gradient.get_point_count(), 4, "a rainbow")
	t.set_style("crown")
	assert_eq(t.gradient.get_color(1), Color(1.0, 0.85, 0.3, 0.8), "gold")
	t.set_style("none")
	assert_eq(t.gradient.get_color(1), Color(1, 1, 1, 0.7), "white without a hat")
	var main = _main()
	main.progress.total_runs = 1
	main.choose_hat("party")
	main.start_game()
	assert_eq(main.trail.style, "party", "every shot uses the hat's trail")
