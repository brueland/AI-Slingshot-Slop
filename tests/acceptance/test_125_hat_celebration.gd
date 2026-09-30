extends GutTest
# Task 125: a run that unlocks a hat (and has nothing bigger to celebrate) throws confetti with "New hat!".

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_125_save.json"


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func test_new_hat_celebration() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	main.start_game()
	var fb = main.feedback
	assert_eq(fb.celebrate({"new_hats": ["chef"]}), "New hat!")
	assert_eq(fb.celebrate({"new_best": true, "new_hats": ["party"]}), "NEW BEST!", "a new best comes first")
	assert_eq(fb.celebrate({"new_hats": []}), "", "no new hat, nothing to celebrate")
