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
## The alien's body: a ball of this radius whose center is this far above its contact point (0 = just the point).
var body: float = 0.0
## The hats some balloons carry ("" for none; see carry_hats), and the hats found by popping them this shot.
var hats: Array[String] = []
var found_hats: Array[String] = []


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


## About one balloon in six carries a hat (Cowboy Hat, Viking Helmet or Bobble Beanie), rolled from the course seed.
func carry_hats(course_seed: int) -> void:
	var choices: Array[String] = ["cowboy", "viking", "beanie"]
	var rng := RandomNumberGenerator.new()
	rng.seed = course_seed * 7919 + 17
	hats.clear()
	for i in points.size():
		var hat: String = choices[rng.randi_range(0, 2)]
		hats.append(hat if rng.randi_range(1, 6) == 1 else "")


## Pops every balloon the alien touched between `previous_position` and its current position.
func after_step(sim: FlightSim, previous_position: Vector2) -> void:
	for i in points.size():
		if used[i]:
			continue
		var p := points[i]
		if p.x < previous_position.x - 2.0 - body or p.x > sim.position.x + 2.0 + body:
			continue
		var lift := Vector2(0.0, body)
		var closest := Geometry2D.get_closest_point_to_segment(p, previous_position + lift, sim.position + lift)
		if closest.distance_to(p) <= RADIUS + body:
			used[i] = true
			popped_count += 1
			if i < hats.size() and hats[i] != "":
				found_hats.append(hats[i])
			sim.velocity.y = maxf(sim.velocity.y, LIFT_SPEED)
			sim.stopped = false
			popped.emit(i)
