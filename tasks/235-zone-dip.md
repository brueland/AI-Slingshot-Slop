---
id: 235-zone-dip
status: ready
tests: [tests/acceptance/test_235_zone_dip.gd]
files: [scripts/core/balance.gd, scripts/core/flight_sim.gd]
---

# Landing zones sit in a dip

"Stop between" goals are hard to hit exactly. The ground gets dips: between a dip's ends the floor is 0.75 m
lower, with straight 1.5 m slopes outside each end (`Balance.DIP_DEPTH`, `DIP_SLOPE`). The slopes are steep
enough that nothing rests on them: gravity pulls a sliding alien down a slope (sliding friction can't hold it
there), so a shot that would stop just short of the zone, or slowly run past it, ends on the floor. The flight
uses the ground's height everywhere it used 0. Without dips (the default) nothing changes. Task 236 puts a dip
under each landing zone.

**1. `scripts/core/balance.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds the two constants at the end of the file; nothing else changes.

Edit 1 - SEARCH:
```gdscript
const LOOK_SCALE: float = 1.5
```
REPLACE:
```gdscript
const LOOK_SCALE: float = 1.5
## Roguelike landing zones sit in a dip: the floor between the zone's edges is DIP_DEPTH lower, with a DIP_SLOPE-wide
## slope outside each edge. The slopes are too steep to rest on, so a shot that stops on one rolls into the zone.
const DIP_DEPTH: float = 0.75
const DIP_SLOPE: float = 1.5
```

**2. `scripts/core/flight_sim.gd`**: exactly these 6 SEARCH/REPLACE edit(s). Edits 2, 3 and 5 replace `0.0` with `ground_height(position.x)` in one line each; edit 4 changes `_slide()` (the slope pulls the alien, it follows the ground's height, and it only stops where the ground is not too steep); edit 6 adds `ground_height()` and `ground_slope()` at the end of the file. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var start_x: float = 0.0
```
REPLACE:
```gdscript
var start_x: float = 0.0
## Dips in the ground as (start, end) in meters (see Balance.DIP_DEPTH); roguelike landing zones get one.
var dips: Array[Vector2] = []
```

Edit 2 - SEARCH:
```gdscript
	return position.y > 0.0 or velocity.y > 0.0
```
REPLACE:
```gdscript
	return position.y > ground_height(position.x) or velocity.y > 0.0
```

Edit 3 - SEARCH:
```gdscript
func _touch_ground() -> void:
	position.y = 0.0
```
REPLACE:
```gdscript
func _touch_ground() -> void:
	position.y = ground_height(position.x)
```

Edit 4 - SEARCH:
```gdscript
func _slide(dt: float) -> void:
	position.y = 0.0
	velocity.y = 0.0
	velocity.x = move_toward(velocity.x, 0.0, Balance.SLIDE_FRICTION * dt)
	position.x += velocity.x * dt
	if absf(velocity.x) <= Balance.STOP_SPEED:
```
REPLACE:
```gdscript
func _slide(dt: float) -> void:
	velocity.y = 0.0
	velocity.x -= gravity * ground_slope(position.x) * dt
	velocity.x = move_toward(velocity.x, 0.0, Balance.SLIDE_FRICTION * dt)
	position.x += velocity.x * dt
	position.y = ground_height(position.x)
	if absf(velocity.x) <= Balance.STOP_SPEED and absf(gravity * ground_slope(position.x)) <= Balance.SLIDE_FRICTION:
```

Edit 5 - SEARCH:
```gdscript
		if position.y <= 0.0:
			_touch_ground()
```
REPLACE:
```gdscript
		if position.y <= ground_height(position.x):
			_touch_ground()
```

Edit 6 - SEARCH:
```gdscript
func boost_capacity() -> float:
	return boost_charges * Balance.BOOST_TANK_SECONDS
```
REPLACE:
```gdscript
func boost_capacity() -> float:
	return boost_charges * Balance.BOOST_TANK_SECONDS


## The ground's height at x: 0, or lower in a dip (a flat floor DIP_DEPTH down, straight slopes outside it).
func ground_height(x: float) -> float:
	var h := 0.0
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
	return 0.0
```

## Acceptance criteria
- `FlightSim.dips` (Array[Vector2], empty by default); `ground_height(x)` is 0, -0.75 on a dip's floor and in between on its slopes; `ground_slope(x)` is -0.5 / +0.5 on the slopes.
- The alien lands on, slides along and stops on the ground's height; slopes pull it down; it never stops on a slope.
- With no dips every result is exactly as before.
