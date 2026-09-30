extends GutTest
# Task 121: springs say "Boing!", and mud says "Splat!" with a spray of mud.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_121_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func _main_in_flight():
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	main.advance(1.0 / 60.0)
	return main


func _texts(main) -> Array:
	var texts := []
	for c in main.popups.get_children():
		texts.append(c.text)
	return texts


func test_boing_and_splat() -> void:
	var main = _main_in_flight()
	main.session.tracker.spring_hit.emit(0)
	assert_true(_texts(main).has("Boing!"), "popups: %s" % [_texts(main)])
	var before: int = main.effects.get_child_count()
	main.session.tracker.mud_hit.emit(0)
	assert_true(_texts(main).has("Splat!"))
	assert_eq(main.effects.get_child_count(), before + 1, "a spray of mud")
