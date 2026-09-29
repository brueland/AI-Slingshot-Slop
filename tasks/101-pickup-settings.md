---
id: 101-pickup-settings
status: ready
tests: [tests/acceptance/test_101_pickup_settings.gd]
files: [scripts/core/player_stats.gd, scripts/core/run_tracker.gd, scripts/core/run_session.gd]
---

# Star pickups become a setting

Milestone 11 makes roguelike star goals fairer with alien sizes. First, star pickups get two settings. The
defaults keep the classic rule exactly (a star within 1.5 m of the alien's contact point); a positive offset measures
from higher up (the alien's body), so rolling into a low star counts. Use small SEARCH/REPLACE edits.

**1. `scripts/core/player_stats.gd`:** **declare** these right after `var bounce_bonus: int = 0`:
```gdscript
## Star pickups: a star is collected within pickup_radius of a point pickup_offset meters above the alien's
## contact point. The defaults are the classic rule; the roguelike measures from the alien's body (see RogueSizes).
var size_scale: float = 1.0
var pickup_offset: float = 0.0
var pickup_radius: float = Balance.STAR_RADIUS
```

**2. `scripts/core/run_tracker.gd`** (keep everything else):
- **Declare** after `var mud_hits: int = 0`:
  ```gdscript
  var pickup_offset: float = 0.0
  var pickup_radius: float = Balance.STAR_RADIUS
  ```
- `_init` gets two optional parameters (the first lines of the function become):
  ```gdscript
  func _init(course_items: Array = [], p_pickup_offset: float = 0.0, p_pickup_radius: float = Balance.STAR_RADIUS) -> void:
  	items = course_items
  	pickup_offset = p_pickup_offset
  	pickup_radius = p_pickup_radius
  ```
- In the `"star":` branch of `after_step()`, replace the two lines
  `var closest := Geometry2D.get_closest_point_to_segment(star, previous_position, sim.position)` and
  `if closest.distance_to(star) <= Balance.STAR_RADIUS:` with:
  ```gdscript
  				var lift := Vector2(0.0, pickup_offset)
  				var closest := Geometry2D.get_closest_point_to_segment(star, previous_position + lift, sim.position + lift)
  				if closest.distance_to(star) <= pickup_radius:
  ```

**3. `scripts/core/run_session.gd`:** in `_init()`, the tracker line becomes:
```gdscript
	tracker = RunTracker.new(course, stats.pickup_offset, stats.pickup_radius)
```

## Acceptance criteria
- PlayerStats: `size_scale` 1.0, `pickup_offset` 0.0, `pickup_radius` 1.5 by default (classic stars unchanged).
- With offset 0.75 and radius 1.65, rolling on the ground collects a star 2.2 m up but not one 3.5 m up.
- RunSession passes the stats' pickup settings to its tracker.
