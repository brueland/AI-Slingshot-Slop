---
id: 302-star-cloud
status: ready
tests: [tests/acceptance/test_302_star_cloud.gd]
files: [scripts/core/star_cloud.gd, scripts/core/run_session.gd, scripts/game/main.gd]
---

# The star cloud

Very high up (from 600 m, which takes strong upgrades) the sky is thick with stars. `StarCloud` (a new core script)
puts a star in most 4 x 4 m cells there, at a spot of its own, the same in every shot, worked out per cell so none
are stored. Flying through collects them; they count with the course's stars for the score, the result and the
HUD (`RunSession.stars_collected()`).

**1. Create the file `scripts/core/star_cloud.gd`** with exactly this code (use that exact path as the edit's file name):
```gdscript
class_name StarCloud
extends RefCounted
## Very high up the sky is thick with stars: from FROM_M meters up, most CELL_M x CELL_M cells hold a star at a spot
## of their own (the same in every shot). Flying through collects them like course stars, so a shot that gets that
## high can grab a ton of them.

signal star_collected(cell: Vector2i)

const FROM_M: float = 600.0
const CELL_M: float = 4.0
## The share of cells that hold a star.
const CHANCE: float = 0.6
const SEED: int = 77

var pickup_offset: float = 0.0
var pickup_radius: float = Balance.STAR_RADIUS
## Stars collected this shot, and the cells they were in.
var count: int = 0
var collected: Dictionary = {}


## The star in `cell` (world meters), or Vector2.INF when that cell has none (below FROM_M, or by chance).
static func star_in(cell: Vector2i) -> Vector2:
	if cell.y * CELL_M < FROM_M:
		return Vector2.INF
	var rng := RandomNumberGenerator.new()
	rng.seed = cell.x * 73856093 + cell.y * 19349663 + SEED
	if rng.randf() > CHANCE:
		return Vector2.INF
	return (Vector2(cell) + Vector2(rng.randf_range(0.2, 0.8), rng.randf_range(0.2, 0.8))) * CELL_M


## Collects every star of the cloud the alien touched between `previous_position` and its position now.
func after_step(sim: FlightSim, previous_position: Vector2) -> void:
	var a := previous_position + Vector2(0.0, pickup_offset)
	var b := sim.position + Vector2(0.0, pickup_offset)
	if maxf(a.y, b.y) + pickup_radius < FROM_M:
		return
	var low_x := floori((minf(a.x, b.x) - pickup_radius) / CELL_M)
	var high_x := floori((maxf(a.x, b.x) + pickup_radius) / CELL_M)
	var low_y := floori((minf(a.y, b.y) - pickup_radius) / CELL_M)
	var high_y := floori((maxf(a.y, b.y) + pickup_radius) / CELL_M)
	for cx in range(low_x, high_x + 1):
		for cy in range(low_y, high_y + 1):
			var cell := Vector2i(cx, cy)
			if collected.has(cell):
				continue
			var star := star_in(cell)
			if star == Vector2.INF:
				continue
			if Geometry2D.get_closest_point_to_segment(star, a, b).distance_to(star) <= pickup_radius:
				collected[cell] = true
				count += 1
				star_collected.emit(cell)
```

**2. `scripts/core/run_session.gd`**: exactly these 6 SEARCH/REPLACE edit(s). Edits 1-3 keep the SEARCH lines and add the new ones; edits 4 and 5 change how `result()` counts stars; edit 6 adds `stars_collected()` before `release_boost()`. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var space: SpaceThings
```
REPLACE:
```gdscript
var space: SpaceThings
## The thick star cloud very high up (see StarCloud).
var cloud: StarCloud
```

Edit 2 - SEARCH:
```gdscript
	space.body = stats.pickup_offset
```
REPLACE:
```gdscript
	space.body = stats.pickup_offset
	cloud = StarCloud.new()
	cloud.pickup_offset = stats.pickup_offset
	cloud.pickup_radius = stats.pickup_radius
```

Edit 3 - SEARCH:
```gdscript
	space.after_step(sim, previous, dt)
```
REPLACE:
```gdscript
	space.after_step(sim, previous, dt)
	cloud.after_step(sim, previous)
```

Edit 4 - SEARCH:
```gdscript
	var r := Scoring.compute(sim.distance(), tracker.stars_collected, sim.bounce_count, stats)
```
REPLACE:
```gdscript
	var r := Scoring.compute(sim.distance(), stars_collected(), sim.bounce_count, stats)
```

Edit 5 - SEARCH:
```gdscript
	r["stars"] = tracker.stars_collected
```
REPLACE:
```gdscript
	r["stars"] = stars_collected()
	r["cloud_stars"] = cloud.count
```

Edit 6 - SEARCH:
```gdscript
## The boost key went up.
func release_boost() -> void:
```
REPLACE:
```gdscript
## Stars collected this shot: the course's and the star cloud's.
func stars_collected() -> int:
	return tracker.stars_collected + cloud.count


## The boost key went up.
func release_boost() -> void:
```

**3. `scripts/game/main.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE changes one argument of the `hud.update_flight` call; nothing else in main.gd changes.

Edit 1 - SEARCH:
```gdscript
session.tracker.stars_collected, session.sim.boost_fuel```
REPLACE:
```gdscript
session.stars_collected(), session.sim.boost_fuel```

## Acceptance criteria
- `StarCloud.star_in(cell)` and `after_step` work as described; `RunSession.stars_collected()` = course + cloud stars.
- `result()["stars"]` includes the cloud's (`"cloud_stars"` alone); the HUD shows the total.
