extends GutTest
# Task 168: the Wardrobe's "Surprise me!" button puts on a random unlocked hat (a different one when possible).

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_168_save.json"


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


## A classic shot where two balloons count as popped and three sheep as woken, flown to the end.
func _busy_shot(main) -> void:
	main.launch_with_pull(Vector2(-84.852814, 84.852814))
	main.advance(1.0 / 60.0)
	main.session.balloons.popped_count = 2
	main.feedback.sheep_woken_run = 3
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)


func test_surprise_me() -> void:
	var main = _main()
	main.title_panel.wardrobe_button.pressed.emit()
	var panel = main.wardrobe_panel
	assert_eq(panel.surprise_button.text, "Surprise me!")
	assert_eq(panel.surprise_button.get_index(), panel.close_button.get_index() - 1, "right above Done")
	assert_eq(main.choose_random_hat(), "none", "only one hat: keep it")
	main.progress.total_runs = 1
	panel.surprise_button.pressed.emit()
	assert_eq(main.progress.hat, "party", "a different hat")
	panel.surprise_button.pressed.emit()
	assert_eq(main.progress.hat, "none")
	main.progress.best_distance = 999.0
	main.progress.goal_reached = true
	main.progress.total_runs = 50
	for i in 30:
		var id: String = main.choose_random_hat()
		assert_true(Hats.is_unlocked(id, main.progress), "only unlocked hats")
		assert_eq(main.progress.hat, id)
	await wait_process_frames(3)
	assert_true(main.get_viewport().get_visible_rect().encloses(panel.get_global_rect()), "the wardrobe still fits on screen")
