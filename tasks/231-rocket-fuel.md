---
id: 231-rocket-fuel
status: ready
tests: [tests/acceptance/test_231_rocket_fuel.gd, tests/acceptance/test_006_flight_sim_boost.gd, tests/acceptance/test_020_run_session.gd, tests/acceptance/test_036_boost_pause_input.gd]
files: [scripts/core/balance.gd, scripts/core/flight_sim.gd, scripts/core/run_session.gd]
---

# The rocket burns while the key is held

Milestone 30 gives the rocket a throttle. Until now each rocket charge was a fixed kick of 12 m/s. Now the rocket
fires for as long as the boost key is held: 24 m/s of push per second, and each rocket tank (upgrade level or
Rocket perk, still counted in `boost_charges`) is 0.5 s of burn per flight. A full tank adds the same 12 m/s as
before, but a short tap adds less, so the player has fine control. `boost_fuel` holds the seconds left. Three older
tests are updated for the new rule.

**1. `scripts/core/balance.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
const BOOST_SPEED: float = 12.0
```
REPLACE:
```gdscript
const BOOST_SPEED: float = 12.0
## The rocket fires while the boost key is held: BOOST_THRUST m/s of push per second, and each rocket tank (upgrade
## level or Rocket perk) burns for BOOST_TANK_SECONDS per flight. A full tank adds BOOST_SPEED, like the old boost.
const BOOST_THRUST: float = 24.0
const BOOST_TANK_SECONDS: float = 0.5
```

**2. `scripts/core/flight_sim.gd`**: exactly these 5 SEARCH/REPLACE edit(s). Edit 2 replaces the body of `boost()` (it no longer pushes or spends a charge); every other REPLACE keeps the SEARCH lines and adds the new ones. Edit 5 adds three functions at the end of the file. Nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var boost_charges: int = 0
```
REPLACE:
```gdscript
var boost_charges: int = 0
## Seconds of rocket left this flight: boost_charges tanks of Balance.BOOST_TANK_SECONDS, filled at launch.
var boost_fuel: float = 0.0
## True while the boost key is held; the rocket burns while it is held, in the air and with fuel left.
var boost_held: bool = false
```

Edit 2 - SEARCH:
```gdscript
func boost() -> bool:
	if stopped or boost_charges <= 0 or not is_airborne():
		return false
	velocity += Vector2(1.0, 1.0).normalized() * Balance.BOOST_SPEED
	boost_charges -= 1
	boosted.emit()
	return true
```
REPLACE:
```gdscript
## The boost key went down: the rocket fires until the key is released (see step). True when it starts firing.
func boost() -> bool:
	if stopped or boost_held or boost_fuel <= 0.0 or not is_airborne():
		return false
	boost_held = true
	boosted.emit()
	return true
```

Edit 3 - SEARCH:
```gdscript
	bounce_count = 0
	stopped = false
```
REPLACE:
```gdscript
	bounce_count = 0
	stopped = false
	boost_fuel = boost_capacity()
	boost_held = false
```

Edit 4 - SEARCH:
```gdscript
	if is_airborne():
		var accel := Vector2(0.0, -gravity) - velocity * velocity.length() * drag
```
REPLACE:
```gdscript
	if is_airborne():
		if is_boosting():
			var burn := minf(dt, boost_fuel)
			velocity += Vector2(1.0, 1.0).normalized() * Balance.BOOST_THRUST * burn
			boost_fuel -= burn
		var accel := Vector2(0.0, -gravity) - velocity * velocity.length() * drag
```

Edit 5 - SEARCH:
```gdscript
func simulate(dt: float, max_steps: int) -> int:
	var steps := 0
	while not stopped and steps < max_steps:
		step(dt)
		steps += 1
	return steps
```
REPLACE:
```gdscript
func simulate(dt: float, max_steps: int) -> int:
	var steps := 0
	while not stopped and steps < max_steps:
		step(dt)
		steps += 1
	return steps


## The boost key went up: the rocket stops firing.
func release_boost() -> void:
	boost_held = false


func is_boosting() -> bool:
	return boost_held and boost_fuel > 0.0 and not stopped and is_airborne()


## Rocket seconds a flight starts with: one Balance.BOOST_TANK_SECONDS tank per boost charge.
func boost_capacity() -> float:
	return boost_charges * Balance.BOOST_TANK_SECONDS
```

**3. `scripts/core/run_session.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds `release_boost()` at the end of the file; nothing else changes.

Edit 1 - SEARCH:
```gdscript
	r["air_time"] = sim.air_time
	return r
```
REPLACE:
```gdscript
	r["air_time"] = sim.air_time
	return r


## The boost key went up.
func release_boost() -> void:
	sim.release_boost()
```

## Acceptance criteria
- `Balance.BOOST_THRUST` is 24.0 and `Balance.BOOST_TANK_SECONDS` is 0.5.
- `FlightSim.launch()` fills `boost_fuel` with `boost_capacity()` (0.5 s per charge); `boost()` starts the burn, `release_boost()` stops it,
  and `step()` pushes along (1, 1) at 24 m/s per second while `is_boosting()`.
- `RunSession.release_boost()` passes the key going up to the sim.
