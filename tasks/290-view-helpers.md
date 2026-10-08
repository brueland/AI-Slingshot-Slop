---
id: 290-view-helpers
status: ready
tests: [tests/acceptance/test_290_view_helpers.gd]
files: [scripts/game/world_view.gd]
---

# View helpers and a lighter ground

Two things make the meadow endless and smooth: decorations repeat their layout and draw only what is on screen,
and the hilly ground was ~800 separate draw calls (every 2 m piece of dirt and of grass was its own textured
polygon), which is slow in browsers. WorldView gets `visible_span` (the stretch of the world on screen),
`repeat_x` (the copy of a repeating decoration nearest a place) and `ground_strip`; `_draw_hills` now draws the dirt
and the grass as one triangle strip each, which looks the same.

**1. `scripts/game/world_view.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Edit 1 adds `visible_span()` and `repeat_x()` after `screen_to_world()`; edit 2 replaces `_draw_hills()` (the last function in the file) and adds `ground_strip()` and `_draw_strip()` after it. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
static func screen_to_world(p: Vector2) -> Vector2:
	return Vector2(p.x, -p.y) / Balance.PIXELS_PER_METER
```
REPLACE:
```gdscript
static func screen_to_world(p: Vector2) -> Vector2:
	return Vector2(p.x, -p.y) / Balance.PIXELS_PER_METER


## The stretch of the world on screen for `item` (meters: x = left edge, y = right edge), plus `margin_m` on each
## side. Decorations draw only what is in it.
static func visible_span(item: CanvasItem, margin_m: float) -> Vector2:
	var to_world := item.get_canvas_transform().affine_inverse()
	var width := item.get_viewport_rect().size.x
	var left := (to_world * Vector2.ZERO).x / Balance.PIXELS_PER_METER
	var right := (to_world * Vector2(width, 0.0)).x / Balance.PIXELS_PER_METER
	return Vector2(left - margin_m, right + margin_m)


## Decorations laid out over `period_m` meters repeat every `period_m` meters after that, so the meadow never runs
## out: the x of the copy of `base_m` nearest `near_m` (never before `base_m` itself).
static func repeat_x(base_m: float, period_m: float, near_m: float) -> float:
	return base_m + period_m * maxf(0.0, roundf((near_m - base_m) / period_m))
```

Edit 2 - SEARCH:
```gdscript
## Draws the dirt and the grass following the hills from `from_m` to `to_m`, in 2 m pieces (70 px textures, tiled).
func _draw_hills(from_m: float, to_m: float) -> void:
	var tile := 70.0
	var x := from_m
	while x < to_m:
		var a := ground_point(x)
		var b := ground_point(x + 2.0)
		var deep_a := Vector2(a.x, GROUND_DEPTH_PX)
		var deep_b := Vector2(b.x, GROUND_DEPTH_PX)
		draw_colored_polygon(PackedVector2Array([a, b, deep_b, deep_a]), Color(0.85, 0.75, 0.65),
			PackedVector2Array([a / tile, b / tile, deep_b / tile, deep_a / tile]), dirt_texture)
		draw_colored_polygon(PackedVector2Array([a + Vector2(0, -8), b + Vector2(0, -8), b + Vector2(0, 24), a + Vector2(0, 24)]),
			Color.WHITE, PackedVector2Array([Vector2(a.x / tile, 0.0), Vector2(b.x / tile, 0.0), Vector2(b.x / tile, 32.0 / tile),
			Vector2(a.x / tile, 32.0 / tile)]), ground_texture)
		x += 2.0
```
REPLACE:
```gdscript
## Draws the dirt and the grass following the hills from `from_m` to `to_m`: each is one strip of 2 m pieces
## (70 px textures, tiled), so the whole ground is two draw calls.
func _draw_hills(from_m: float, to_m: float) -> void:
	_draw_strip(ground_strip(from_m, to_m, 0.0, GROUND_DEPTH_PX, true), Color(0.85, 0.75, 0.65), dirt_texture)
	_draw_strip(ground_strip(from_m, to_m, -8.0, 24.0, false), Color.WHITE, ground_texture)


## The ground from `from_m` to `to_m` as one strip of 2 m pieces: "points" (two per x: the ground + `top_px`,
## and the bottom), "uvs" (70 px tiles) and "indices" (two triangles per piece). The bottom is the screen depth
## `bottom_px` when `flat_bottom` (the dirt), else the ground + `bottom_px` (the grass band, its texture top to bottom).
static func ground_strip(from_m: float, to_m: float, top_px: float, bottom_px: float, flat_bottom: bool) -> Dictionary:
	var tile := 70.0
	var points := PackedVector2Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	var x := from_m
	while true:
		var g := ground_point(x)
		var top := g + Vector2(0.0, top_px)
		var bottom := Vector2(g.x, bottom_px) if flat_bottom else g + Vector2(0.0, bottom_px)
		points.append(top)
		points.append(bottom)
		if flat_bottom:
			uvs.append(top / tile)
			uvs.append(bottom / tile)
		else:
			uvs.append(Vector2(g.x / tile, 0.0))
			uvs.append(Vector2(g.x / tile, (bottom_px - top_px) / tile))
		var n := points.size()
		if n >= 4:
			indices.append_array(PackedInt32Array([n - 4, n - 2, n - 1, n - 4, n - 1, n - 3]))
		if x >= to_m:
			break
		x = minf(x + 2.0, to_m)
	return {"points": points, "uvs": uvs, "indices": indices}


## Draws a ground_strip in one draw call.
func _draw_strip(strip: Dictionary, color: Color, texture: Texture2D) -> void:
	var points: PackedVector2Array = strip["points"]
	var colors := PackedColorArray()
	colors.resize(points.size())
	colors.fill(color)
	RenderingServer.canvas_item_add_triangle_array(get_canvas_item(), strip["indices"], points, colors, strip["uvs"],
		PackedInt32Array(), PackedFloat32Array(), texture.get_rid())
```

## Acceptance criteria
- `visible_span(item, margin)`, `repeat_x(base, period, near)` and `ground_strip(...)` work as described.
- `_draw_hills` draws two strips with `RenderingServer.canvas_item_add_triangle_array`.
