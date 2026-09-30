extends GutTest
# Task 197: the title screen shows today's holiday greeting under the game's name.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_197_save.json"
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


func test_title_greeting() -> void:
	var main = _main()
	var title = main.title_panel
	assert_eq(title.greeting_label.get_index(), title.title_label.get_index() + 1, "right under the name")
	assert_eq(title.greeting_label.text, Greetings.today())
	assert_eq(title.greeting_label.visible, Greetings.today() != "")
	title.show_greeting("Happy Halloween!")
	assert_true(title.greeting_label.visible)
	assert_eq(title.greeting_label.text, "Happy Halloween!")
	await wait_process_frames(3)
	assert_true(main.get_viewport().get_visible_rect().encloses(title.get_global_rect()), "the title still fits on screen")
	title.show_greeting("")
	assert_false(title.greeting_label.visible)
