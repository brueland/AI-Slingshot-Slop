class_name StarField
extends Node2D
## Twinkling stars in the high sky. Invisible near the ground; they fade in as the alien climbs.

const COUNT: int = 90
const SEED: int = 3
const FADE_START_M: float = 40.0
const FADE_FULL_M: float = 150.0

var stars: Array[Vector3] = []
var time: float = 0.0
var shooting: Array[Vector3] = []


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = SEED
	for i in COUNT:
		stars.append(Vector3(rng.randf_range(-900.0, 900.0), rng.randf_range(-800.0, 300.0), rng.randf_range(0.0, TAU)))
	modulate.a = 0.0


## How visible the stars are at a height: 0 below 40 m, 1 from 150 m up.
static func alpha_for_height(height_m: float) -> float:
	return clampf((height_m - FADE_START_M) / (FADE_FULL_M - FADE_START_M), 0.0, 1.0)


func set_height(height_m: float) -> void:
	modulate.a = alpha_for_height(height_m)


func _process(delta: float) -> void:
	if modulate.a > 0.0:
		time += delta
		advance_shooting(delta)
		queue_redraw()


## A shooting star every 3 seconds while the stars are out; each one crosses the sky in 1 second.
func advance_shooting(delta: float) -> void:
	if fmod(time, 3.0) < delta:
		shooting.append(Vector3(fposmod(time * 211.0, 1400.0) - 700.0, -650.0, 0.0))
	for i in range(shooting.size() - 1, -1, -1):
		var s := shooting[i]
		s.z += delta
		if s.z >= 1.0:
			shooting.remove_at(i)
		else:
			shooting[i] = s


## Where a shooting star's head is: it starts at (x, y) and flies down and to the right.
static func shooting_position(s: Vector3) -> Vector2:
	return Vector2(s.x, s.y) + Vector2(420.0, 180.0) * s.z


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
	for streak in shooting:
		var head := shooting_position(streak)
		draw_line(head, head - Vector2(60.0, 26.0), Color(1.0, 1.0, 0.9, 1.0 - streak.z), 2.0)
