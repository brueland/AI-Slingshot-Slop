extends GutTest
# Task 057: Effects also spawns a gold star sparkle (collected stars) and an upward burst (springs); main.gd plays
# them at the star's or spring's sprite position.

const PATH := "res://scripts/game/effects.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_057_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func test_sparkle_and_burst() -> void:
	var e = load(PATH).new()
	add_child_autofree(e)
	var s = e.spawn_sparkle(Vector2(50, -80))
	assert_true(s is CPUParticles2D)
	if s is CPUParticles2D:
		assert_eq(s.position, Vector2(50, -80))
		assert_eq(s.amount, 12)
		assert_true(s.one_shot)
		assert_eq(s.texture.resource_path, "res://assets/sprites/star.png")
		assert_almost_eq(s.spread, 180.0, 0.001, "sparkles fly out in every direction")
		assert_true(s.finished.is_connected(s.queue_free))
	var b = e.spawn_burst(Vector2(300, 0))
	assert_true(b is CPUParticles2D)
	if b is CPUParticles2D:
		assert_eq(b.amount, 16)
		assert_true(b.one_shot)
		assert_eq(b.direction, Vector2(0, -1), "bursts upward")
		assert_lt(b.spread, 60.0)
		assert_true(b.finished.is_connected(b.queue_free))


func _spring_index(course: Array) -> int:
	for i in course.size():
		if course[i]["type"] == "spring":
			return i
	return -1


func test_main_sparkles_and_bursts_at_the_item() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	main.session.tracker.star_collected.emit(0)
	var effects = main.effects
	assert_eq(effects.get_child_count(), 1)
	if effects.get_child_count() >= 1:
		var p = effects.get_child(effects.get_child_count() - 1)
		assert_eq(p.texture.resource_path, "res://assets/sprites/star.png")
		assert_eq(p.position, main.course_view.sprites[0].position, "at the collected star")
	var k := _spring_index(main.session.course)
	assert_gt(k, -1, "the course has a spring")
	main.session.tracker.spring_hit.emit(k)
	assert_eq(effects.get_child_count(), 2)
	if effects.get_child_count() == 2:
		var q = effects.get_child(1)
		assert_eq(q.amount, 16, "a spring burst")
		assert_eq(q.position, main.course_view.sprites[k].position, "at the spring")
