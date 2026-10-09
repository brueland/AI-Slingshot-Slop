---
id: 314-sheep-sprites
status: ready
tests: [tests/acceptance/test_314_sheep_sprites.gd]
files: [scripts/game/critters.gd]
---

# Nicer sheep

The sheep were drawn with a few circles. Now they use sprites (assets/sprites/sheep.png, sheep_graze.png and the
black ones): `sheep_texture(index)` picks the black or white sprite, grazing while the head is down, and `_draw`
draws it at SPRITE_SCALE with the feet on the ground (still only the sheep on screen).

**1. `scripts/game/critters.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Edit 1 adds a variable and two constants; edit 2 adds `sheep_texture()` before `_process()`; edit 3 replaces the drawing at the end of `_draw()`'s loop with the sprite. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var period: float = Balance.COURSE_LENGTH
```
REPLACE:
```gdscript
var period: float = Balance.COURSE_LENGTH
## The flock's sprites (white and black, head up and grazing), drawn at SPRITE_SCALE with the feet at
## SPRITE_FEET_X of their width.
var textures: Dictionary = {"up": load("res://assets/sprites/sheep.png"), "graze": load("res://assets/sprites/sheep_graze.png"),
	"black_up": load("res://assets/sprites/sheep_black.png"), "black_graze": load("res://assets/sprites/sheep_black_graze.png")}
const SPRITE_SCALE: float = 0.4
const SPRITE_FEET_X: float = 0.4
```

Edit 2 - SEARCH:
```gdscript
	return maxf(0.0, sin(time * 1.5 + index * 1.3)) * 3.0


func _process(delta: float) -> void:
```
REPLACE:
```gdscript
	return maxf(0.0, sin(time * 1.5 + index * 1.3)) * 3.0


## The sprite for sheep `index` right now: black or white, grazing while its head is down.
func sheep_texture(index: int) -> Texture2D:
	var key := ("black_" if is_black(index) else "") + ("graze" if head_bob(index) > 1.5 else "up")
	return textures[key]


func _process(delta: float) -> void:
```

Edit 3 - SEARCH:
```gdscript
		draw_line(p + Vector2(-6, -5), p + Vector2(-6, 0), FACE, 2.0)
		draw_line(p + Vector2(6, -5), p + Vector2(6, 0), FACE, 2.0)
		for o in [Vector2(-7, -11), Vector2(0, -14), Vector2(7, -11), Vector2(-3, -8), Vector2(4, -8)]:
			draw_circle(p + o, 6.0, BLACK_WOOL if is_black(i) else WOOL)
		draw_circle(p + Vector2(12, -13 + head_bob(i)), 4.0, FACE)
		draw_circle(p + Vector2(13, -14 + head_bob(i)), 1.0, Color.WHITE)
```
REPLACE:
```gdscript
		var texture := sheep_texture(i)
		var size := texture.get_size() * SPRITE_SCALE
		draw_texture_rect(texture, Rect2(p - Vector2(size.x * SPRITE_FEET_X, size.y - 6.0 * SPRITE_SCALE), size), false)
```

## Acceptance criteria
- `sheep_texture(i)` returns the right sprite; `_draw` uses `draw_texture_rect` (no circles).
