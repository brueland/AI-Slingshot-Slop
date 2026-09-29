extends GutTest
# Task 056: scripts/game/effects.gd spawns one-shot CPUParticles2D effects that free themselves; main.gd puffs
# dust where the projectile bounces (bigger bounces, more dust).

const PATH := "res://scripts/game/effects.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_056_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func _effects():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	var e = load(PATH).new()
	add_child_autofree(e)
	return e


func test_dust_puff() -> void:
	var e = _effects()
	if e == null:
		return
	var p = e.spawn_dust(Vector2(100, -5), 5.0)
	assert_true(p is CPUParticles2D)
	if not p is CPUParticles2D:
		return
	assert_eq(p.get_parent(), e)
	assert_eq(p.position, Vector2(100, -5))
	assert_true(p.one_shot, "plays once")
	assert_true(p.emitting)
	assert_eq(p.amount, 10, "2 particles per m/s of impact")
	assert_almost_eq(p.lifetime, 0.6, 0.001)
	assert_not_null(p.texture)
	if p.texture != null:
		assert_eq(p.texture.resource_path, "res://assets/sprites/cloud.png")
	assert_true(p.finished.is_connected(p.queue_free), "frees itself when finished")


func test_dust_amount_is_clamped() -> void:
	var e = _effects()
	if e == null:
		return
	assert_eq(e.spawn_dust(Vector2.ZERO, 1.0).amount, 6)
	assert_eq(e.spawn_dust(Vector2.ZERO, 50.0).amount, 24)


func test_main_puffs_dust_on_bounces() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	var effects = main.get("effects")
	assert_not_null(effects, "main.effects")
	if effects == null:
		return
	assert_gt(effects.get_index(), main.projectile_view.get_index(), "effects draw over the projectile")
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	main.advance(1.0 / 60.0)
	main.session.sim.bounced.emit(9.0)
	assert_eq(effects.get_child_count(), 1)
	if effects.get_child_count() == 1:
		var p = effects.get_child(0)
		assert_true(p is CPUParticles2D)
		assert_eq(p.amount, 18)
		assert_eq(p.position, main.projectile_view.position + Vector2(0, 12), "at the projectile's feet")
