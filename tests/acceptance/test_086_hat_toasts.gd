extends GutTest
# Task 086: new hats are announced. A classic run lists them on the results screen ("New hat: Party Hat! Try it
# on in the Wardrobe"); a roguelike run toasts "New hat: <name>".

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_086_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


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


func _fly(main) -> void:
	for i in 20000:
		if main.state_name() != "FLIGHT":
			return
		main.advance(1.0 / 60.0)


func _toast_titles(main) -> Array:
	var titles := []
	if main.toast.visible:
		titles.append(main.toast.title_label.text)
	for item in main.toast.queue:
		titles.append(item[0])
	return titles


func test_first_run_shows_the_party_hat_on_the_results() -> void:
	var main = _main()
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	_fly(main)
	assert_eq(main.last_result.get("new_hats"), ["party"])
	var label = main.results_panel.get("hats_label")
	assert_true(label is Label, "results_panel.hats_label")
	if not label is Label:
		return
	assert_true(label.visible)
	assert_eq(label.text, "New hat: Party Hat! Try it on in the Wardrobe")
	assert_false(_toast_titles(main).has("New hat: Party Hat"), "classic hats are not toasted")
	main.continue_to_shop()
	main.leave_shop()
	main.launch_with_pull(FULL_PULL_45)
	_fly(main)
	assert_eq(main.last_result.get("new_hats"), [], "only announced once")
	assert_false(label.visible)


func test_roguelike_toasts_the_wizard_hat() -> void:
	var main = _main()
	main.progress.best_rogue_round = 4
	main.start_rogue(7)
	main.rogue.rounds_cleared = 5
	main.rogue.lives = 1
	main.launch_with_pull(Vector2(-12, 0))
	_fly(main)
	assert_true(main.rogue.is_over())
	assert_true(_toast_titles(main).has("New hat: Wizard Hat"), "toasts: %s" % [_toast_titles(main)])
