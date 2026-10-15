---
id: 317-tree-rest
status: ready
tests: [tests/acceptance/test_317_tree_rest.gd]
files: [scripts/core/trees.gd]
---

# No endless bonk against a tree

Bug: an alien too slow to break a tree that rolls up against it said "Bonk!" every frame forever and the shot never
ended. After a slow hit the alien is put at the edge of the tree's reach, which still counts as touching it, so
every step bounced it again (its speed flipping back and forth) and reset `stopped`. Now a side hit only counts
while the alien moves toward the trunk, and at a crawl (under REST_SPEED, 2 m/s) it comes to rest against the tree:
on the ground the shot ends, in the air it just falls.

**1. `scripts/core/trees.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Edit 1 adds a constant after BOUNCE; edit 2 replaces the side-hit `else:` branch at the end of `after_step()` (the crown branch above it does not change). Nothing else changes.

Edit 1 - SEARCH:
```gdscript
const BOUNCE: float = 0.4
```
REPLACE:
```gdscript
const BOUNCE: float = 0.4
## Slower than this (m/s) against a trunk, the alien just comes to rest there (no bounce).
const REST_SPEED: float = 2.0
```

Edit 2 - SEARCH:
```gdscript
		else:
			sim.position.x = x - reach if previous_position.x < x else x + reach
			sim.velocity.x = -sim.velocity.x * BOUNCE
		sim.stopped = false
		tree_bounced.emit(i)
```
REPLACE:
```gdscript
		else:
			var from_left := previous_position.x < x
			# only a move toward the trunk is a hit (pushed back to its side, it is still within reach next step)
			if (sim.velocity.x > 0.0) != from_left:
				continue
			sim.position.x = x - reach if from_left else x + reach
			if absf(sim.velocity.x) < REST_SPEED:
				sim.velocity.x = 0.0
				if not sim.is_airborne():
					sim.velocity = Vector2.ZERO
					sim.stopped = true
				continue
			sim.velocity.x = -sim.velocity.x * BOUNCE
		sim.stopped = false
		tree_bounced.emit(i)
```

## Acceptance criteria
- A slow roll into a tree ends the shot within 10 s with at most 3 bonks; moving away from a tree is no hit.
- A 10 m/s side hit still bounces back at 40%.
