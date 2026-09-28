---
id: 019-tracker-springs-mud
status: ready
tests: [tests/acceptance/test_019_tracker_springs_mud.gd]
files: [scripts/core/run_tracker.gd]
read: [scripts/core/flight_sim.gd, scripts/core/balance.gd]
---

# RunTracker part 2: springs and mud

Edit `scripts/core/run_tracker.gd`. In `after_step`, handle the two ground items as well as stars (a `match`
on `item["type"]` works well). Both only trigger when the projectile is on the ground (`sim.position.y <= 0.0`),
and each item triggers once.

**Spring** at `x`: if `sim.position.y <= 0.0` and `absf(sim.position.x - x) <= Balance.SPRING_HALF_WIDTH`:
```gdscript
_used[index] = true
sim.velocity.y = maxf(sim.velocity.y, Balance.SPRING_SPEED)
sim.velocity.x += Balance.SPRING_PUSH
sim.stopped = false
springs_hit += 1
spring_hit.emit(index)
```

**Mud** at `x`: if `sim.position.y <= 0.0` and `sim.position.x >= x` and `sim.position.x <= x + Balance.MUD_WIDTH`:
```gdscript
_used[index] = true
sim.velocity.x *= Balance.MUD_FACTOR
mud_hits += 1
mud_hit.emit(index)
```

Keep the star logic from task 018 unchanged.

## Acceptance criteria
- A sliding projectile on a spring gets 14 m/s up and +4 m/s forward (a faster upward speed is kept), even if
  it had stopped. Springs do nothing to projectiles in the air or more than 1.5 m away.
- Mud halves the horizontal speed once, only on the ground inside [x, x + 6].
