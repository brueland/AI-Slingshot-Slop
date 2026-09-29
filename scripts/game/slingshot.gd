class_name Slingshot
extends Node2D
## The slingshot. The node's position is the pouch rest point (anchor), in screen pixels.
## pull = drag point - anchor. Posts are drawn from the anchor down to the ground.

signal launched(pull: Vector2)

const GRAB_RADIUS: float = 48.0
const BAND_COLORS: Array[Color] = [Color(0.35, 0.2, 0.1), Color(0.8, 0.2, 0.2), Color(1.0, 0.8, 0.2)]

var max_pull: float = Balance.MAX_PULL_PX
var pull: Vector2 = Vector2.ZERO
var dragging: bool = false
var enabled: bool = true
var frame_height_px: float = Balance.BASE_LAUNCH_HEIGHT * Balance.PIXELS_PER_METER
var band_color: Color = Color(0.35, 0.2, 0.1)
var post_texture: Texture2D


func _ready():
	post_texture = load("res://assets/sprites/post.png")
	queue_redraw()


func apply_stats(stats: PlayerStats, power_level: int) -> void:
	frame_height_px = stats.launch_height * Balance.PIXELS_PER_METER
	band_color = BAND_COLORS[clampi(floori(power_level / 4.0), 0, BAND_COLORS.size() - 1)]
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var point: Vector2 = get_canvas_transform().affine_inverse() * event.position
		if event.pressed:
			if begin_drag(point):
				get_viewport().set_input_as_handled()
		elif dragging:
			release()
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and dragging:
		var point: Vector2 = get_canvas_transform().affine_inverse() * event.position
		update_drag(point)
		get_viewport().set_input_as_handled()


func begin_drag(point: Vector2) -> bool:
	if not enabled or point.distance_to(global_position) > GRAB_RADIUS:
		return false
	dragging = true
	pull = Vector2.ZERO
	queue_redraw()
	return true


func update_drag(point: Vector2) -> void:
	if dragging:
		pull = LaunchMath.clamp_pull(point - global_position, max_pull)
		queue_redraw()


func release() -> Vector2:
	if not dragging:
		return Vector2.ZERO
	
	dragging = false
	var p: Vector2 = pull
	pull = Vector2.ZERO
	queue_redraw()
	
	if p.length() < Balance.MIN_PULL_PX:
		return Vector2.ZERO
	
	launched.emit(p)
	return p


func cancel_drag() -> void:
	dragging = false
	pull = Vector2.ZERO
	queue_redraw()


func pouch_position() -> Vector2:
	return global_position + pull


func _draw():
	# Draw two posts from -18 to +18 from anchor
	var post_x: float = -18.0
	var post_width: float = 36.0
	
	# Draw the posts (from y = -6 down to frame_height_px)
	draw_texture_rect(post_texture, Rect2(post_x, -6.0, 6.0, frame_height_px + 6.0), false, band_color)
	draw_texture_rect(post_texture, Rect2(post_x + post_width - 6.0, -6.0, 6.0, frame_height_px + 6.0), false, band_color)
	
	# Draw the bands
	if dragging:
		draw_line(Vector2(-18.0, 0.0), pull, band_color, 4.0)
		draw_line(Vector2(18.0, 0.0), pull, band_color, 4.0)
		
		# Draw the pouch
		draw_circle(pull, 6.0, band_color)
