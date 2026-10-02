extends GutTest
# Task 275: things found in the world are kept for good (Progress.found, saved): three new hats (Cowboy Hat, Viking
# Helmet, Bobble Beanie) unlock when found, and every finished shot keeps what it found.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_275_save.json"
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



func test_finds() -> void:
	var p := Progress.new()
	assert_eq(p.found, [])
	assert_eq(p.add_finds({"found": ["cowboy", "magnet"]}), ["cowboy", "magnet"])
	assert_eq(p.add_finds({"found": ["cowboy"]}), [], "already found")
	assert_eq(p.add_finds({"distance": 3.0}), [])
	var q := Progress.from_dict(JSON.parse_string(JSON.stringify(p.to_dict())))
	assert_eq(q.found, ["cowboy", "magnet"], "saved and loaded")
	assert_true(Hats.is_unlocked("cowboy", q), "a found hat is unlocked")
	assert_false(Hats.is_unlocked("viking", q))
	assert_eq(Hats.get_def("beanie")["hint"], "Pop the balloon carrying it")
	var main_text := FileAccess.get_file_as_string("res://scripts/game/main.gd")
	assert_true(main_text.contains("progress.add_finds(session.result())"),
		"main.gd keeps every finished shot's finds (checkpoint 281c plays it)")
