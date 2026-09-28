---
id: 005-flight-sim-slide
status: ready
tests: [tests/acceptance/test_005_flight_sim_slide.gd]
files: [scripts/core/flight_sim.gd]
read: [scripts/core/balance.gd]
---

# FlightSim part 3: sliding to a stop, and simulate()

Edit `scripts/core/flight_sim.gd`.

1. In `step()`, add an `else:` branch to `if is_airborne():` that calls `_slide(dt)`.
2. Add:
   ```gdscript
   func _slide(dt: float) -> void:
   	position.y = 0.0
   	velocity.y = 0.0
   	velocity.x = move_toward(velocity.x, 0.0, Balance.SLIDE_FRICTION * dt)
   	position.x += velocity.x * dt
   	if absf(velocity.x) <= Balance.STOP_SPEED:
   		velocity = Vector2.ZERO
   		stopped = true
   ```
3. Add a helper that steps until the projectile stops or `max_steps` is reached, and returns the number of
   steps it took:
   ```gdscript
   func simulate(dt: float, max_steps: int) -> int:
   	var steps := 0
   	while not stopped and steps < max_steps:
   		step(dt)
   		steps += 1
   	return steps
   ```

Keep everything else as it is.

## Acceptance criteria
- On the ground the projectile slows by 6 m/s² (update speed first, then position) and stops below 0.1 m/s.
- `step()` does nothing once `stopped` is true.
- A normal shot launched at (15, 15) m/s bounces, slides and stops.
