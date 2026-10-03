class_name FlightSim
extends RefCounted
## Deterministic projectile simulation in world units (meters, y up). See docs/DESIGN.md section 7.

signal bounced(impact_speed: float)
signal boosted
## The alien hit the brick wall behind the slingshot (Balance.WALL_X).
signal wall_hit

var position: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var gravity: float = Balance.GRAVITY
var drag: float = Balance.BASE_DRAG
var restitution: float = Balance.BASE_RESTITUTION
var boost_charges: int = 0
## Seconds of rocket left this flight: boost_charges tanks of Balance.BOOST_TANK_SECONDS, filled at launch.
var boost_fuel: float = 0.0
## True while the boost key is held; the rocket burns while it is held, in the air and with fuel left.
var boost_held: bool = false
var bounce_count: int = 0
var max_height: float = 0.0
## Seconds spent in the air this flight (sliding along the ground does not count).
var air_time: float = 0.0
var stopped: bool = false
var start_x: float = 0.0
## Dips in the ground as (start, end) in meters (see Balance.DIP_DEPTH); roguelike landing zones get one.
var dips: Array[Vector2] = []
## Rolling hills (see Terrain): their height in meters (0 = flat), where along their waves this course starts, and
## stretches kept flat (landing zones, the boss).
var hills: float = 0.0
var hill_phase: float = 0.0
var flat_spans: Array[Vector2] = []


## The boost key went down: the rocket fires until the key is released (see step). True when it starts firing.
func boost() -> bool:
	if stopped or boost_held or boost_fuel <= 0.0 or not is_airborne():
		return false
	boost_held = true
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
	boost_fuel = boost_capacity()
	boost_held = false


func is_airborne() -> bool:
	return position.y > ground_height(position.x) or velocity.y > 0.0


func distance() -> float:
	return position.x - start_x


func _touch_ground() -> void:
	position.y = ground_height(position.x)
	# bounce off the ground's slope: the speed into the ground turns around (times restitution), the speed along it
	# keeps BOUNCE_FRICTION. On flat ground that is the plain vertical bounce.
	var normal := Vector2(-ground_slope(position.x), 1.0).normalized()
	var along := Vector2(normal.y, -normal.x)
	var rebound := -velocity.dot(normal) * restitution
	if rebound >= Balance.MIN_BOUNCE_SPEED:
		velocity = normal * rebound + along * velocity.dot(along) * Balance.BOUNCE_FRICTION
		bounce_count += 1
		bounced.emit(rebound)
	else:
		velocity.y = 0.0


func _slide(dt: float) -> void:
	velocity.y = 0.0
	velocity.x -= gravity * ground_slope(position.x) * dt
	velocity.x = move_toward(velocity.x, 0.0, Balance.SLIDE_FRICTION * dt)
	position.x += velocity.x * dt
	position.y = ground_height(position.x)
	if absf(velocity.x) <= Balance.STOP_SPEED and absf(gravity * ground_slope(position.x)) <= Balance.SLIDE_FRICTION:
		velocity = Vector2.ZERO
		stopped = true


func step(dt: float) -> void:
	if stopped:
		return
	if is_airborne():
		if is_boosting():
			var burn := minf(dt, boost_fuel)
			velocity += Vector2(1.0, 1.0).normalized() * Balance.BOOST_THRUST * burn
			boost_fuel -= burn
		var accel := Vector2(0.0, -gravity) - velocity * velocity.length() * drag
		velocity += accel * dt
		air_time += dt
		position += velocity * dt
		max_height = maxf(max_height, position.y)
		if position.y <= ground_height(position.x):
			_touch_ground()
	else:
		_slide(dt)
	if position.x < Balance.WALL_X:
		position.x = Balance.WALL_X
		if velocity.x < 0.0:
			velocity.x = -velocity.x * restitution
			wall_hit.emit()


func simulate(dt: float, max_steps: int) -> int:
	var steps := 0
	while not stopped and steps < max_steps:
		step(dt)
		steps += 1
	return steps


## The boost key went up: the rocket stops firing.
func release_boost() -> void:
	boost_held = false


func is_boosting() -> bool:
	return boost_held and boost_fuel > 0.0 and not stopped and is_airborne()


## Rocket seconds a flight starts with: one Balance.BOOST_TANK_SECONDS tank per boost charge.
func boost_capacity() -> float:
	return boost_charges * Balance.BOOST_TANK_SECONDS


## The ground's height at x: 0, or lower in a dip (a flat floor DIP_DEPTH down, straight slopes outside it).
func ground_height(x: float) -> float:
	var h := terrain_height(x)
	for dip in dips:
		var down := clampf(minf(x - (dip.x - Balance.DIP_SLOPE), (dip.y + Balance.DIP_SLOPE) - x) / Balance.DIP_SLOPE, 0.0, 1.0)
		h = minf(h, -Balance.DIP_DEPTH * down)
	return h


## How steep the ground is at x (rise per meter): negative on the slope down into a dip, positive on the way out.
func ground_slope(x: float) -> float:
	for dip in dips:
		if x > dip.x - Balance.DIP_SLOPE and x < dip.x:
			return -Balance.DIP_DEPTH / Balance.DIP_SLOPE
		if x > dip.y and x < dip.y + Balance.DIP_SLOPE:
			return Balance.DIP_DEPTH / Balance.DIP_SLOPE
	return terrain_slope(x)


## The rolling hills' height at x (meters): two gentle waves `hills` high, flat near the slingshot (the hills grow
## in from 30 to 50 m) and around the flat spans and dips (growing back in over 15 m).
func terrain_height(x: float) -> float:
	if hills <= 0.0:
		return 0.0
	var wave := 0.6 * sin(x * TAU / 120.0 + hill_phase) + 0.4 * sin(x * TAU / 47.0 + hill_phase * 2.1)
	var flat := clampf((x - 30.0) / 20.0, 0.0, 1.0)
	for span in flat_spans:
		flat = minf(flat, clampf(maxf(span.x - x, x - span.y) / 15.0, 0.0, 1.0))
	for dip in dips:
		flat = minf(flat, clampf(maxf(dip.x - Balance.DIP_SLOPE - x, x - dip.y - Balance.DIP_SLOPE) / 15.0, 0.0, 1.0))
	return hills * wave * flat


## How steep the hills are at x (rise per meter).
func terrain_slope(x: float) -> float:
	return (terrain_height(x + 0.05) - terrain_height(x - 0.05)) / 0.1
