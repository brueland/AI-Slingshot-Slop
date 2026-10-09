extends GutTest
# Task 306: the trees are drawn (only those on screen); a broken one is a stump with its top falling over, with
# "Crash!" or "Bonk!" popping up.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_306_save.json"
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



func test_tree_view() -> void:
	var main = _main()
	main.start_game()
	var view = null
	for w in main.feedback.watchers:
		if w.get_script() != null and w.get_script().resource_path == "res://scripts/game/tree_view.gd":
			view = w
	assert_not_null(view, "a TreeView follows every shot")
	if view == null:
		return
	assert_eq(view.get_parent(), main)
	assert_eq(view.shot, main.session)
	main.session.trees.broken[0] = true
	main.session.trees.tree_broken.emit(0)
	assert_eq(view.get_child(view.get_child_count() - 1).text, "Crash!")
	assert_eq(view.fallen[0], 0.0, "it starts to fall")
	main.camera.snap_to(WorldView.world_to_screen(Vector2(main.session.trees.xs[0], 0.0)))
	await wait_process_frames(10)
	assert_gt(view.fallen[0], 0.0, "and falls over")
	main.session.trees.tree_bounced.emit(1)
	assert_eq(view.get_child(view.get_child_count() - 1).text, "Bonk!")
	assert_true(FileAccess.get_file_as_string("res://scripts/game/tree_view.gd").contains("visible_span"), "only on screen")
