---
id: 249-endless-ground
status: ready
tests: [tests/acceptance/test_249_endless_ground.gd]
files: [scripts/game/world_view.gd]
---

# The ground never ends

Milestone 33 makes the meadow endless. Strong roguelike shots fly past 2000 m, where the grass stopped (at 1900
m) and the dirt and distance markers stopped (at 2100 m), leaving the alien over nothing. Now WorldView draws the
ground 400 m on each side of the camera and redraws it when the camera has moved half that far, so the ground and
the markers go on forever. The physics ground was always endless; this is only drawing.

**1. `scripts/game/world_view.gd`**: exactly these 7 SEARCH/REPLACE edit(s). Edits 3-6 change `ground_rect()` (it takes the stretch to cover) and `_draw()` (it draws `drawn_from_m`..`drawn_to_m`); edit 7 adds `span_around()`, `view_center_m()` and `_process()` at the end of the file; the others keep the SEARCH lines and add the new ones. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
const GROUND_DEPTH_PX: float = 600.0
```
REPLACE:
```gdscript
const GROUND_DEPTH_PX: float = 600.0
## The ground is drawn this far (meters) on each side of the camera and redrawn as the camera moves on, so it
## never ends. Its pieces start on multiples of SNAP_M (8 tiles of the 70 px textures) so redraws line up.
const DRAW_SPAN_M: float = 400.0
const SNAP_M: float = 35.0
```

Edit 2 - SEARCH:
```gdscript
var dirt_texture: Texture2D
```
REPLACE:
```gdscript
var dirt_texture: Texture2D
## The stretch of ground drawn now (meters).
var drawn_from_m: float = -105.0
var drawn_to_m: float = 730.0
```

Edit 3 - SEARCH:
```gdscript
## The dirt below the grass, in screen pixels: 100 m before the slingshot to 100 m past the course.
static func ground_rect() -> Rect2:
	var ppm := Balance.PIXELS_PER_METER
	return Rect2(-100.0 * ppm, 0.0, (Balance.COURSE_LENGTH + 200.0) * ppm, GROUND_DEPTH_PX)
```
REPLACE:
```gdscript
## The dirt below the grass from `from_m` to `to_m`, in screen pixels (by default 100 m before the slingshot to
## 100 m past the course).
static func ground_rect(from_m: float = -100.0, to_m: float = Balance.COURSE_LENGTH + 100.0) -> Rect2:
	var ppm := Balance.PIXELS_PER_METER
	return Rect2(from_m * ppm, 0.0, (to_m - from_m) * ppm, GROUND_DEPTH_PX)
```

Edit 4 - SEARCH:
```gdscript
	var ground_y: float = 0.0
	draw_texture_rect(dirt_texture, ground_rect(), true, Color(0.85, 0.75, 0.65))
```
REPLACE:
```gdscript
	var ground_y: float = 0.0
	var rect := ground_rect(drawn_from_m, drawn_to_m)
	draw_texture_rect(dirt_texture, rect, true, Color(0.85, 0.75, 0.65))
```

Edit 5 - SEARCH:
```gdscript
	var width: float = Balance.COURSE_LENGTH * Balance.PIXELS_PER_METER
	draw_texture_rect(ground_texture, Rect2(-100 * Balance.PIXELS_PER_METER, ground_y - 8, width, 32), true)
```
REPLACE:
```gdscript
	draw_texture_rect(ground_texture, Rect2(rect.position.x, ground_y - 8, rect.size.x, 32), true)
```

Edit 6 - SEARCH:
```gdscript
	var from_m: float = -100.0
	var to_m: float = Balance.COURSE_LENGTH + 100.0
	var distances: Array[int] = marker_distances(from_m, to_m)
```
REPLACE:
```gdscript
	var distances: Array[int] = marker_distances(drawn_from_m, drawn_to_m)
```

Edit 7 - SEARCH:
```gdscript
		draw_string_outline(ThemeDB.fallback_font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, 4, Color(0, 0, 0, 0.8))
```
REPLACE:
```gdscript
		draw_string_outline(ThemeDB.fallback_font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, 4, Color(0, 0, 0, 0.8))


## The stretch to draw (meters) when the middle of the view is at `center_m`: DRAW_SPAN_M on each side, starting
## on a multiple of SNAP_M, and never more than 105 m behind the slingshot.
static func span_around(center_m: float) -> Vector2:
	var from := maxf(floorf((center_m - DRAW_SPAN_M) / SNAP_M) * SNAP_M, -105.0)
	return Vector2(from, from + 2.0 * DRAW_SPAN_M + SNAP_M)


## The world x (meters) in the middle of the view.
func view_center_m() -> float:
	return (get_canvas_transform().affine_inverse() * (get_viewport_rect().size / 2.0)).x / Balance.PIXELS_PER_METER


## Redraws the ground around the camera once it has moved half a span from where it was drawn.
func _process(_delta: float) -> void:
	var span := span_around(view_center_m())
	if absf(span.x - drawn_from_m) >= DRAW_SPAN_M / 2.0:
		drawn_from_m = span.x
		drawn_to_m = span.y
		queue_redraw()
```

## Acceptance criteria
- `WorldView.span_around(center_m)` is the stretch to draw (400 m each side, 35 m steps, not before -105 m); `ground_rect(from, to)` covers it.
- `_process` redraws the ground, grass and markers around `view_center_m()` once the camera has moved 200 m.
