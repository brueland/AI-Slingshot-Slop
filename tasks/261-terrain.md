---
id: 261-terrain
status: ready
tests: [tests/acceptance/test_261_terrain.gd]
files: [scripts/core/terrain.gd, scripts/core/player_stats.gd]
---

# How hilly

Milestone 36 adds gentle rolling hills to the ground, growing as the game goes on. This task decides how hilly:
`Terrain` (a new core script) gives the hills' height for a roguelike round (flat for two rounds, then 0.12 m more
every round) and for classic (0.25 m more every 100 m of the best distance), at most 2.5 m. PlayerStats carries
the height for a shot and the stretches to keep flat. The next tasks shape the ground with it.

**1. Create the file `scripts/core/terrain.gd`** with exactly this code (use that exact path as the edit's file name):
```gdscript
class_name Terrain
extends RefCounted
## How hilly the ground is: the height (meters) of the rolling hills FlightSim.terrain_height draws. Flat at first,
## then a little hillier as the game goes on, up to MAX_HILLS (always gentle: a slope of at most about 0.2).

const MAX_HILLS: float = 2.5


## Roguelike: flat for the first two rounds, then 0.12 m more every round.
static func for_round(round_number: int) -> float:
	return clampf(0.12 * (round_number - 2), 0.0, MAX_HILLS)


## Classic: 0.25 m more for every 100 m of the best distance.
static func for_best_distance(best: float) -> float:
	return clampf(best / 400.0, 0.0, MAX_HILLS)
```

**2. `scripts/core/player_stats.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var boss: BossFight = null
```
REPLACE:
```gdscript
var boss: BossFight = null
## The rolling hills' height for this shot (meters; 0 = flat ground; see Terrain), and stretches kept flat
## (landing zones).
var hills: float = 0.0
var flat_spans: Array[Vector2] = []
```

## Acceptance criteria
- `Terrain.for_round(r)` = clamp(0.12 * (r - 2), 0, 2.5); `Terrain.for_best_distance(d)` = clamp(d / 400, 0, 2.5).
- `PlayerStats.hills` (0.0) and `PlayerStats.flat_spans` (empty).
