extends GutTest
# Task 208: the alien makes its "focus" face while the slingshot is pulled (looking where it will fly) and winces
# ("ouch") on a hard bounce.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_208_save.json"
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


func test_focus_and_ouch() -> void:
	var main = _main()
	main.start_game()
	var decor = main.projectile_view.decor
	assert_true(main.slingshot.begin_drag(main.slingshot.global_position))
	main.slingshot.update_drag(main.slingshot.global_position + Vector2(-60, 40))
	main.advance(1.0 / 60.0)
	assert_eq(decor.face, "focus", "concentrating while aiming")
	assert_almost_eq(decor.look, Vector2(60, -40).normalized(), Vector2(0.06, 0.06), "looking where it will fly")
	main.slingshot.cancel_drag()
	main.advance(1.0 / 60.0)
	assert_eq(decor.face, "happy", "relaxed again")
	main.launch_with_pull(PULL)
	main.advance(1.0 / 60.0)
	main.feedback._on_bounced(12.0)
	assert_eq(decor.face, "ouch", "a hard bounce hurts")
	assert_gt(main.projectile_view.ouch_left, 0.0)
