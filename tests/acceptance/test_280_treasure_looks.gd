extends GutTest
# Task 280: special stars are big and purple on the course, finding a treasure says so ("Star Magnet found!",
# "Cowboy Hat found!"), and special perks have their own colors in the HUD's boxes.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_280_save.json"
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



func test_treasure_looks() -> void:
	var main = _main()
	main.start_game()
	var course: Array = main.session.course
	var star := -1
	for i in course.size():
		if course[i]["type"] == "star":
			star = i
			break
	course[star]["special"] = "magnet"
	main.course_view.build(course)
	var sprite = main.course_view.sprites[star]
	assert_eq(sprite.modulate, Color(0.85, 0.45, 1.0), "purple")
	assert_eq(sprite.scale, Vector2(0.75, 0.75), "and bigger")
	assert_eq(main.feedback.shot, main.session)
	var popups: int = main.popups.get_child_count()
	main.feedback._on_star_collected(star)
	assert_gt(main.popups.get_child_count(), popups + 1, "a found! popup besides the +points")
	var chips = load("res://scripts/ui/perk_chips.gd")
	for p in SpecialStars.PERKS:
		assert_true(chips.COLORS.has(p["id"]), "a color for " + str(p["id"]))
