class_name Slingshot
extends Node2D
## The slingshot. The node's position is the pouch rest point (anchor), in screen pixels.
## pull = drag point - anchor. Posts are drawn from the anchor down to the ground.

signal launched(pull: Vector2)

const GRAB_RADIUS: float = 48.0
const BAND_COLORS: Array[Color] = [Color(0.35, 0.2, 0.1), Color(0.8, 0.2, 0.2), Color(1.0, 0.8, 0.2)]
const POST_WIDTH: float = 12.0
const POWER_LOW := Color(0.3, 0.9, 0.3)
const POWER_MID := Color(1.0, 0.9, 0.2)
const POWER_HIGH := Color(1.0, 0.3, 0.2)
const AIM_LINE_LENGTH: float = 2.5
const AIM_LINE_COLOR := Color(1, 1, 1, 0.55)

var max_pull: float = Balance.MAX_PULL_PX
var pull: Vector2 = Vector2.ZERO
var dragging: bool = false
var enabled: bool = true
var frame_height_px: float = Balance.BASE_LAUNCH_HEIGHT * Balance.PIXELS_PER_METER
var band_color: Color = Color(0.35, 0.2, 0.1)
var post_texture: Texture2D
var last_pull: Vector2 = Vector2.ZERO
var show_last_aim: bool = false:
	set(value):
		show_last_aim = value
		queue_redraw()


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
	
	last_pull = p
	launched.emit(p)
	return p


func cancel_drag() -> void:
	dragging = false
	pull = Vector2.ZERO
	queue_redraw()


func pouch_position() -> Vector2:
	return global_position + pull


## The remembered aim: from the last pull point forward through the anchor, or nothing when hidden.
func aim_line_points() -> PackedVector2Array:
	if not show_last_aim or last_pull == Vector2.ZERO:
		return PackedVector2Array()
	return PackedVector2Array([last_pull, -last_pull * AIM_LINE_LENGTH])


## How hard the band is pulled, 0..1.
func power_ratio() -> float:
	if max_pull <= 0.0:
		return 0.0
	return clampf(pull.length() / max_pull, 0.0, 1.0)


## Green at no pull, yellow at half, red at full.
static func power_color(ratio: float) -> Color:
	if ratio <= 0.5:
		return POWER_LOW.lerp(POWER_MID, ratio * 2.0)
	return POWER_MID.lerp(POWER_HIGH, (ratio - 0.5) * 2.0)


func _draw() -> void:
	var aim := aim_line_points()
	if aim.size() == 2:
		draw_dashed_line(aim[0], aim[1], AIM_LINE_COLOR, 2.0, 8.0)
		draw_circle(aim[0], 7.0, Color(1, 1, 1, 0.35))
	
	var left_tip := Vector2(-18.0, 0.0)
	var right_tip := Vector2(18.0, 0.0)
	var pouch: Vector2 = pull if dragging else Vector2.ZERO
	# Back band, then the two wooden posts, then the front band on top.
	draw_line(right_tip, pouch, band_color, 4.0)
	for tip in [left_tip, right_tip]:
		draw_texture_rect(post_texture, Rect2(tip.x - POST_WIDTH / 2.0, -6.0, POST_WIDTH, frame_height_px + 6.0), false)
	draw_line(left_tip, pouch, band_color, 4.0)
	draw_circle(pouch, 6.0, band_color)
	if dragging:
		var ratio := power_ratio()
		var bar := Rect2(-30.0, -48.0, 60.0, 8.0)
		draw_rect(bar, Color(0, 0, 0, 0.5))
		draw_rect(Rect2(bar.position, Vector2(bar.size.x * ratio, bar.size.y)), power_color(ratio))
