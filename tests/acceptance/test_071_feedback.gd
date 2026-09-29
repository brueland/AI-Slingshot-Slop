extends GutTest
# Task 071 (refactor): scripts/game/feedback.gd takes over the flight-event reactions (sounds, particles, popups,
# camera shake) from main.gd, making room for the roguelike mode. Behavior must not change: the existing tests
# for sounds (044), shake (047), popups (048), dust (056), sparkles (057) and the boost flame (065) keep passing.

const PATH := "res://scripts/game/feedback.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_071_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func test_main_has_a_feedback_node() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	var fb = main.get("feedback")
	assert_not_null(fb, "main.feedback")
	if fb == null:
		return
	assert_eq(fb.get_script().resource_path, PATH)
	assert_eq(fb.get_parent(), main)
	assert_eq(fb.audio, main.audio)
	assert_eq(fb.effects, main.effects)
	assert_eq(fb.camera, main.camera)
	assert_eq(fb.course_view, main.course_view)
	assert_eq(fb.projectile_view, main.projectile_view)
	assert_eq(fb.popups, main.popups)
	assert_eq(fb.hud, main.hud)


func test_feedback_reacts_to_the_session() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	main.progress.levels = {"star_value": 1, "boosts": 1}
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	main.advance(1.0 / 60.0)
	main.session.tracker.star_collected.emit(0)
	assert_false(main.course_view.sprites[0].visible, "the star hides")
	assert_eq(main.audio.last_sfx, "star")
	var texts := []
	for c in main.popups.get_children():
		texts.append(c.text)
	assert_true(texts.has("+15"), "popup shows this run's star value")
	main.session.sim.bounced.emit(9.0)
	assert_eq(main.audio.last_sfx, "bounce")
	assert_true(main.camera.is_shaking())
	main.request_boost()
	assert_eq(main.audio.last_sfx, "boost")


func test_main_no_longer_handles_flight_events() -> void:
	var text := FileAccess.get_file_as_string("res://scripts/game/main.gd")
	for moved in ["func _on_star_collected", "func _on_spring_hit", "func _on_bounced", "func _on_boosted",
			"effects.spawn_", "FloatingText.new()"]:
		assert_false(text.contains(moved), "main.gd must not contain '%s' (Feedback does it)" % moved)
