---
id: 118-boss-run
status: ready
tests: [tests/acceptance/test_118_boss_run.gd]
files: [scripts/core/rogue_run.gd]
read: [scripts/core/rogue_goals.gd]
---

# Boss rounds in the roguelike run

The run uses a boss goal on boss rounds. Beating a boss gives an extra life, and `finish_shot()` reports it as
`"boss_beaten"`. A miss keeps the boss for the retry.

**`scripts/core/rogue_run.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes. (Edit 3 only appends `, "boss_beaten": boss_beaten` to the returned Dictionary.)

Edit 1 - SEARCH:
```gdscript
	var met := RogueGoals.check(goal, result)
```
REPLACE:
```gdscript
	var met := RogueGoals.check(goal, result)
	var boss_beaten := met and str(goal.get("type", "")) == "boss"
	if boss_beaten:
		lives += 1
```

Edit 2 - SEARCH:
```gdscript
		goal = RogueGoals.make_goal(round_number, run_seed)
```
REPLACE:
```gdscript
		goal = RogueGoals.make_goal(round_number, run_seed)
		if RogueGoals.is_boss_round(round_number):
			goal = RogueGoals.make_boss_goal(round_number, run_seed)
```

Edit 3 - SEARCH:
```gdscript
"offer": offer.duplicate()}
```
REPLACE:
```gdscript
"offer": offer.duplicate(), "boss_beaten": boss_beaten}
```

## Acceptance criteria
- After round 11 the goal is `RogueGoals.make_boss_goal(12, run_seed)`; round 13 is normal again.
- Beating a boss: `boss_beaten` true and +1 life (so the lives stay the same after a miss and a win).
