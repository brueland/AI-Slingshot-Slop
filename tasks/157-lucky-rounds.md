---
id: 157-lucky-rounds
status: ready
tests: [tests/acceptance/test_157_lucky_rounds.gd]
files: [scripts/core/rogue_goals.gd, scripts/core/rogue_run.gd]
---

# Lucky rounds

Milestone 19 adds more roguelike variety and small polish. Lucky rounds: from round 4, about one round in eight
(never a boss round) is lucky; meeting it gives an extra reroll. `finish_shot()` reports `"lucky"`.

**1. `scripts/core/rogue_goals.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
static func is_boss_round(round_number: int) -> bool:
```
REPLACE:
```gdscript
## Lucky rounds: from round 4, about one round in eight (never a boss round); meeting one gives a reroll.
static func is_lucky_round(round_number: int, run_seed: int) -> bool:
	if round_number < 4 or is_boss_round(round_number):
		return false
	return posmod(run_seed * 13 + round_number * 29, 8) == 0


static func is_boss_round(round_number: int) -> bool:
```

**2. `scripts/core/rogue_run.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes. (Edit 2 only appends `, "lucky": lucky` to the returned Dictionary.)

Edit 1 - SEARCH:
```gdscript
	var boss_beaten := met and str(goal.get("type", "")) == "boss"
```
REPLACE:
```gdscript
	var boss_beaten := met and str(goal.get("type", "")) == "boss"
	var lucky := met and RogueGoals.is_lucky_round(round_number, run_seed)
	if lucky:
		rerolls += 1
```

Edit 2 - SEARCH:
```gdscript
"boss_beaten": boss_beaten}
```
REPLACE:
```gdscript
"boss_beaten": boss_beaten, "lucky": lucky}
```

## Acceptance criteria
- `is_lucky_round(r, seed)`: posmod(seed * 13 + r * 29, 8) == 0 from round 4, never on boss rounds.
- Meeting a lucky round's goal gives +1 reroll and `"lucky": true`.
