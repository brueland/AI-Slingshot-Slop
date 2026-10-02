extends GutTest
# Task 259: every UFO shines a tractor beam down to the ground; flying into one pulls the alien gently up (9 m/s per
# second, less than gravity).

const PATH := "res://scripts/core/tractor_beams.gd"


func _session_at(x: float) -> RunSession:
	var s := RunSession.new(PlayerStats.new(), 3)
	s.launch_from_pull(Vector2(-60, 60))
	s.sim.position = Vector2(x, 12.0)
	s.sim.velocity = Vector2(1.0, 0.0)
	return s


func test_tractor_beams() -> void:
	var tb = load(PATH)
	assert_eq(tb.SPOTS_M, Ufo.SPOTS_M, "a beam under every UFO")
	assert_eq(tb.HEIGHT_M, Ufo.HEIGHT_M)
	assert_true(tb.inside(Vector2(180.0, 10.0)))
	assert_true(tb.inside(Vector2(182.5, 1.0)), "wider near the ground")
	assert_false(tb.inside(Vector2(185.0, 10.0)), "outside the cone")
	assert_false(tb.inside(Vector2(180.0, 25.0)), "above the UFO")
	assert_false(tb.inside(Vector2(300.0, 10.0)), "no UFO there")
	var beam := _session_at(179.5)
	var plain := _session_at(300.0)
	beam.step(0.05)
	plain.step(0.05)
	assert_almost_eq(beam.sim.velocity.y - plain.sim.velocity.y, 9.0 * 0.05, 0.02, "pulled up inside the beam")
