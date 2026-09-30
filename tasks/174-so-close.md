---
id: 174-so-close
status: ready
tests: [tests/acceptance/test_174_so_close.gd]
files: [scripts/core/rogue_run.gd, scripts/game/feedback.gd, scripts/game/main.gd]
---

# So close!

A roguelike goal missed by only a little (the shot got 85% or more of the way) gets a "So close!" popup.

**1. `scripts/core/rogue_run.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Edit 1 adds a line; Edit 2 changes the end of the `return {...}` line at the end of `finish_shot()` (the SEARCH is only the end of that line). Nothing else changes.

Edit 1 - SEARCH:
```gdscript
	var met := RogueGoals.check(goal, result)
```
REPLACE:
```gdscript
	var met := RogueGoals.check(goal, result)
	var ratio := RogueGoals.progress_ratio(goal, result)
```

Edit 2 - SEARCH:
```gdscript
"boss_beaten": boss_beaten, "lucky": lucky}
```
REPLACE:
```gdscript
"boss_beaten": boss_beaten, "lucky": lucky, "ratio": ratio}
```

**2. `scripts/game/feedback.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Edit 1 adds two lines; Edit 2 adds three lines above the `if text == "":` check in `celebrate()`. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
const COMBO_WINDOW: float = 1.2
```
REPLACE:
```gdscript
const COMBO_WINDOW: float = 1.2
## A missed roguelike goal at least this close (0-1) gets a "So close!".
const CLOSE_RATIO: float = 0.85
```

Edit 2 - SEARCH:
```gdscript
	if text == "":
		return ""
```
REPLACE:
```gdscript
	if text == "" and float(result.get("goal_ratio", 0.0)) >= CLOSE_RATIO:
		_say("So close!", Color(1.0, 0.8, 0.4))
		return "So close!"
	if text == "":
		return ""
```

**3. `scripts/game/main.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE changes that one line in `_finish_run()`; nothing else changes.

Edit 1 - SEARCH:
```gdscript
		feedback.celebrate({"goal_met": rogue_outcome["met"]})
```
REPLACE:
```gdscript
		feedback.celebrate({"goal_met": rogue_outcome["met"], "goal_ratio": rogue_outcome["ratio"]})
```

## Acceptance criteria
- `RogueRun.finish_shot` returns `ratio` (how close the shot came to the goal it was for).
- `Feedback.celebrate` returns "So close!" (and pops it up) for a missed goal with `goal_ratio` >= 0.85.
