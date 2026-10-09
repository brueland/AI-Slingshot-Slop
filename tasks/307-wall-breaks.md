---
id: 307-wall-breaks
status: ready
tests: [tests/acceptance/test_307_wall_breaks.gd, tests/acceptance/test_288c_checkpoint_wrong_way.gd]
files: [scripts/core/balance.gd, scripts/core/flight_sim.gd, scripts/core/run_session.gd]
---

# The wall breaks

The secret: hit the brick wall hard enough and it breaks. FlightSim: at WALL_BREAK_SPEED (50 m/s sideways) or faster
the wall goes down for the rest of the shot (`wall_down`, signal `wall_broken`) and the alien flies on with 60% of
its speed into the secret behind it, where the world ends for good at SECRET_END_X (-260 m). Slower hits bounce off
as before. A shot that broke through has found "secret_wall" (kept for good, like hats). Checkpoint 288c now shoots
with power 4, which still reaches the wall but does not break it.

**1. `scripts/core/balance.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
const WALL_X: float = -120.0
```
REPLACE:
```gdscript
const WALL_X: float = -120.0
## Hitting the wall at least this fast (m/s, sideways) breaks through it, into the secret behind it.
const WALL_BREAK_SPEED: float = 50.0
## Behind the wall the world ends here for good (meters): the alien bounces off.
const SECRET_END_X: float = -260.0
```

**2. `scripts/core/flight_sim.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Edit 3 replaces the wall check at the end of `step()` (the line `func simulate...` after it stays); the others keep the SEARCH lines and add the new ones. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
signal wall_hit
```
REPLACE:
```gdscript
signal wall_hit
## The alien broke through the brick wall (hit at WALL_BREAK_SPEED or faster) into the secret behind it.
signal wall_broken
```

Edit 2 - SEARCH:
```gdscript
var restitution: float = Balance.BASE_RESTITUTION
```
REPLACE:
```gdscript
var restitution: float = Balance.BASE_RESTITUTION
## The brick wall is down for the rest of this shot.
var wall_down: bool = false
```

Edit 3 - SEARCH:
```gdscript
	if position.x < Balance.WALL_X:
		position.x = Balance.WALL_X
		if velocity.x < 0.0:
			velocity.x = -velocity.x * restitution
			wall_hit.emit()


func simulate(dt: float, max_steps: int) -> int:
```
REPLACE:
```gdscript
	if not wall_down and position.x < Balance.WALL_X:
		if velocity.x <= -Balance.WALL_BREAK_SPEED:
			wall_down = true
			velocity.x *= 0.6
			wall_broken.emit()
		else:
			position.x = Balance.WALL_X
			if velocity.x < 0.0:
				velocity.x = -velocity.x * restitution
				wall_hit.emit()
	if position.x < Balance.SECRET_END_X:
		position.x = Balance.SECRET_END_X
		if velocity.x < 0.0:
			velocity.x = -velocity.x * restitution


func simulate(dt: float, max_steps: int) -> int:
```

**3. `scripts/core/run_session.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	r["found"].append_array(tracker.found_specials)
```
REPLACE:
```gdscript
	r["found"].append_array(tracker.found_specials)
	if sim.wall_down:
		r["found"].append("secret_wall")
```

## Acceptance criteria
- `Balance.WALL_BREAK_SPEED` 50, `SECRET_END_X` -260; a hit at 50 m/s or more breaks the wall (`wall_down`, `wall_broken`), slower bounces.
- `result()["found"]` has "secret_wall" when the wall is down.
