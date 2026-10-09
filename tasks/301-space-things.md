---
id: 301-space-things
status: ready
tests: [tests/acceptance/test_301_space_things.gd]
files: [scripts/core/space_things.gd, scripts/core/run_session.gd]
---

# Meteors and space stations

Milestone 43 gives the high sky things to play with. `SpaceThings` (a new core script) lays out meteors (every
60-140 m, 120-260 m up, each circling its spot) and space stations (every 300-700 m, 220-320 m up). Smashing into a
meteor boosts the alien 12 m/s along its flight; a station is solid and bounces it off with 90% of its speed. Every
RunSession has its course's ones (more come as the course grows) and the result counts the meteors smashed.

**1. Create the file `scripts/core/space_things.gd`** with exactly this code (use that exact path as the edit's file name):
```gdscript
class_name SpaceThings
extends RefCounted
## Things high in the sky along the course that the alien can fly into (world meters, like the balloons). Meteors
## circle their spot; smashing into one boosts the alien along its flight. Space stations are solid: the alien
## bounces off them.

signal meteor_hit(index: int)
signal station_hit(index: int)

const METEOR_RADIUS: float = 1.6
## How much faster (m/s) the alien flies after smashing a meteor.
const METEOR_BOOST: float = 12.0
## Meteors circle their spot METEOR_DRIFT_M meters out, once every METEOR_LOOP_SECONDS.
const METEOR_DRIFT_M: float = 3.0
const METEOR_LOOP_SECONDS: float = 5.0
const STATION_RADIUS: float = 4.5
## A bounce off a station keeps this share of the alien's speed.
const STATION_BOUNCE: float = 0.9
const SEED_OFFSET: int = 900

var meteors: Array[Vector2] = []
var meteor_used: Array[bool] = []
var stations: Array[Vector2] = []
## The alien's body (as Balloons.body): a ball this big whose center is this far above its contact point.
var body: float = 0.0
## Seconds since the launch: the meteors move with it.
var time: float = 0.0


## Meteor spots and station centers (world meters) for a seed over `length` meters: a meteor every 60-140 m from
## 150 m on, 120-260 m up; a station every 300-700 m from 300 m on, 220-320 m up.
static func layout(seed: int, length: float) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed + SEED_OFFSET
	var rocks: Array[Vector2] = []
	var x := 150.0
	while true:
		x += rng.randf_range(60.0, 140.0)
		if x >= length:
			break
		rocks.append(Vector2(x, rng.randf_range(120.0, 260.0)))
	var hubs: Array[Vector2] = []
	x = 300.0
	while true:
		x += rng.randf_range(300.0, 700.0)
		if x >= length:
			break
		hubs.append(Vector2(x, rng.randf_range(220.0, 320.0)))
	return {"meteors": rocks, "stations": hubs}


## Adds a layout's meteors and stations, `offset_m` further along (the course grows during long shots).
func add(things: Dictionary, offset_m: float) -> void:
	for p in things["meteors"]:
		meteors.append(p + Vector2(offset_m, 0.0))
		meteor_used.append(false)
	for p in things["stations"]:
		stations.append(p + Vector2(offset_m, 0.0))


## Where meteor `index` is right now (world meters).
func meteor_position(index: int) -> Vector2:
	var a := TAU * time / METEOR_LOOP_SECONDS + index * 1.7
	return meteors[index] + Vector2(cos(a), sin(a)) * METEOR_DRIFT_M


## Moves the meteors on by `dt`, then smashes every meteor the alien touched between `previous_position` and its
## position now (a boost along its flight) and bounces it off any station it reached.
func after_step(sim: FlightSim, previous_position: Vector2, dt: float) -> void:
	time += dt
	var lift := Vector2(0.0, body)
	var left := minf(previous_position.x, sim.position.x)
	var right := maxf(previous_position.x, sim.position.x)
	for i in meteors.size():
		if meteor_used[i] or meteors[i].x < left - 8.0 or meteors[i].x > right + 8.0:
			continue
		var m := meteor_position(i)
		var closest := Geometry2D.get_closest_point_to_segment(m, previous_position + lift, sim.position + lift)
		if closest.distance_to(m) <= METEOR_RADIUS + body:
			meteor_used[i] = true
			var along := sim.velocity.normalized() if sim.velocity.length() > 0.1 else Vector2.RIGHT
			sim.velocity += along * METEOR_BOOST
			sim.stopped = false
			meteor_hit.emit(i)
	for i in stations.size():
		var c := stations[i]
		if c.x < left - 10.0 or c.x > right + 10.0:
			continue
		var away := sim.position + lift - c
		if away.length() >= STATION_RADIUS + body or away.length() < 0.001:
			continue
		var n := away.normalized()
		if sim.velocity.dot(n) < 0.0:
			sim.velocity = (sim.velocity - 2.0 * sim.velocity.dot(n) * n) * STATION_BOUNCE
			station_hit.emit(i)
		sim.position = c + n * (STATION_RADIUS + body) - lift
```

**2. `scripts/core/run_session.gd`**: exactly these 5 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var balloons: Balloons
```
REPLACE:
```gdscript
var balloons: Balloons
## Meteors and space stations high above the course (see SpaceThings).
var space: SpaceThings
```

Edit 2 - SEARCH:
```gdscript
	balloons.carry_hats(course_seed)
```
REPLACE:
```gdscript
	balloons.carry_hats(course_seed)
	space = SpaceThings.new()
	space.add(SpaceThings.layout(course_seed, Balance.COURSE_LENGTH), 0.0)
	space.body = stats.pickup_offset
```

Edit 3 - SEARCH:
```gdscript
	balloons.after_step(sim, previous)
```
REPLACE:
```gdscript
	balloons.after_step(sim, previous)
	space.after_step(sim, previous, dt)
```

Edit 4 - SEARCH:
```gdscript
	balloons.add_points(more, chunk_seed)
```
REPLACE:
```gdscript
	balloons.add_points(more, chunk_seed)
	space.add(SpaceThings.layout(chunk_seed, Balance.COURSE_LENGTH), course_end)
```

Edit 5 - SEARCH:
```gdscript
	r["balloons"] = balloons.popped_count
```
REPLACE:
```gdscript
	r["balloons"] = balloons.popped_count
	r["meteors"] = space.meteor_used.count(true)
```

## Acceptance criteria
- `SpaceThings.layout`, `add`, `meteor_position` and `after_step` work as described (signals `meteor_hit`, `station_hit`).
- RunSession has `space`, steps it, extends it with the course, and `result()["meteors"]` counts the smashed ones.
