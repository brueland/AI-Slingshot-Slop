class_name Balloons
extends RefCounted
## Party balloons floating above the course. Flying into one pops it and lifts the alien up.
## They are separate from the course items; every course seed has its own balloons.

signal popped(index: int)

const RADIUS: float = 1.2
const LIFT_SPEED: float = 11.0
const SEED_OFFSET: int = 500

var points: Array[Vector2] = []
var used: Array[bool] = []
var popped_count: int = 0


## Balloon centers (world meters) for a course seed: one every 60-140 m after 60 m, 5-14 m high.
static func layout(course_seed: int, length: float) -> Array[Vector2]:
	var rng := RandomNumberGenerator.new()
	rng.seed = course_seed + SEED_OFFSET
	var out: Array[Vector2] = []
	var x := 60.0
	while true:
		x += rng.randf_range(60.0, 140.0)
		if x >= length:
			break
		out.append(Vector2(x, rng.randf_range(5.0, 14.0)))
	return out


func _init(balloon_points: Array[Vector2]) -> void:
	points = balloon_points
	used.resize(points.size())
	used.fill(false)


## Pops every balloon the alien touched between `previous_position` and its current position.
func after_step(sim: FlightSim, previous_position: Vector2) -> void:
	for i in points.size():
		if used[i]:
			continue
		var p := points[i]
		if p.x < previous_position.x - 2.0 or p.x > sim.position.x + 2.0:
			continue
		var closest := Geometry2D.get_closest_point_to_segment(p, previous_position, sim.position)
		if closest.distance_to(p) <= RADIUS:
			used[i] = true
			popped_count += 1
			sim.velocity.y = maxf(sim.velocity.y, LIFT_SPEED)
			sim.stopped = false
			popped.emit(i)
