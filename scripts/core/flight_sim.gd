class_name FlightSim
extends RefCounted
## Deterministic projectile simulation in world units (meters, y up). See docs/DESIGN.md section 7.

signal bounced(impact_speed: float)
signal boosted

var position: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var gravity: float = Balance.GRAVITY
var drag: float = Balance.BASE_DRAG
var restitution: float = Balance.BASE_RESTITUTION
var boost_charges: int = 0
var bounce_count: int = 0
var max_height: float = 0.0
## Seconds spent in the air this flight (sliding along the ground does not count).
var air_time: float = 0.0
var stopped: bool = false
var start_x: float = 0.0


func boost() -> bool:
	if stopped or boost_charges <= 0 or not is_airborne():
		return false
	velocity += Vector2(1.0, 1.0).normalized() * Balance.BOOST_SPEED
	boost_charges -= 1
	boosted.emit()
	return true


func launch(start: Vector2, launch_velocity: Vector2) -> void:
	position = start
	velocity = launch_velocity
	start_x = start.x
	max_height = start.y
	air_time = 0.0
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


func _slide(dt: float) -> void:
	position.y = 0.0
	velocity.y = 0.0
	velocity.x = move_toward(velocity.x, 0.0, Balance.SLIDE_FRICTION * dt)
	position.x += velocity.x * dt
	if absf(velocity.x) <= Balance.STOP_SPEED:
		velocity = Vector2.ZERO
		stopped = true


func step(dt: float) -> void:
	if stopped:
		return
	if is_airborne():
		var accel := Vector2(0.0, -gravity) - velocity * velocity.length() * drag
		velocity += accel * dt
		air_time += dt
		position += velocity * dt
		max_height = maxf(max_height, position.y)
		if position.y <= 0.0:
			_touch_ground()
	else:
		_slide(dt)


func simulate(dt: float, max_steps: int) -> int:
	var steps := 0
	while not stopped and steps < max_steps:
		step(dt)
		steps += 1
	return steps
