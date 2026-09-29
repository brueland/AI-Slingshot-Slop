---
id: 093-balloons
status: ready
tests: [tests/acceptance/test_093_balloons.gd]
files: [scripts/core/balloons.gd, scripts/core/run_session.gd]
read: [scripts/core/run_tracker.gd, scripts/core/flight_sim.gd]
---

# Party balloons (logic)

Milestone 10 adds features. Party balloons float 5-14 m above the course; flying into one pops it and lifts the
alien up (vertical speed at least 11 m/s). They are **not** course items (CourseGenerator does not change); each
RunSession has its own `balloons`. Task 094 draws them.

**1. Create the file `scripts/core/balloons.gd` with exactly this code** (use that exact path as the edit's file name):
```gdscript
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
```

**2. `scripts/core/run_session.gd`** (keep everything else):
- **Declare** `var balloons: Balloons` after `var tracker: RunTracker`.
- In `_init()`, right after `tracker = RunTracker.new(course)`:
  ```gdscript
  	balloons = Balloons.new(Balloons.layout(course_seed, Balance.COURSE_LENGTH))
  ```
- In `step()`, right after `tracker.after_step(sim, previous)`: `balloons.after_step(sim, previous)`
- In `result()`, before `return r`: `r["balloons"] = balloons.popped_count`

## Acceptance criteria
- `layout` is the same for the same seed; balloons every 60-140 m after 60 m, 5-14 m high.
- A balloon within 1.2 m of the alien's path pops once, emits `popped(index)` and sets the vertical speed to at
  least 11 m/s (forward speed unchanged).
- RunSession pops its balloons during a shot and reports `result()["balloons"]`.
