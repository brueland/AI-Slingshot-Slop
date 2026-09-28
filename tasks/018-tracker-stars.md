---
id: 018-tracker-stars
status: ready
tests: [tests/acceptance/test_018_tracker_stars.gd]
files: [scripts/core/run_tracker.gd]
read: [scripts/core/flight_sim.gd, scripts/core/balance.gd]
---

# RunTracker part 1: collecting stars

Create `scripts/core/run_tracker.gd`. After every FlightSim step, the tracker checks the course items near
the projectile. This task handles stars; task 019 adds springs and mud.

```gdscript
class_name RunTracker
extends RefCounted
## Applies course items (stars, springs, mud) to a flight after each step. See docs/DESIGN.md section 9.

signal star_collected(index: int)
signal spring_hit(index: int)
signal mud_hit(index: int)

var items: Array = []
var stars_collected: int = 0
var springs_hit: int = 0
var mud_hits: int = 0
var _used: Array[bool] = []


func _init(course_items: Array = []) -> void:
	items = course_items
	_used.resize(items.size())
	_used.fill(false)
```

Add:
- `func is_used(index: int) -> bool`: false for out-of-range indexes, otherwise `_used[index]`.
- `func after_step(sim: FlightSim, previous_position: Vector2) -> void`: loop over the items by index. Skip
  used items, and (for speed) items with `x < previous_position.x - 10.0` or `x > sim.position.x + 10.0`.
  For a `"star"` item at `star := Vector2(x, y)`:
  ```gdscript
  var closest := Geometry2D.get_closest_point_to_segment(star, previous_position, sim.position)
  if closest.distance_to(star) <= Balance.STAR_RADIUS:
  	_used[index] = true
  	stars_collected += 1
  	star_collected.emit(index)
  ```
  Using the segment from the previous position to the new one means fast projectiles can't skip stars.
  Ignore other item types for now.

## Acceptance criteria
- A star within 1.5 m of the path of a step is collected once and `star_collected(index)` is emitted.
- Stars farther than 1.5 m from the path are not collected.
