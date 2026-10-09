---
id: 311-hat-bonuses
status: ready
tests: [tests/acceptance/test_311_hat_bonuses.gd]
files: [scripts/core/hat_bonuses.gd, scripts/core/progress.gd, scripts/core/hats.gd]
---

# Hats that help

Milestone 45 makes hats useful and the animals nicer. Each hat now gives a small boost in its style: `HatBonuses`
(a new core script) says what each one gives (`text`) and applies it to a shot's stats (`apply`): the Propeller Cap
+3% launch speed, the Crown +10% score, the Wizard Hat -5% air drag, and so on. Classic shots get the worn hat's
boost (`Progress.stats()`); task 312 does the roguelike.

**1. Create the file `scripts/core/hat_bonuses.gd`** with exactly this code (use that exact path as the edit's file name):
```gdscript
class_name HatBonuses
extends RefCounted
## Each hat gives the alien a small boost of its own, in its style: a nice extra, never a must.

## What each hat gives (hats not listed give nothing).
const LIST: Dictionary = {
	"party": "+2 points per bounce",
	"propeller": "+3% launch speed",
	"chef": "+2 star value",
	"top_hat": "+0.5 m launch height",
	"wizard": "-5% air drag",
	"crown": "+10% score",
	"cowboy": "+0.02 bounciness",
	"viking": "+0.4 m star reach",
	"beanie": "+2% launch speed, -2% air drag",
}


## What `hat_id` gives ("" for none).
static func text(hat_id: String) -> String:
	return str(LIST.get(hat_id, ""))


## Gives `stats` the boost of `hat_id` (in place) and returns them.
static func apply(stats: PlayerStats, hat_id: String) -> PlayerStats:
	match hat_id:
		"party":
			stats.bounce_bonus += 2
		"propeller":
			stats.max_speed *= 1.03
		"chef":
			stats.star_value += 2
		"top_hat":
			stats.launch_height += 0.5
		"wizard":
			stats.drag *= 0.95
		"crown":
			stats.score_multiplier += 0.1
		"cowboy":
			stats.restitution = minf(stats.restitution + 0.02, RoguePerks.MAX_RESTITUTION)
		"viking":
			stats.pickup_radius += 0.4
		"beanie":
			stats.max_speed *= 1.02
			stats.drag *= 0.98
	return stats
```

**2. `scripts/core/progress.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds one line to `stats()` before its return; nothing else changes.

Edit 1 - SEARCH:
```gdscript
func stats() -> PlayerStats:
	var s := PlayerStats.from_levels(levels)
	s.hills = Terrain.for_best_distance(best_distance)
	return s
```
REPLACE:
```gdscript
func stats() -> PlayerStats:
	var s := PlayerStats.from_levels(levels)
	s.hills = Terrain.for_best_distance(best_distance)
	HatBonuses.apply(s, hat)
	return s
```

**3. `scripts/core/hats.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE changes the comment at the top; nothing else changes.

Edit 1 - SEARCH:
```gdscript
## Cosmetic hats for the alien. Each one unlocks by playing; hats never change the physics.
```
REPLACE:
```gdscript
## Hats for the alien. Each one unlocks by playing and gives a small boost in its style (see HatBonuses).
```

## Acceptance criteria
- `HatBonuses.text(id)` and `HatBonuses.apply(stats, id)` work as listed; every hat but "none" gives something.
- `Progress.stats()` includes the worn hat's boost.
