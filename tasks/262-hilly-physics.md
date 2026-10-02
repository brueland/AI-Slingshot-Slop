---
id: 262-hilly-physics
status: ready
tests: [tests/acceptance/test_262_hilly_physics.gd]
files: [scripts/core/flight_sim.gd]
---

# Hilly physics

FlightSim gets rolling hills (`hills` high; `Terrain` decides how high, task 261): two gentle waves along the course
(`hill_phase` shifts them per course), flat near the slingshot and around `flat_spans` and landing-zone dips.
`ground_height` and `ground_slope` include them, so landing and sliding follow the hills, and a bounce now comes off
the slope: the speed into the ground turns around, the speed along it keeps BOUNCE_FRICTION. On flat ground that is
exactly the old bounce.

**1. `scripts/core/flight_sim.gd`**: exactly these 4 SEARCH/REPLACE edit(s). Edit 2 rewrites the start of `_touch_ground()` (the bounce uses the ground's normal); edit 3 changes the first line of `ground_height()`; edit 4 changes the last line of `ground_slope()` and adds `terrain_height()` and `terrain_slope()` at the end of the file. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var dips: Array[Vector2] = []
```
REPLACE:
```gdscript
var dips: Array[Vector2] = []
## Rolling hills (see Terrain): their height in meters (0 = flat), where along their waves this course starts, and
## stretches kept flat (landing zones, the boss).
var hills: float = 0.0
var hill_phase: float = 0.0
var flat_spans: Array[Vector2] = []
```

Edit 2 - SEARCH:
```gdscript
func _touch_ground() -> void:
	position.y = ground_height(position.x)
	var rebound := -velocity.y * restitution
	if rebound >= Balance.MIN_BOUNCE_SPEED:
		velocity.y = rebound
		velocity.x *= Balance.BOUNCE_FRICTION
```
REPLACE:
```gdscript
func _touch_ground() -> void:
	position.y = ground_height(position.x)
	# bounce off the ground's slope: the speed into the ground turns around (times restitution), the speed along it
	# keeps BOUNCE_FRICTION. On flat ground that is the plain vertical bounce.
	var normal := Vector2(-ground_slope(position.x), 1.0).normalized()
	var along := Vector2(normal.y, -normal.x)
	var rebound := -velocity.dot(normal) * restitution
	if rebound >= Balance.MIN_BOUNCE_SPEED:
		velocity = normal * rebound + along * velocity.dot(along) * Balance.BOUNCE_FRICTION
```

Edit 3 - SEARCH:
```gdscript
func ground_height(x: float) -> float:
	var h := 0.0
```
REPLACE:
```gdscript
func ground_height(x: float) -> float:
	var h := terrain_height(x)
```

Edit 4 - SEARCH:
```gdscript
			return Balance.DIP_DEPTH / Balance.DIP_SLOPE
	return 0.0
```
REPLACE:
```gdscript
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
```

## Acceptance criteria
- `terrain_height(x)` is 0 without hills, at most `hills` high, flat before 30 m and around flat spans and dips; `terrain_slope(x)` is its slope.
- `ground_height`/`ground_slope` include the hills; bounces reflect off the slope (flat ground unchanged).
