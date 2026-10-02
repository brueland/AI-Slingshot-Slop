---
id: 285-back-wall
status: ready
tests: [tests/acceptance/test_285_back_wall.gd]
files: [scripts/core/balance.gd, scripts/core/flight_sim.gd]
---

# The wall behind the slingshot

Milestone 41 is for shots fired backwards. 120 m behind the slingshot (`Balance.WALL_X`) a giant brick wall now
stands: FlightSim stops the alien at it and bounces it back (its bounciness share of the speed) with a `wall_hit`
signal. Task 286 draws the wall and WRONG WAY signs.

**1. `scripts/core/balance.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
const DIP_SLOPE: float = 1.5
```
REPLACE:
```gdscript
const DIP_SLOPE: float = 1.5
## A giant brick wall stands this far behind the slingshot (meters); the alien bounces off it.
const WALL_X: float = -120.0
```

**2. `scripts/core/flight_sim.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Edit 2 adds the wall check at the end of `step()`, after the `else` branch; nothing else changes.

Edit 1 - SEARCH:
```gdscript
signal boosted
```
REPLACE:
```gdscript
signal boosted
## The alien hit the brick wall behind the slingshot (Balance.WALL_X).
signal wall_hit
```

Edit 2 - SEARCH:
```gdscript
	else:
		_slide(dt)
```
REPLACE:
```gdscript
	else:
		_slide(dt)
	if position.x < Balance.WALL_X:
		position.x = Balance.WALL_X
		if velocity.x < 0.0:
			velocity.x = -velocity.x * restitution
			wall_hit.emit()
```

## Acceptance criteria
- `Balance.WALL_X` is -120.0; the alien never goes past it, bounces back (velocity.x = -velocity.x * restitution) and `wall_hit` is emitted.
