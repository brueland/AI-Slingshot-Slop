class_name WorldView
extends Node2D
## Draws the ground and distance markers. Converts world meters (y up) to screen pixels (y down).

const MARKER_SPACING_M: int = 50
const GROUND_DEPTH_PX: float = 600.0
## The ground is drawn this far (meters) on each side of the camera and redrawn as the camera moves on, so it
## never ends. Its pieces start on multiples of SNAP_M (8 tiles of the 70 px textures) so redraws line up.
const DRAW_SPAN_M: float = 400.0
const SNAP_M: float = 35.0

var ground_texture: Texture2D
var dirt_texture: Texture2D
## The stretch of ground drawn now (meters).
var drawn_from_m: float = -175.0
var drawn_to_m: float = 660.0
## The current shot's ground (its hills); null = flat. main.gd sets it for every new shot (use_terrain).
static var terrain: FlightSim = null
## Goes up every time the terrain changes, so the ground and its decorations know to redraw.
static var terrain_version: int = 0
## The WorldView that showed the terrain (instance id); the ground goes back to flat when it leaves the tree.
static var terrain_owner: int = 0
var drawn_version: int = 0


static func world_to_screen(p: Vector2) -> Vector2:
	return Vector2(p.x, -p.y) * Balance.PIXELS_PER_METER


static func screen_to_world(p: Vector2) -> Vector2:
	return Vector2(p.x, -p.y) / Balance.PIXELS_PER_METER


## The dirt below the grass from `from_m` to `to_m`, in screen pixels (by default 100 m before the slingshot to
## 100 m past the course).
static func ground_rect(from_m: float = -100.0, to_m: float = Balance.COURSE_LENGTH + 100.0) -> Rect2:
	var ppm := Balance.PIXELS_PER_METER
	return Rect2(from_m * ppm, 0.0, (to_m - from_m) * ppm, GROUND_DEPTH_PX)


static func marker_distances(from_m: float, to_m: float) -> Array[int]:
	var distances: Array[int] = []
	var start: int = maxi(1, ceili(from_m / MARKER_SPACING_M)) * MARKER_SPACING_M
	
	for i in range(start, to_m + 1, MARKER_SPACING_M):
		if i > 0:
			distances.append(i)
	
	return distances


func _ready():
	ground_texture = load("res://assets/sprites/ground.png")
	dirt_texture = load("res://assets/sprites/mud.png")
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	queue_redraw()


func _draw():
	# Draw dirt below the ground
	var ground_y: float = 0.0
	if terrain != null and terrain.hills > 0.0:
		_draw_hills(drawn_from_m, drawn_to_m)
	else:
		var rect := ground_rect(drawn_from_m, drawn_to_m)
		draw_texture_rect(dirt_texture, rect, true, Color(0.85, 0.75, 0.65))
		# Draw grass texture tiled along the top
		draw_texture_rect(ground_texture, Rect2(rect.position.x, ground_y - 8, rect.size.x, 32), true)
	
	# Draw distance markers
	var distances: Array[int] = marker_distances(drawn_from_m, drawn_to_m)
	
	for d in distances:
		var x: float = d * Balance.PIXELS_PER_METER
		var gy: float = ground_point(float(d)).y
		# Draw vertical line
		draw_line(Vector2(x, gy - 8), Vector2(x, gy - 20), Color.WHITE, 2)
		# Draw label with dark outline
		var pos: Vector2 = Vector2(x + 4, gy + 56)
		var text: String = "%d m" % d
		draw_string_outline(ThemeDB.fallback_font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, 4, Color(0, 0, 0, 0.8))


## The stretch to draw (meters) when the middle of the view is at `center_m`: DRAW_SPAN_M on each side, starting
## on a multiple of SNAP_M, and never more than 175 m behind the slingshot (the brick wall is at 120 m).
static func span_around(center_m: float) -> Vector2:
	var from := maxf(floorf((center_m - DRAW_SPAN_M) / SNAP_M) * SNAP_M, -175.0)
	return Vector2(from, from + 2.0 * DRAW_SPAN_M + SNAP_M)


## The world x (meters) in the middle of the view.
func view_center_m() -> float:
	return (get_canvas_transform().affine_inverse() * (get_viewport_rect().size / 2.0)).x / Balance.PIXELS_PER_METER


## Redraws the ground around the camera once it has moved half a span from where it was drawn.
func _process(_delta: float) -> void:
	var span := span_around(view_center_m())
	if absf(span.x - drawn_from_m) >= DRAW_SPAN_M / 2.0 or drawn_version != terrain_version:
		drawn_version = terrain_version
		drawn_from_m = span.x
		drawn_to_m = span.y
		queue_redraw()


## Makes `sim` the ground everything is drawn on (its hills; null = flat ground).
static func use_terrain(sim: FlightSim) -> void:
	terrain = sim
	terrain_version += 1


## Shows `sim`'s hills as this world's ground (main.gd calls it for every new shot).
func show_terrain(sim: FlightSim) -> void:
	use_terrain(sim)
	terrain_owner = get_instance_id()


func _exit_tree() -> void:
	if terrain_owner == get_instance_id():
		terrain_owner = 0
		use_terrain(null)


## The ground's height (meters) under x for the current shot: its hills (landing-zone dips are drawn by ZoneMarker).
static func ground_height_at(x_m: float) -> float:
	return terrain.terrain_height(x_m) if terrain != null else 0.0


## The point on the ground under x, in screen pixels.
static func ground_point(x_m: float) -> Vector2:
	return world_to_screen(Vector2(x_m, ground_height_at(x_m)))


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
