extends GutTest
# Task 214: the game's font is Fredoka (a FontVariation at weight 600); the title logo uses Lilita One.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_214_save.json"
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


func test_fonts() -> void:
	var theme: Theme = load("res://scripts/ui/ui_theme.gd").build()
	var font = theme.default_font
	assert_true(font is FontVariation, "Fredoka at a set weight")
	if font is FontVariation:
		assert_eq(font.base_font.resource_path, "res://assets/fonts/Fredoka.ttf")
	assert_eq(theme.default_font_size, 22)
	assert_true(theme.is_type_variation("LogoLabel", "Label"))
	assert_eq(theme.get_font("font", "LogoLabel").resource_path, "res://assets/fonts/LilitaOne-Regular.ttf")
	assert_eq(theme.get_font_size("font_size", "LogoLabel"), 76)
	var main = _main()
	assert_eq(main.title_panel.title_label.theme_type_variation, "LogoLabel")
	await wait_process_frames(3)
	_on_screen(main, main.title_panel.title_label, "the logo")
	for path in ["res://assets/fonts/Fredoka-OFL.txt", "res://assets/fonts/LilitaOne-OFL.txt"]:
		assert_true(FileAccess.file_exists(path), "the font license ships with the game: " + path)
