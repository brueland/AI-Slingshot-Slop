extends GutTest
# Task 314: the sheep are drawn with sprites (white or black, head up or grazing) instead of circles.

const PATH := "res://scripts/game/critters.gd"


func test_sheep_sprites() -> void:
	for name in ["sheep", "sheep_graze", "sheep_black", "sheep_black_graze"]:
		assert_true(ResourceLoader.exists("res://assets/sprites/%s.png" % name), name)
	var c = load(PATH).new()
	add_child_autofree(c)
	c.build(11, 2000.0)
	c.time = 0.0
	assert_eq(c.sheep_texture(0), load("res://assets/sprites/sheep.png"), "head up")
	c.time = PI / 3.0
	assert_eq(c.sheep_texture(0), load("res://assets/sprites/sheep_graze.png"), "grazing while the head is down")
	c.time = (PI - 2.6) / 1.5
	assert_eq(c.sheep_texture(2), load("res://assets/sprites/sheep_black.png"), "every 4th sheep (from 2) is black")
	var text := FileAccess.get_file_as_string(PATH)
	assert_false(text.contains("draw_circle"), "no circles any more")
	assert_true(text.contains("draw_texture_rect"))
	c.queue_redraw()
	await wait_process_frames(2)
