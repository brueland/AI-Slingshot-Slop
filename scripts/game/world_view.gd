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
var drawn_from_m: float = -105.0
var drawn_to_m: float = 730.0


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
	var rect := ground_rect(drawn_from_m, drawn_to_m)
	draw_texture_rect(dirt_texture, rect, true, Color(0.85, 0.75, 0.65))
	
	# Draw grass texture tiled along the top
	draw_texture_rect(ground_texture, Rect2(rect.position.x, ground_y - 8, rect.size.x, 32), true)
	
	# Draw distance markers
	var distances: Array[int] = marker_distances(drawn_from_m, drawn_to_m)
	
	for d in distances:
		var x: float = d * Balance.PIXELS_PER_METER
		# Draw vertical line
		draw_line(Vector2(x, ground_y - 8), Vector2(x, ground_y - 20), Color.WHITE, 2)
		# Draw label with dark outline
		var pos: Vector2 = Vector2(x + 4, 56)
		var text: String = "%d m" % d
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
