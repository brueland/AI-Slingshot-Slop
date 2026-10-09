extends GutTest
# Task 315: the cows are drawn with sprites (head up, and now and then grazing) instead of rectangles and circles.

const PATH := "res://scripts/game/cows.gd"


func test_cow_sprites() -> void:
	assert_true(ResourceLoader.exists("res://assets/sprites/cow.png"))
	assert_true(ResourceLoader.exists("res://assets/sprites/cow_graze.png"))
	var cows = load(PATH).new()
	add_child_autofree(cows)
	cows.time = 0.0
	assert_eq(cows.cow_texture(0), load("res://assets/sprites/cow.png"), "head up")
	cows.time = PI / 0.8
	assert_eq(cows.cow_texture(0), load("res://assets/sprites/cow_graze.png"), "grazing now and then")
	cows._process(0.5)
	assert_almost_eq(cows.time, PI / 0.8 + 0.5, 0.0001, "time goes on")
	var text := FileAccess.get_file_as_string(PATH)
	assert_false(text.contains("draw_circle"), "no circles any more")
	assert_true(text.contains("draw_texture_rect"))
	await wait_process_frames(2)
