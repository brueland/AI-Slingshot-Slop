class_name WorldView
extends Node2D
## Draws the ground and distance markers. Converts world meters (y up) to screen pixels (y down).

const MARKER_SPACING_M: int = 50

var ground_texture: Texture2D


static func world_to_screen(p: Vector2) -> Vector2:
	return Vector2(p.x, -p.y) * Balance.PIXELS_PER_METER


static func screen_to_world(p: Vector2) -> Vector2:
	return Vector2(p.x, -p.y) / Balance.PIXELS_PER_METER


static func marker_distances(from_m: float, to_m: float) -> Array[int]:
	var distances: Array[int] = []
	var start: int = maxi(1, ceili(from_m / MARKER_SPACING_M)) * MARKER_SPACING_M
	
	for i in range(start, to_m + 1, MARKER_SPACING_M):
		if i > 0:
			distances.append(i)
	
	return distances


func _ready():
	ground_texture = load("res://assets/sprites/ground.png")
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	queue_redraw()


func _draw():
	# Draw ground rectangle below the ground
	var ground_y: float = 0.0
	draw_rect(Rect2(-100 * Balance.PIXELS_PER_METER, ground_y - 8, (Balance.COURSE_LENGTH + 200) * Balance.PIXELS_PER_METER, 32), Color(0.4, 0.3, 0.2))
	
	# Draw grass texture tiled along the top
	var width: float = Balance.COURSE_LENGTH * Balance.PIXELS_PER_METER
	draw_texture_rect(ground_texture, Rect2(-100 * Balance.PIXELS_PER_METER, ground_y - 8, width, 32), true)
	
	# Draw distance markers
	var from_m: float = -100.0
	var to_m: float = Balance.COURSE_LENGTH + 100.0
	var distances: Array[int] = marker_distances(from_m, to_m)
	
	for d in distances:
		var x: float = d * Balance.PIXELS_PER_METER
		# Draw vertical line
		draw_line(Vector2(x, ground_y - 8), Vector2(x, ground_y - 20), Color.WHITE, 2)
		# Draw label
		draw_string(ThemeDB.fallback_font, Vector2(x + 4, 56), "%d m" % d, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
