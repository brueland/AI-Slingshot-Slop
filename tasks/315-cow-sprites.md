---
id: 315-cow-sprites
status: ready
tests: [tests/acceptance/test_315_cow_sprites.gd]
files: [scripts/game/cows.gd]
---

# Nicer cows

The cows were a rectangle and some circles. Now they use sprites (assets/sprites/cow.png and cow_graze.png):
`cow_texture(index)` lowers a cow's head to graze now and then (`time` goes on in `_process`), and `_draw` draws
the sprite at SPRITE_SCALE with the feet on the ground (still only the cows on screen).

**1. `scripts/game/cows.gd`**: exactly these 4 SEARCH/REPLACE edit(s). Edit 1 adds two variables and two constants; edit 2 makes `_process()` count `time`; edit 3 adds `cow_texture()` before `_draw()`; edit 4 replaces the drawing in `_draw()`'s loop with the sprite. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var seen_terrain: int = -1
```
REPLACE:
```gdscript
var seen_terrain: int = -1
## Seconds since the start, for the cows' grazing.
var time: float = 0.0
## The cow's sprites (head up and grazing), drawn at SPRITE_SCALE with the feet at SPRITE_FEET_X of their width.
var textures: Dictionary = {"up": load("res://assets/sprites/cow.png"), "graze": load("res://assets/sprites/cow_graze.png")}
const SPRITE_SCALE: float = 0.4
const SPRITE_FEET_X: float = 0.4
```

Edit 2 - SEARCH:
```gdscript
func _process(_delta: float) -> void:
	seen_terrain = WorldView.terrain_version
```
REPLACE:
```gdscript
func _process(delta: float) -> void:
	time += delta
	seen_terrain = WorldView.terrain_version
```

Edit 3 - SEARCH:
```gdscript
	# the view moves, so the cows on screen are redrawn every frame (only those: see _draw)
	queue_redraw()


func _draw() -> void:
```
REPLACE:
```gdscript
	# the view moves, so the cows on screen are redrawn every frame (only those: see _draw)
	queue_redraw()


## The sprite for cow `index` right now: now and then it lowers its head to graze.
func cow_texture(index: int) -> Texture2D:
	return textures["graze"] if sin(time * 0.4 + index * 2.1) > 0.3 else textures["up"]


func _draw() -> void:
```

Edit 4 - SEARCH:
```gdscript
		var p := WorldView.ground_point(x)
		for leg in [-12.0, -5.0, 6.0, 12.0]:
			draw_line(p + Vector2(leg, -8), p + Vector2(leg, 0), SPOTS, 2.5)
		draw_rect(Rect2(p + Vector2(-16, -24), Vector2(32, 16)), HIDE)
		draw_circle(p + Vector2(-8, -18), 4.0, SPOTS)
		draw_circle(p + Vector2(6, -14), 3.0, SPOTS)
		draw_circle(p + Vector2(20, -24), 6.0, HIDE)
		draw_circle(p + Vector2(23, -22), 3.0, Color(1.0, 0.75, 0.8))
		draw_line(p + Vector2(17, -30), p + Vector2(15, -34), SPOTS, 2.0)
		draw_line(p + Vector2(22, -30), p + Vector2(24, -34), SPOTS, 2.0)
```
REPLACE:
```gdscript
		var p := WorldView.ground_point(x)
		var texture := cow_texture(i)
		var size := texture.get_size() * SPRITE_SCALE
		draw_texture_rect(texture, Rect2(p - Vector2(size.x * SPRITE_FEET_X, size.y - 6.0 * SPRITE_SCALE), size), false)
```

## Acceptance criteria
- `cow_texture(i)` returns the right sprite; `_draw` uses `draw_texture_rect` (no circles).
