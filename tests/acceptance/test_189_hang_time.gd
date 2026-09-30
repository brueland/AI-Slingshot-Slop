extends GutTest
# Task 189: a single hop of 3 seconds or more in the air gets a "Hang time!" popup when it lands.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_189_save.json"
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


func _hangs(main) -> int:
	var count := 0
	for child in main.popups.get_children():
		if child is FloatingText and child.text.begins_with("Hang time!"):
			count += 1
	return count


func test_hang_time() -> void:
	var main = _main()
	main.start_game()
	main.launch_with_pull(PULL)
	main.advance(1.0 / 60.0)
	assert_eq(main.feedback.hop_start, 0.0)
	main.session.sim.air_time = 5.0
	main.feedback._on_bounced(3.0)
	assert_eq(_hangs(main), 1, "a 5 s hop")
	for child in main.popups.get_children():
		if child is FloatingText and child.text.begins_with("Hang time!"):
			assert_eq(child.text, "Hang time! 5.0 s")
	assert_eq(main.feedback.hop_start, 5.0, "the next hop starts now")
	main.session.sim.air_time = 6.5
	main.feedback._on_bounced(3.0)
	assert_eq(_hangs(main), 1, "a 1.5 s hop is not hang time")
	main.go_to_title()
	main.start_game()
	main.launch_with_pull(PULL)
	main.advance(1.0 / 60.0)
	assert_eq(main.feedback.hop_start, 0.0, "a new shot starts over")
