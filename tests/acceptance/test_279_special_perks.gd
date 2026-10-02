extends GutTest
# Task 279: special perks found in special stars can be offered in the roguelike (from the next shot of the run that
# found them, and in every later run): Star Magnet (+1.5 m star reach), Super Ball (+0.15 bounciness), Jet Pack
# (+1 s of rocket).

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_279_save.json"
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



func test_special_perks() -> void:
	assert_eq(RoguePerks.get_def("magnet")["name"], "Star Magnet")
	var base := PlayerStats.new()
	var s := RoguePerks.apply(base, ["super_ball", "jet_pack"])
	assert_almost_eq(s.restitution, base.restitution + 0.15, 0.0001)
	assert_eq(s.boost_charges, 2, "+1 s of rocket")
	var rp = load("res://scripts/core/rogue_perks.gd")
	var seen := false
	for k in 40:
		if rp.offer(k, [], 3, ["magnet"]).has("magnet"):
			seen = true
	assert_true(seen, "a found perk turns up in offers")
	for k in 40:
		assert_false(rp.offer(k, []).has("magnet"), "not before it is found")
	var run = load("res://scripts/core/rogue_run.gd").new()
	run.start(4, ["cowboy", "magnet"])
	assert_eq(run.specials, ["magnet"], "found special perks, not hats")
	run.finish_shot({"distance": 5.0, "found": ["jet_pack"]})
	assert_eq(run.specials, ["magnet", "jet_pack"], "found this run: offered from now on")
	var radius: float = run.stats().pickup_radius
	run.perks.append("magnet")
	assert_almost_eq(run.stats().pickup_radius, radius + 1.5, 0.0001, "Star Magnet reaches 1.5 m further")
	var main = _main()
	main.progress.found.assign(["super_ball"])
	main.start_rogue(9)
	assert_eq(main.rogue.specials, ["super_ball"], "a new run starts with the found perks")
