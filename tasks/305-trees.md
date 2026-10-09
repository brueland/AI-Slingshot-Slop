---
id: 305-trees
status: ready
tests: [tests/acceptance/test_305_trees.gd, tests/acceptance/test_300c_checkpoint_endless.gd]
files: [scripts/core/trees.gd, scripts/core/run_session.gd]
---

# Trees

Milestone 44 adds trees and a secret. `Trees` (a new core script) puts a tree every 90-220 m from 200 m on (5-9 m
tall), never within 10 m of a landing zone or the boss. Hitting one at BREAK_SPEED (18 m/s) or faster smashes
through it (the alien keeps 85% of its speed); slower, the alien bounces back off it (40%), and dropping slowly onto
a crown rolls it off the side, so a tree never holds the alien. Every RunSession has its course's trees (more as
the course grows) and the result counts the broken ones. Checkpoint 300c's long shot now flies 15 degrees up, over
most trees.

**1. Create the file `scripts/core/trees.gd`** with exactly this code (use that exact path as the edit's file name):
```gdscript
class_name Trees
extends RefCounted
## Trees along the meadow (world meters, like the balloons). Hit fast enough (BREAK_SPEED) the alien smashes through a
## tree and keeps most of its speed; slower, it bounces back off it. A broken tree stays down for the rest of the shot.

signal tree_broken(index: int)
signal tree_bounced(index: int)

## Hitting a tree at least this fast (m/s) breaks it; the alien keeps KEEP_SPEED of its speed.
const BREAK_SPEED: float = 18.0
const KEEP_SPEED: float = 0.85
## A slower hit sends the alien back with this share of its speed.
const BOUNCE: float = 0.4
## A tree reaches this far to each side of its trunk (meters): its crown.
const HALF_WIDTH: float = 1.6
const SEED_OFFSET: int = 1300

var xs: Array[float] = []
var heights: Array[float] = []
var broken: Array[bool] = []
## The alien's body (as Balloons.body).
var body: float = 0.0


## Trees for a seed over `length` meters: one every 90-220 m from 200 m on, 5-9 m tall, as (x, height).
static func layout(seed: int, length: float) -> Array[Vector2]:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed + SEED_OFFSET
	var out: Array[Vector2] = []
	var x := 200.0
	while true:
		x += rng.randf_range(90.0, 220.0)
		if x >= length:
			break
		out.append(Vector2(x, rng.randf_range(5.0, 9.0)))
	return out


## Adds trees `offset_m` further along, except within 10 m of the `keep_clear` stretches (landing zones, the boss).
func add(trees: Array[Vector2], offset_m: float, keep_clear: Array[Vector2] = []) -> void:
	for t in trees:
		var x := t.x + offset_m
		var clear := true
		for span in keep_clear:
			if x >= span.x - 10.0 and x <= span.y + 10.0:
				clear = false
		if clear:
			xs.append(x)
			heights.append(t.y)
			broken.append(false)


## Breaks, or bounces the alien off, every standing tree it ran into between `previous_position` and now.
func after_step(sim: FlightSim, previous_position: Vector2) -> void:
	var reach := HALF_WIDTH + body
	for i in xs.size():
		if broken[i]:
			continue
		var x := xs[i]
		if x < minf(previous_position.x, sim.position.x) - reach or x > maxf(previous_position.x, sim.position.x) + reach:
			continue
		var ground := sim.ground_height(x)
		if sim.position.y - ground > heights[i] + body:
			continue
		if sim.velocity.length() >= BREAK_SPEED:
			broken[i] = true
			sim.velocity *= KEEP_SPEED
			tree_broken.emit(i)
			continue
		if previous_position.y - ground > heights[i] + body:
			# dropped onto the crown: it rolls off the side it is on
			var side := 1.0 if sim.position.x >= x else -1.0
			sim.position.y = ground + heights[i] + body
			sim.velocity = Vector2(side * 4.0, 3.0)
		else:
			sim.position.x = x - reach if previous_position.x < x else x + reach
			sim.velocity.x = -sim.velocity.x * BOUNCE
		sim.stopped = false
		tree_bounced.emit(i)
```

**2. `scripts/core/run_session.gd`**: exactly these 5 SEARCH/REPLACE edit(s). Edit 2 adds four lines at the end of `_init()`; the others keep the SEARCH lines and add the new ones. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var cloud: StarCloud
```
REPLACE:
```gdscript
var cloud: StarCloud
## Trees along the meadow (see Trees).
var trees: Trees
```

Edit 2 - SEARCH:
```gdscript
	for item in course:
		item["y"] = float(item["y"]) + sim.terrain_height(float(item["x"]))


func launch_from_pull(pull: Vector2) -> Vector2:
```
REPLACE:
```gdscript
	for item in course:
		item["y"] = float(item["y"]) + sim.terrain_height(float(item["x"]))
	# trees keep clear of the landing zones and the boss (the flat spans)
	trees = Trees.new()
	trees.body = stats.pickup_offset
	trees.add(Trees.layout(course_seed, Balance.COURSE_LENGTH), 0.0, sim.flat_spans)


func launch_from_pull(pull: Vector2) -> Vector2:
```

Edit 3 - SEARCH:
```gdscript
	cloud.after_step(sim, previous)
```
REPLACE:
```gdscript
	cloud.after_step(sim, previous)
	trees.after_step(sim, previous)
```

Edit 4 - SEARCH:
```gdscript
	space.add(SpaceThings.layout(chunk_seed, Balance.COURSE_LENGTH), course_end)
```
REPLACE:
```gdscript
	space.add(SpaceThings.layout(chunk_seed, Balance.COURSE_LENGTH), course_end)
	trees.add(Trees.layout(chunk_seed, Balance.COURSE_LENGTH), course_end, sim.flat_spans)
```

Edit 5 - SEARCH:
```gdscript
	r["meteors"] = space.meteor_used.count(true)
```
REPLACE:
```gdscript
	r["meteors"] = space.meteor_used.count(true)
	r["trees"] = trees.broken.count(true)
```

## Acceptance criteria
- `Trees.layout`, `add` (keeping clear of flat spans) and `after_step` (break, bounce, roll off a crown) work as described.
- RunSession has `trees`, steps them, extends them with the course; `result()["trees"]` counts broken trees.
