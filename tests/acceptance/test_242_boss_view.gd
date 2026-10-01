extends GutTest
# Task 242: the Grumblor on the field: a BossView (behind the alien) draws the boss of a fight round with its targets
# and HP bar, and a hit makes a "-3!" popup and flashes the boss. Other shots show no boss.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_242_save.json"
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


## Round 10 of a roguelike run, a boss fight.
func _fight_round(main) -> void:
	main.start_rogue(5)
	main.rogue.round_number = 10
	main.rogue.fight = BossFight.make(10)
	main.rogue.goal = main.rogue.fight.goal()
	main._begin_aim()


func test_boss_on_the_field() -> void:
	var main = _main()
	_fight_round(main)
	var view = main.feedback.boss_view
	assert_not_null(view)
	assert_eq(view.get_script().resource_path, "res://scripts/game/boss_view.gd")
	assert_true(view.visible, "a fight round shows the boss")
	assert_eq(view.boss, main.session.boss, "the shot's boss")
	assert_eq(view.boss.x, 70.0)
	assert_eq(view.target_screen(0), WorldView.world_to_screen(Vector2(70.0, 11.5)))
	assert_lt(view.get_index(), main.projectile_view.get_index(), "drawn behind the alien")
	var popups: int = main.popups.get_child_count()
	main.session.boss.target_hit.emit(1, 3)
	assert_eq(main.popups.get_child_count(), popups + 1, "a damage popup")
	assert_gt(view.flash_left, 0.0, "the boss flashes")
	main.camera.snap_to(WorldView.world_to_screen(Vector2(70.0, 6.0)))
	await wait_frames(3)
	assert_true(view.visible)


func test_no_boss_in_classic() -> void:
	var main = _main()
	main.start_game()
	assert_false(main.feedback.boss_view.visible)
