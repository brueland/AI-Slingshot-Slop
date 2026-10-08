extends GutTest
# Task 029: scripts/game/course_view.gd shows course items as sprites and milestone flags.

const PATH := "res://scripts/game/course_view.gd"
const ITEMS := [
	{"type": "star", "x": 40.0, "y": 5.0},
	{"type": "spring", "x": 100.0, "y": 0.0},
	{"type": "mud", "x": 130.0, "y": 0.0},
]


func _cv():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	var cv = load(PATH).new()
	add_child_autofree(cv)
	return cv


func test_milestone_flags() -> void:
	var cv = _cv()
	if cv == null:
		return
	assert_eq(cv.flags.size(), 34, "one flag per milestone up to 30000 m (task 292)")
	if cv.flags.size() == 34:
		assert_eq(cv.flags[0].position.x, 50.0 * 16.0)
		assert_eq(cv.flags[4].position.x, 1000.0 * 16.0)
		assert_eq(cv.flags[0].texture.resource_path, "res://assets/sprites/flag.png")
		assert_eq(cv.flags[4].texture.resource_path, "res://assets/sprites/goal_flag.png", "the 1000 m goal flag")


func test_build_creates_one_sprite_per_item() -> void:
	var cv = _cv()
	if cv == null:
		return
	cv.build(ITEMS)
	assert_eq(cv.item_count(), 3)
	assert_eq(cv.sprites.size(), 3)
	if cv.sprites.size() < 3:
		return
	assert_true(cv.sprites[0] is Sprite2D)
	assert_eq(cv.sprites[0].texture.resource_path, "res://assets/sprites/star.png")
	assert_eq(cv.sprites[1].texture.resource_path, "res://assets/sprites/spring.png")
	assert_eq(cv.sprites[2].texture.resource_path, "res://assets/sprites/mud.png")
	assert_eq(cv.sprites[0].position, Vector2(640, -80), "star at world (x, y)")
	assert_eq(cv.sprites[1].position, Vector2(1600, 0), "spring at world (x, 0)")
	assert_eq(cv.sprites[2].position, Vector2(2128, 0), "mud centered at world (x + MUD_WIDTH / 2, 0)")


func test_mark_collected_hides_the_sprite() -> void:
	var cv = _cv()
	if cv == null:
		return
	cv.build(ITEMS)
	cv.mark_collected(0)
	assert_false(cv.sprites[0].visible)
	assert_true(cv.sprites[1].visible)
	cv.mark_collected(99)
	cv.mark_collected(-1)
	pass_test("out-of-range indexes are ignored")


func test_rebuild_replaces_the_old_sprites() -> void:
	var cv = _cv()
	if cv == null:
		return
	cv.build(ITEMS)
	var old = cv.sprites[0]
	cv.build([ITEMS[1]])
	assert_eq(cv.item_count(), 1)
	assert_false(is_instance_valid(old) and old.is_inside_tree(), "old sprites are removed")
	assert_eq(cv.flags.size(), 34, "flags stay")
