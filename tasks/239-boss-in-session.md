---
id: 239-boss-in-session
status: ready
tests: [tests/acceptance/test_239_boss_in_session.gd]
files: [scripts/core/player_stats.gd, scripts/core/run_session.gd]
---

# Shots fight the boss

The boss fight (task 238) now takes part in shots. `PlayerStats.boss` is the boss a roguelike shot is fired at
(RogueRun sets it in task 241); RunSession fights a copy of it, so predicting a shot never hurts the real boss.
Each step checks the targets against the alien's drawn body (`stats.pickup_offset`), and the result reports
`boss_hp` (after the shot) and `boss_damage`.

**1. `scripts/core/player_stats.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var bounce_bonus: int = 0
```
REPLACE:
```gdscript
var bounce_bonus: int = 0
## The roguelike boss this shot is fired at (null when there is none); RunSession fights a copy.
var boss: BossFight = null
```

**2. `scripts/core/run_session.gd`**: exactly these 4 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var balloons: Balloons
```
REPLACE:
```gdscript
var balloons: Balloons
## A copy of stats.boss for this shot (null without a boss fight).
var boss: BossFight = null
```

Edit 2 - SEARCH:
```gdscript
	balloons = Balloons.new(Balloons.layout(course_seed, Balance.COURSE_LENGTH))
```
REPLACE:
```gdscript
	balloons = Balloons.new(Balloons.layout(course_seed, Balance.COURSE_LENGTH))
	if stats.boss != null:
		boss = stats.boss.copy()
```

Edit 3 - SEARCH:
```gdscript
	balloons.after_step(sim, previous)
```
REPLACE:
```gdscript
	balloons.after_step(sim, previous)
	if boss != null:
		boss.after_step(sim, previous, stats.pickup_offset)
```

Edit 4 - SEARCH:
```gdscript
	r["air_time"] = sim.air_time
	return r
```
REPLACE:
```gdscript
	r["air_time"] = sim.air_time
	if boss != null:
		r["boss_hp"] = boss.hp
		r["boss_damage"] = boss.damage
	return r
```

## Acceptance criteria
- `PlayerStats.boss` (null by default); `RunSession.boss` is `stats.boss.copy()` when there is one.
- Every step calls `boss.after_step(sim, previous, stats.pickup_offset)`; `result()` has `boss_hp` and `boss_damage` (only with a boss).
