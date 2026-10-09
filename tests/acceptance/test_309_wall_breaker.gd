extends GutTest
# Task 309: the achievement "Wall Breaker" for finding the secret behind the brick wall.


func test_wall_breaker() -> void:
	var a = load("res://scripts/core/achievements.gd")
	var entry: Dictionary = a.LIST[a.LIST.size() - 1]
	assert_eq(entry["id"], "wall_breaker")
	assert_eq(entry["name"], "Wall Breaker")
	var p := Progress.new()
	assert_false(a.is_earned("wall_breaker", {"found": []}, p))
	assert_true(a.is_earned("wall_breaker", {"found": ["secret_wall"]}, p))
	var got: Array = a.unlock({"found": ["secret_wall"]}, p)
	assert_true(got.map(func(e): return e["id"]).has("wall_breaker"))
