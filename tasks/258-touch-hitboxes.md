---
id: 258-touch-hitboxes
status: ready
tests: [tests/acceptance/test_258_touch_hitboxes.gd]
files: [scripts/core/run_tracker.gd, scripts/core/balloons.gd, scripts/core/run_session.gd]
---

# Touching counts

Springs and balloons only reacted to the alien's contact point (its feet), so a touch that looked like a hit often
missed. Now a spring fires when the alien's side reaches it (its half width plus 0.8 of the alien's body radius) or
the alien comes within `RunTracker.SPRING_TOP` (0.6 m) over it, and balloons check the alien's body (`body`, a
ball centered `body` above the feet) like stars do. RunSession gives its balloons the alien's body size.

**1. `scripts/core/run_tracker.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Edit 2 changes the spring's `if` line in `after_step()` (and adds two lines before it); nothing else changes.

Edit 1 - SEARCH:
```gdscript
signal mud_hit(index: int)
```
REPLACE:
```gdscript
signal mud_hit(index: int)

## A spring fires when the alien comes this low over it (meters above the ground), not only on the ground.
const SPRING_TOP: float = 0.6
```

Edit 2 - SEARCH:
```gdscript
				if sim.position.y <= 0.0 and absf(sim.position.x - x) <= Balance.SPRING_HALF_WIDTH:
```
REPLACE:
```gdscript
				# the alien's side touching the spring counts: its body reaches 0.8 x pickup_offset to each side
				var reach := Balance.SPRING_HALF_WIDTH + pickup_offset * 0.8
				if sim.position.y <= sim.ground_height(x) + SPRING_TOP and absf(sim.position.x - x) <= reach:
```

**2. `scripts/core/balloons.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Edits 2 and 3 change the checks in `after_step()`; nothing else changes.

Edit 1 - SEARCH:
```gdscript
var popped_count: int = 0
```
REPLACE:
```gdscript
var popped_count: int = 0
## The alien's body: a ball of this radius whose center is this far above its contact point (0 = just the point).
var body: float = 0.0
```

Edit 2 - SEARCH:
```gdscript
		if p.x < previous_position.x - 2.0 or p.x > sim.position.x + 2.0:
```
REPLACE:
```gdscript
		if p.x < previous_position.x - 2.0 - body or p.x > sim.position.x + 2.0 + body:
```

Edit 3 - SEARCH:
```gdscript
		var closest := Geometry2D.get_closest_point_to_segment(p, previous_position, sim.position)
		if closest.distance_to(p) <= RADIUS:
```
REPLACE:
```gdscript
		var lift := Vector2(0.0, body)
		var closest := Geometry2D.get_closest_point_to_segment(p, previous_position + lift, sim.position + lift)
		if closest.distance_to(p) <= RADIUS + body:
```

**3. `scripts/core/run_session.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	balloons = Balloons.new(Balloons.layout(course_seed, Balance.COURSE_LENGTH))
```
REPLACE:
```gdscript
	balloons = Balloons.new(Balloons.layout(course_seed, Balance.COURSE_LENGTH))
	balloons.body = stats.pickup_offset
```

## Acceptance criteria
- A spring fires within `SPRING_HALF_WIDTH + 0.8 * pickup_offset` of it when the alien is at most `SPRING_TOP` over the ground.
- `Balloons.body` (0 by default; RunSession sets the alien's `pickup_offset`) makes balloons pop when they touch the alien's body.
