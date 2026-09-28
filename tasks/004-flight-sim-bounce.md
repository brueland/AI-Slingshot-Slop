---
id: 004-flight-sim-bounce
status: ready
tests: [tests/acceptance/test_004_flight_sim_bounce.gd]
files: [scripts/core/flight_sim.gd]
read: [scripts/core/balance.gd]
---

# FlightSim part 2: bouncing on the ground

Edit `scripts/core/flight_sim.gd`. Replace the temporary "stop on the ground" code from task 003 with real
ground contact.

1. Add a signal at the top of the class: `signal bounced(impact_speed: float)`
2. In `step()`, where the projectile reaches the ground (`if position.y <= 0.0:`), call a new function
   `_touch_ground()` instead of stopping.
3. Add:
   ```gdscript
   func _touch_ground() -> void:
   	position.y = 0.0
   	var rebound := -velocity.y * restitution
   	if rebound >= Balance.MIN_BOUNCE_SPEED:
   		velocity.y = rebound
   		velocity.x *= Balance.BOUNCE_FRICTION
   		bounce_count += 1
   		bounced.emit(rebound)
   	else:
   		velocity.y = 0.0
   ```
   A soft landing (rebound below 2 m/s) keeps its horizontal speed and does **not** set `stopped`; it will
   slide along the ground (task 005 adds sliding). For now `step()` does nothing when not airborne.

Keep everything else in the file as it is.

## Acceptance criteria
- Hard landings bounce with `restitution`, lose 15% horizontal speed, count a bounce and emit `bounced(rebound)`.
- Soft landings set vertical speed to 0 without stopping; the projectile never goes below y = 0.
- The task 003 tests still pass.
