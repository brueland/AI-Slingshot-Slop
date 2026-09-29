extends GutTest
# Task 065: a boost shoots an orange flame out behind the projectile and gives the camera a small kick.

const PATH := "res://scripts/game/effects.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_065_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func test_spawn_flame() -> void:
	var e = load(PATH).new()
	add_child_autofree(e)
	var f = e.spawn_flame(Vector2(10, -20))
	assert_true(f is CPUParticles2D)
	if not f is CPUParticles2D:
		return
	assert_eq(f.position, Vector2(10, -20))
	assert_eq(f.amount, 20)
	assert_almost_eq(f.lifetime, 0.4, 0.001)
	assert_true(f.one_shot)
	assert_true(f.direction.is_equal_approx(Vector2(-1, 1).normalized()), "out the back: down-left")
	assert_eq(f.color, Color(1.0, 0.55, 0.1), "orange")
	assert_true(f.finished.is_connected(f.queue_free))


func test_main_flames_on_boost() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	main.progress.levels = {"boosts": 1}
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	main.advance(1.0 / 60.0)
	var before: int = main.effects.get_child_count()
	assert_true(main.request_boost())
	assert_eq(main.effects.get_child_count(), before + 1)
	var f = main.effects.get_child(main.effects.get_child_count() - 1)
	assert_eq(f.amount, 20, "the flame")
	assert_eq(f.position, main.projectile_view.position)
	assert_true(main.camera.is_shaking(), "a small camera kick")
