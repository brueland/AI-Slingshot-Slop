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
const KEY_ANGLE_STEP: float = 2.0
const KEY_POWER_STEP: float = 0.05

var max_pull: float = Balance.MAX_PULL_PX
var pull: Vector2 = Vector2.ZERO
var dragging: bool = false
var enabled: bool = true
var frame_height_px: float = Balance.BASE_LAUNCH_HEIGHT * Balance.PIXELS_PER_METER
var band_color: Color = Color(0.35, 0.2, 0.1)
var post_texture: Texture2D
var last_pull: Vector2 = Vector2.ZERO
var key_angle: float = 45.0
var key_power: float = 0.8
var key_aiming: bool = false
## The alien's drawn radius in pixels as it rests on the pouch (bigger for the roguelike's big size).
var ball_radius_px: float = Balance.PROJECTILE_RADIUS * Balance.LOOK_SCALE * Balance.PIXELS_PER_METER
## Where the drag started, from the anchor: the pull follows the hand from there.
var grab_offset: Vector2 = Vector2.ZERO
var show_last_aim: bool = false:
	set(value):
		show_last_aim = value
		queue_redraw()


func _ready():
	post_texture = load("res://assets/sprites/post.png")
	queue_redraw()


func apply_stats(stats: PlayerStats, power_level: int) -> void:
	frame_height_px = stats.launch_height * Balance.PIXELS_PER_METER
	ball_radius_px = stats.pickup_offset * Balance.PIXELS_PER_METER
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
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
		if repeat_last_shot():
			get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and key_aim(event.keycode):
		get_viewport().set_input_as_handled()


func begin_drag(point: Vector2) -> bool:
	if not enabled or (point.distance_to(global_position) > GRAB_RADIUS and not on_ball(point)):
		return false
	grab_offset = point - global_position
	dragging = true
	pull = Vector2.ZERO
	queue_redraw()
	return true


func update_drag(point: Vector2) -> void:
	if dragging:
		pull = LaunchMath.clamp_pull(point - grab_offset - global_position, max_pull)
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


## The pull for the keyboard aim: key_angle degrees up, key_power (0..1) of the full pull.
func key_pull() -> Vector2:
	var r := deg_to_rad(key_angle)
	return Vector2(-cos(r), sin(r)) * max_pull * key_power


## Keyboard aiming: the arrow keys start aiming and change the angle (up/down) and power (left/right); Enter
## launches. Returns true when the key was used.
func key_aim(keycode: int) -> bool:
	if not enabled:
		return false
	match keycode:
		KEY_UP:
			key_angle = clampf(key_angle + KEY_ANGLE_STEP, 5.0, 85.0)
		KEY_DOWN:
			key_angle = clampf(key_angle - KEY_ANGLE_STEP, 5.0, 85.0)
		KEY_RIGHT:
			key_power = clampf(key_power + KEY_POWER_STEP, 0.1, 1.0)
		KEY_LEFT:
			key_power = clampf(key_power - KEY_POWER_STEP, 0.1, 1.0)
		KEY_ENTER, KEY_KP_ENTER:
			if not key_aiming:
				return false
			key_aiming = false
			dragging = true
			pull = key_pull()
			release()
			return true
		_:
			return false
	key_aiming = true
	dragging = true
	pull = key_pull()
	queue_redraw()
	return true


func cancel_drag() -> void:
	key_aiming = false
	dragging = false
	pull = Vector2.ZERO
	queue_redraw()


## Launches again with the remembered pull (the R key), only while the last-aim line is shown.
func repeat_last_shot() -> bool:
	if not enabled or dragging or not show_last_aim or last_pull == Vector2.ZERO:
		return false
	launched.emit(last_pull)
	return true


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


## Is `point` on the alien resting on the pouch (its circle sits right above the anchor)?
func on_ball(point: Vector2) -> bool:
	return point.distance_to(global_position + Vector2(0.0, -ball_radius_px)) <= ball_radius_px + 6.0
