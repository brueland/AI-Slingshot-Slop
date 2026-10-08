---
id: 299-flower-mesh
status: ready
tests: [tests/acceptance/test_299_flower_mesh.gd]
files: [scripts/game/flowers.gd]
---

# The flowers in one draw call

Flowers sprout wherever the alien bounces (up to 80). Each was a line and six circles, and the whole lot was drawn
every frame (they are spread along the meadow, so they are never all off screen): up to ~560 draw calls. Flowers now
build one mesh (`mesh_points`, `mesh_colors`, `mesh_indices`: a thin quad for the stem, small discs for the petals
and the middle) and draw it with one `canvas_item_add_triangle_array` call. They look the same.

**1. `scripts/game/flowers.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Edit 1 adds three variables; edit 2 replaces `_draw()` (the last function in the file) and adds `_add_disc()` and `_add_quad()` after it. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var seen_terrain: int = -1
```
REPLACE:
```gdscript
var seen_terrain: int = -1
## The flowers' mesh, rebuilt when they redraw (see _draw).
var mesh_points := PackedVector2Array()
var mesh_colors := PackedColorArray()
var mesh_indices := PackedInt32Array()
```

Edit 2 - SEARCH:
```gdscript
func _draw() -> void:
	for i in xs.size():
		var g := growth(i)
		var base := WorldView.ground_point(xs[i])
		var top := base + Vector2(0.0, -14.0 * g)
		draw_line(base, top, Color(0.3, 0.6, 0.3), 2.0)
		var color := COLORS[i % COLORS.size()]
		for k in 5:
			var a := TAU * k / 5.0
			draw_circle(top + Vector2(cos(a), sin(a)) * 3.5 * g, 2.5 * g, color)
		draw_circle(top, 2.0 * g, Color(1.0, 0.9, 0.3))
```
REPLACE:
```gdscript
## All the flowers as one mesh, one draw call (80 flowers of separate circles were hundreds of draw calls every
## frame): each has a stem (a thin quad), five petals and a middle (small discs).
func _draw() -> void:
	mesh_points.clear()
	mesh_colors.clear()
	mesh_indices.clear()
	for i in xs.size():
		var g := growth(i)
		var base := WorldView.ground_point(xs[i])
		var top := base + Vector2(0.0, -14.0 * g)
		_add_quad(base, top, 1.0, Color(0.3, 0.6, 0.3))
		var color := COLORS[i % COLORS.size()]
		for k in 5:
			var a := TAU * k / 5.0
			_add_disc(top + Vector2(cos(a), sin(a)) * 3.5 * g, 2.5 * g, color)
		_add_disc(top, 2.0 * g, Color(1.0, 0.9, 0.3))
	if not mesh_indices.is_empty():
		RenderingServer.canvas_item_add_triangle_array(get_canvas_item(), mesh_indices, mesh_points, mesh_colors)


## Adds a disc (8 triangles around `center`) to the mesh.
func _add_disc(center: Vector2, radius: float, color: Color) -> void:
	var first := mesh_points.size()
	mesh_points.append(center)
	mesh_colors.append(color)
	for k in 8:
		mesh_points.append(center + Vector2.from_angle(TAU * k / 8.0) * radius)
		mesh_colors.append(color)
	for k in 8:
		mesh_indices.append_array(PackedInt32Array([first, first + 1 + k, first + 1 + (k + 1) % 8]))


## Adds a line from `a` to `b`, `half_width` px to each side (2 triangles), to the mesh.
func _add_quad(a: Vector2, b: Vector2, half_width: float, color: Color) -> void:
	var side := (b - a).normalized().orthogonal() * half_width
	var first := mesh_points.size()
	mesh_points.append_array(PackedVector2Array([a + side, b + side, b - side, a - side]))
	for k in 4:
		mesh_colors.append(color)
	mesh_indices.append_array(PackedInt32Array([first, first + 1, first + 2, first, first + 2, first + 3]))
```

## Acceptance criteria
- `_draw` builds the mesh and draws it in one call; no `draw_circle`/`draw_line` in flowers.gd.
