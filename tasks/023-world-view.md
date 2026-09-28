---
id: 023-world-view
status: ready
tests: [tests/acceptance/test_023_world_view.gd]
files: [scripts/game/world_view.gd]
read: [scripts/core/balance.gd]
---

# WorldView: ground, distance markers, world <-> screen

Create `scripts/game/world_view.gd`. World units are meters with y **up**; the screen is pixels with y
**down**, 16 px per meter, ground at screen y = 0.

```gdscript
class_name WorldView
extends Node2D
## Draws the ground and distance markers. Converts world meters (y up) to screen pixels (y down).

const MARKER_SPACING_M: int = 50

var ground_texture: Texture2D


static func world_to_screen(p: Vector2) -> Vector2:
	return Vector2(p.x, -p.y) * Balance.PIXELS_PER_METER


static func screen_to_world(p: Vector2) -> Vector2:
	return Vector2(p.x, -p.y) / Balance.PIXELS_PER_METER
```

Also:
- `static func marker_distances(from_m: float, to_m: float) -> Array[int]`: every multiple of 50 that is
  `>= from_m`, `<= to_m` and greater than 0, ascending. `(0, 175)` -> `[50, 100, 150]`; `(60, 200)` -> `[100, 150, 200]`.
- `_ready()`: `ground_texture = load("res://assets/sprites/ground.png")`,
  `texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED`, `queue_redraw()`.
- `_draw()`: a brown `draw_rect` below the ground from x = -100 m to COURSE_LENGTH + 100 m (in pixels, 600 px
  deep), the grass texture tiled along the top with `draw_texture_rect(ground_texture, Rect2(left, -8, width, 32), true)`,
  and for each marker distance a short vertical line at `x = d * 16` plus a label
  `draw_string(ThemeDB.fallback_font, Vector2(x + 4, 56), "%d m" % d, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)`.

## Acceptance criteria
- `world_to_screen(Vector2(10, 2)) == Vector2(160, -32)`, and `screen_to_world` is its inverse.
- `marker_distances` as above; the node loads `res://assets/sprites/ground.png`.
