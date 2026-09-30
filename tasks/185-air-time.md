---
id: 185-air-time
status: ready
tests: [tests/acceptance/test_185_air_time.gd]
files: [scripts/core/flight_sim.gd, scripts/core/run_session.gd]
---

# Air time

Milestone 23 adds flight stats. First, the flight counts how long the alien is in the air.

**1. `scripts/core/flight_sim.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var max_height: float = 0.0
```
REPLACE:
```gdscript
var max_height: float = 0.0
## Seconds spent in the air this flight (sliding along the ground does not count).
var air_time: float = 0.0
```

Edit 2 - SEARCH:
```gdscript
	max_height = start.y
```
REPLACE:
```gdscript
	max_height = start.y
	air_time = 0.0
```

Edit 3 - SEARCH:
```gdscript
		velocity += accel * dt
```
REPLACE:
```gdscript
		velocity += accel * dt
		air_time += dt
```

**2. `scripts/core/run_session.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	r["balloons"] = balloons.popped_count
```
REPLACE:
```gdscript
	r["balloons"] = balloons.popped_count
	r["air_time"] = sim.air_time
```

## Acceptance criteria
- `FlightSim.air_time` adds up the seconds spent airborne (not the slide); `launch()` sets it to 0.
- `RunSession.result()` has `air_time`.
