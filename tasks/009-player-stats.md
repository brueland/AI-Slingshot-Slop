---
id: 009-player-stats
status: ready
tests: [tests/acceptance/test_009_player_stats.gd]
files: [scripts/core/player_stats.gd]
read: [scripts/core/balance.gd, scripts/core/upgrade_catalog.gd, scripts/core/flight_sim.gd]
---

# PlayerStats: gameplay numbers from upgrade levels

Create `scripts/core/player_stats.gd`.

```gdscript
class_name PlayerStats
extends RefCounted
## Gameplay numbers computed from upgrade levels. See docs/DESIGN.md section 4.

var max_speed: float = Balance.BASE_MAX_SPEED
var launch_height: float = Balance.BASE_LAUNCH_HEIGHT
var guide_points: int = Balance.BASE_GUIDE_POINTS
var drag: float = Balance.BASE_DRAG
var restitution: float = Balance.BASE_RESTITUTION
var boost_charges: int = 0
var score_multiplier: float = 1.0
var star_value: int = Balance.BASE_STAR_VALUE
var bounce_bonus: int = 0
```

Add `static func from_levels(levels: Dictionary) -> PlayerStats` that creates a `PlayerStats.new()` and fills
it from the levels dictionary (id -> level). A missing id means level 0. Clamp each level to
`0..UpgradeCatalog.max_level(id)`; ignore unknown ids. With `L(id)` = that clamped level:

| field | formula |
|---|---|
| max_speed | `Balance.BASE_MAX_SPEED * (1.0 + 0.25 * L("power"))` |
| launch_height | `Balance.BASE_LAUNCH_HEIGHT + 1.5 * L("height")` |
| guide_points (int) | `Balance.BASE_GUIDE_POINTS + 6 * L("guide")` |
| drag | `Balance.BASE_DRAG * (1.0 - 0.18 * L("aero"))` |
| restitution | `Balance.BASE_RESTITUTION + 0.08 * L("bounce")` |
| boost_charges (int) | `L("boosts")` |
| score_multiplier | `1.0 + 0.25 * L("multiplier")` |
| star_value (int) | `Balance.BASE_STAR_VALUE + 5 * L("star_value")` |
| bounce_bonus (int) | `3 * L("bounce_bonus")` |

(0.25, 1.5, 6, 0.18, 0.08, 5 and 3 are the `per_level` values in `UpgradeCatalog.UPGRADES`; reading them
from there is fine.) JSON loads numbers as floats, so convert levels with `int(...)`.

Get each level with this helper. Use `clampi`, **not** `clamp`: `clamp` returns an untyped Variant, and
`var x := clamp(...)` then fails to load with "The variable type is being inferred from a Variant value".

```gdscript
static func _level(levels: Dictionary, id: String) -> int:
	return clampi(int(levels.get(id, 0)), 0, UpgradeCatalog.max_level(id))
```

For example: `s.max_speed = Balance.BASE_MAX_SPEED * (1.0 + 0.25 * _level(levels, "power"))`.

Also add:
```gdscript
func apply_to(sim: FlightSim) -> void:
	sim.drag = drag
	sim.restitution = restitution
	sim.boost_charges = boost_charges
```

## Acceptance criteria
- No upgrades gives the base numbers; level 2 everywhere gives max_speed 33, launch_height 5, guide_points 18,
  drag 0.00128, restitution 0.51, boost_charges 2, multiplier 1.5, star_value 20, bounce_bonus 6.
- Levels above the max or below 0 are clamped; int fields are ints.
