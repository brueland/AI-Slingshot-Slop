---
id: 006-flight-sim-boost
status: ready
tests: [tests/acceptance/test_006_flight_sim_boost.gd]
files: [scripts/core/flight_sim.gd]
read: [scripts/core/balance.gd]
---

# FlightSim part 4: mid-air boosts

Edit `scripts/core/flight_sim.gd`. The player can spend a boost charge while the projectile is in the air.

1. Add a second signal next to `bounced`: `signal boosted`
2. Add:
   ```gdscript
   func boost() -> bool:
   	if stopped or boost_charges <= 0 or not is_airborne():
   		return false
   	velocity += Vector2(1.0, 1.0).normalized() * Balance.BOOST_SPEED
   	boost_charges -= 1
   	boosted.emit()
   	return true
   ```

Keep everything else as it is.

## Acceptance criteria
- A boost adds 12 m/s along the up-right diagonal, uses one charge and emits `boosted`.
- No boost without charges, while sliding on the ground, or after stopping.
