---
id: 003-flight-sim-flight
status: ready
tests: [tests/acceptance/test_003_flight_sim_flight.gd]
files: [scripts/core/flight_sim.gd]
read: [scripts/core/balance.gd]
---

# FlightSim part 1: flying through the air

Create `scripts/core/flight_sim.gd`, a deterministic projectile simulation in world units (meters, y up,
ground at y = 0). This task covers flight through the air only; tasks 004-006 add bouncing, sliding and boosts.

```gdscript
class_name FlightSim
extends RefCounted
## Deterministic projectile simulation in world units (meters, y up). See docs/DESIGN.md section 7.

var position: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var gravity: float = Balance.GRAVITY
var drag: float = Balance.BASE_DRAG
var restitution: float = Balance.BASE_RESTITUTION
var boost_charges: int = 0
var bounce_count: int = 0
var max_height: float = 0.0
var stopped: bool = false
var start_x: float = 0.0
```

Declare all of these now, even the ones later tasks use. Then add:

- `func launch(start: Vector2, launch_velocity: Vector2) -> void`: set `position = start`,
  `velocity = launch_velocity`, `start_x = start.x`, `max_height = start.y`, `bounce_count = 0`, `stopped = false`.
- `func is_airborne() -> bool`: `return position.y > 0.0 or velocity.y > 0.0`
- `func distance() -> float`: `return position.x - start_x`
- `func step(dt: float) -> void`, semi-implicit Euler, in this exact order:
  ```gdscript
  if stopped:
  	return
  if is_airborne():
  	var accel := Vector2(0.0, -gravity) - velocity * velocity.length() * drag
  	velocity += accel * dt
  	position += velocity * dt
  	max_height = maxf(max_height, position.y)
  	if position.y <= 0.0:
  		# Ground handling comes in task 004. For now:
  		position.y = 0.0
  		velocity = Vector2.ZERO
  		stopped = true
  ```

## Acceptance criteria
- Defaults come from `Balance` (gravity 15, drag 0.002, restitution 0.35).
- `step()` updates velocity first, then position, exactly as above (the test repeats the same math).
