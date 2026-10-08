---
id: 298-star-mesh
status: ready
tests: [tests/acceptance/test_298_star_mesh.gd]
files: [scripts/game/star_field.gd]
---

# The night stars in one draw call

High up, the 90 twinkling night stars were 90 separate circles, about 350 draw calls a frame (slow in browsers).
StarField now builds them as one mesh (`star_mesh`: an 8-sided disc per star, with its own size and brightness)
and draws it with one `canvas_item_add_triangle_array` call. They look the same.

**1. `scripts/game/star_field.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds `star_mesh()` before `_draw()` and replaces the star loop at the start of `_draw()`; the shooting-star loop after it stays. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
func _draw() -> void:
	for s in stars:
		var twinkle := 0.6 + 0.4 * sin(time * 2.0 + s.z)
		draw_circle(Vector2(s.x, s.y), 1.5 + 0.8 * twinkle, Color(1.0, 1.0, 0.9, twinkle))
```
REPLACE:
```gdscript
## Every star as a small 8-sided disc with its own twinkle, all in one mesh: "points" (a center and 8 rim points
## per star), "colors" (one per point) and "indices" (8 triangles per star).
static func star_mesh(field: Array[Vector3], at_time: float) -> Dictionary:
	var points := PackedVector2Array()
	var colors := PackedColorArray()
	var indices := PackedInt32Array()
	for s in field:
		var twinkle := 0.6 + 0.4 * sin(at_time * 2.0 + s.z)
		var radius := 1.5 + 0.8 * twinkle
		var color := Color(1.0, 1.0, 0.9, twinkle)
		var center := points.size()
		points.append(Vector2(s.x, s.y))
		colors.append(color)
		for k in 8:
			points.append(Vector2(s.x, s.y) + Vector2.from_angle(TAU * k / 8.0) * radius)
			colors.append(color)
		for k in 8:
			indices.append_array(PackedInt32Array([center, center + 1 + k, center + 1 + (k + 1) % 8]))
	return {"points": points, "colors": colors, "indices": indices}


func _draw() -> void:
	# all the stars in one draw call (90 separate circles were hundreds of draw calls)
	var mesh := star_mesh(stars, time)
	RenderingServer.canvas_item_add_triangle_array(get_canvas_item(), mesh["indices"], mesh["points"], mesh["colors"])
```

## Acceptance criteria
- `StarField.star_mesh(stars, time)` returns the points, colors and indices; `_draw` draws it in one call (no `draw_circle`).
