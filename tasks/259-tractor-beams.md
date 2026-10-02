---
id: 259-tractor-beams
status: ready
tests: [tests/acceptance/test_259_tractor_beams.gd]
files: [scripts/core/tractor_beams.gd, scripts/core/run_session.gd, scripts/game/ufo.gd]
---

# Tractor beams

The friendly UFOs (they float at 180, 420, 750, 1100 and 1600 m, 22 m up) now shine a tractor beam down to the
ground, and flying into one pulls the alien gently up: 9 m/s per second, less than gravity, so it slows a fall and
gives a little lift. `TractorBeams` (a new core script) has the beams' shape; RunSession applies the pull while
the alien is in the air; the UFO view draws each beam (brighter once the UFO has said hello).

**1. Create the file `scripts/core/tractor_beams.gd`** with exactly this code (use that exact path as the edit's file name):
```gdscript
class_name TractorBeams
extends RefCounted
## The friendly UFOs' tractor beams: a cone of light from each UFO down to the ground. Flying into one pulls the alien
## gently up (less than gravity pulls it down, so it slows a fall and gives a little lift). The UFOs float here.

const SPOTS_M: Array[float] = [180.0, 420.0, 750.0, 1100.0, 1600.0]
const HEIGHT_M: float = 22.0
## Upward pull inside a beam (m/s per second); gravity is 15.
const PULL: float = 9.0
## Half the beam's width (meters) at the UFO and at the ground.
const TOP_HALF_WIDTH: float = 0.8
const BOTTOM_HALF_WIDTH: float = 3.0


## Is `point` (meters) inside one of the beams?
static func inside(point: Vector2) -> bool:
	if point.y <= 0.0 or point.y >= HEIGHT_M:
		return false
	var half := lerpf(BOTTOM_HALF_WIDTH, TOP_HALF_WIDTH, point.y / HEIGHT_M)
	for x in SPOTS_M:
		if absf(point.x - x) <= half:
			return true
	return false
```

**2. `scripts/core/run_session.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds two lines in `step()` before `sim.step(dt)`; nothing else changes.

Edit 1 - SEARCH:
```gdscript
	var previous := sim.position
	sim.step(dt)
```
REPLACE:
```gdscript
	var previous := sim.position
	if sim.is_airborne() and TractorBeams.inside(sim.position + Vector2(0.0, stats.pickup_offset)):
		sim.velocity.y += TractorBeams.PULL * dt
	sim.step(dt)
```

**3. `scripts/game/ufo.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE turns the short beam drawn only after hello into a beam to the ground, always drawn; nothing else in `_draw()` changes.

Edit 1 - SEARCH:
```gdscript
		if greeted[i]:
			draw_colored_polygon(PackedVector2Array([p + Vector2(-10, 4), p + Vector2(10, 4), p + Vector2(34, 90), p + Vector2(-34, 90)]), Color(1.0, 1.0, 0.6, 0.25))
```
REPLACE:
```gdscript
		# the tractor beam down to the ground (TractorBeams pulls the alien up inside it); brighter after hello
		var foot := WorldView.world_to_screen(Vector2(TractorBeams.SPOTS_M[i], 0.0))
		var top := TractorBeams.TOP_HALF_WIDTH * Balance.PIXELS_PER_METER
		var bottom := TractorBeams.BOTTOM_HALF_WIDTH * Balance.PIXELS_PER_METER
		draw_colored_polygon(PackedVector2Array([p + Vector2(-top, 4), p + Vector2(top, 4), foot + Vector2(bottom, 0), foot + Vector2(-bottom, 0)]),
			Color(1.0, 1.0, 0.6, 0.25 if greeted[i] else 0.12))
```

## Acceptance criteria
- `TractorBeams.inside(point)` is true inside a cone from each UFO (0.8 m half width) to the ground (3 m half width).
- While airborne with its body's center in a beam, the alien gains `TractorBeams.PULL` (9) m/s of upward speed per second.
- Every UFO draws its beam to the ground.
