class_name FlightSim
extends RefCounted
## Deterministic projectile simulation in world units (meters, y up). See docs/DESIGN.md section 7.

signal bounced(impact_speed: float)

var position: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var gravity: float = Balance.GRAVITY
var drag: float = Balance.BASE_DRAG
var restitution: float = Balance.BASE_RESTITUTION
var boost_charges: int = 0
var bounce_count: int = 0
var max_height: float = 0.0
var stopped: bool = false
var start_x: float = 0.0


func launch(start: Vector2, launch_velocity: Vector2) -> void:
	position = start
	velocity = launch_velocity
	start_x = start.x
	max_height = start.y
	bounce_count = 0
	stopped = false


func is_airborne() -> bool:
	return position.y > 0.0 or velocity.y > 0.0


func distance() -> float:
	return position.x - start_x


func _touch_ground() -> void:
	position.y = 0.0
	var rebound := -velocity.y * restitution
	if rebound >= Balance.MIN_BOUNCE_SPEED:
		velocity.y = rebound
		velocity.x *= Balance.BOUNCE_FRICTION
		bounce_count += 1
		bounced.emit(rebound)
	else:
		velocity.y = 0.0


func step(dt: float) -> void:
	if stopped:
		return
	if is_airborne():
		var accel := Vector2(0.0, -gravity) - velocity * velocity.length() * drag
		velocity += accel * dt
		position += velocity * dt
		max_height = maxf(max_height, position.y)
		if position.y <= 0.0:
			_touch_ground()
