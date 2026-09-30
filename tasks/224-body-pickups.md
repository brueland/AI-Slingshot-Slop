---
id: 224-body-pickups
status: ready
tests: [tests/acceptance/test_224_body_pickups.gd, tests/acceptance/test_101_pickup_settings.gd, tests/acceptance/test_102_rogue_sizes.gd]
files: [scripts/core/balance.gd, scripts/core/rogue_sizes.gd, scripts/core/player_stats.gd, scripts/game/projectile_view.gd]
---

# Pickups match the drawn alien

Milestone 29 makes the alien crisp and fair. The alien is drawn 1.5 times its physical size, but stars were still
picked up by the smaller physical body, so a star touching the big alien's head did not count. Now stars are picked
up by the alien as it is drawn: within its drawn radius + 0.9 m of its drawn center, for every size and in classic
too. Two older tests are updated for the new numbers.

**1. `scripts/core/balance.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
const PROJECTILE_RADIUS: float = 0.75
```
REPLACE:
```gdscript
const PROJECTILE_RADIUS: float = 0.75
## The alien is drawn this much bigger than PROJECTILE_RADIUS; star pickups use the drawn body.
const LOOK_SCALE: float = 1.5
```

**2. `scripts/core/rogue_sizes.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE changes that one line in `apply()`; nothing else changes.

Edit 1 - SEARCH:
```gdscript
	var body := Balance.PROJECTILE_RADIUS * s
```
REPLACE:
```gdscript
	var body := Balance.PROJECTILE_RADIUS * s * Balance.LOOK_SCALE
```

**3. `scripts/core/player_stats.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE changes the comment and the two default values; nothing else changes.

Edit 1 - SEARCH:
```gdscript
## Star pickups: a star is collected within pickup_radius of a point pickup_offset meters above the alien's
## contact point. The defaults are the classic rule; the roguelike measures from the alien's body (see RogueSizes).
var size_scale: float = 1.0
var pickup_offset: float = 0.0
var pickup_radius: float = Balance.STAR_RADIUS
```
REPLACE:
```gdscript
## Star pickups: a star is collected within pickup_radius of a point pickup_offset meters above the alien's
## contact point: the center of the alien as it is drawn, and its drawn radius plus RogueSizes.STAR_REACH.
var size_scale: float = 1.0
var pickup_offset: float = Balance.PROJECTILE_RADIUS * Balance.LOOK_SCALE
var pickup_radius: float = Balance.PROJECTILE_RADIUS * Balance.LOOK_SCALE + RogueSizes.STAR_REACH
```

**4. `scripts/game/projectile_view.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE makes the view use the same constant; nothing else changes.

Edit 1 - SEARCH:
```gdscript
const LOOK_SCALE: float = 1.5
```
REPLACE:
```gdscript
const LOOK_SCALE: float = Balance.LOOK_SCALE
```

## Acceptance criteria
- `Balance.LOOK_SCALE` is 1.5 and `ProjectileView.LOOK_SCALE` uses it.
- `PlayerStats` defaults and `RogueSizes.apply` measure pickups from the drawn body (radius 0.75 * size * 1.5, plus 0.9 m).
