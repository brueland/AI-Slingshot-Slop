class_name Flowers
extends Node2D
## Flowers sprout wherever the alien bounces, so the meadow slowly blooms as you play (up to MAX_FLOWERS).

const MAX_FLOWERS: int = 80
const GROW_SECONDS: float = 0.6
const COLORS: Array[Color] = [Color(1.0, 0.5, 0.7), Color(1.0, 0.85, 0.3), Color(0.7, 0.6, 1.0), Color(1.0, 1.0, 1.0)]

var xs: Array[float] = []
var ages: Array[float] = []
## The terrain the flowers were drawn on (WorldView.terrain_version).
var seen_terrain: int = -1
## The flowers' mesh, rebuilt when they redraw (see _draw).
var mesh_points := PackedVector2Array()
var mesh_colors := PackedColorArray()
var mesh_indices := PackedInt32Array()


func grow_at(world_x: float) -> void:
	xs.append(world_x)
	ages.append(0.0)
	while xs.size() > MAX_FLOWERS:
		xs.pop_front()
		ages.pop_front()
	queue_redraw()


## How grown flower `index` is, from 0 (just sprouted) to 1.
func growth(index: int) -> float:
	return clampf(ages[index] / GROW_SECONDS, 0.0, 1.0)


func advance(delta: float) -> void:
	var growing := false
	for i in ages.size():
		if ages[i] < GROW_SECONDS:
			ages[i] += delta
			growing = true
	if growing or seen_terrain != WorldView.terrain_version:
		seen_terrain = WorldView.terrain_version
		queue_redraw()


func _process(delta: float) -> void:
	advance(delta)


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
