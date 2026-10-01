---
id: 240-fight-goals
status: ready
tests: [tests/acceptance/test_240_fight_goals.gd]
files: [scripts/core/rogue_goals.gd]
---

# Boss fight goals

Boss fights (tasks 238-239) get their own goal type, `"fight"`: every 10th roguelike round from round 10 is a fight
(`is_fight_round`), and a fight round is never a lucky round. A fight goal's target is the boss's full HP; it is met
when the shot's result has `boss_hp` 0; its progress is the share of HP knocked off.

**1. `scripts/core/rogue_goals.gd`**: exactly these 7 SEARCH/REPLACE edit(s). Edit 2 adds one condition to the `if` in `is_lucky_round()`; edits 3-6 add a `"fight"` branch to the `match` of `progress_ratio()`, `progress_text()`, `describe()` and `check()`; edit 7 adds `is_fight_round()` at the end of the file. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
const BOSS_EVERY: int = 6
```
REPLACE:
```gdscript
const BOSS_EVERY: int = 6
## Boss fights (BossFight): from FIGHT_FROM_ROUND on, every FIGHT_EVERY rounds.
const FIGHT_FROM_ROUND: int = 10
const FIGHT_EVERY: int = 10
```

Edit 2 - SEARCH:
```gdscript
	if round_number < 4 or is_boss_round(round_number):
```
REPLACE:
```gdscript
	if round_number < 4 or is_boss_round(round_number) or is_fight_round(round_number):
```

Edit 3 - SEARCH:
```gdscript
				return clampf((target + ZONE_WIDTH) / d, 0.0, 0.99)
			return _ratio(d, target)
```
REPLACE:
```gdscript
				return clampf((target + ZONE_WIDTH) / d, 0.0, 0.99)
			return _ratio(d, target)
		"fight":
			return 1.0 - _ratio(float(result.get("boss_hp", target)), target)
```

Edit 4 - SEARCH:
```gdscript
			return "%d m (stop at %d-%d m)" % [int(float(result.get("distance", 0.0))), n, n + int(ZONE_WIDTH)]
```
REPLACE:
```gdscript
			return "%d m (stop at %d-%d m)" % [int(float(result.get("distance", 0.0))), n, n + int(ZONE_WIDTH)]
		"fight":
			return "Boss HP %d/%d" % [int(result.get("boss_hp", n)), n]
```

Edit 5 - SEARCH:
```gdscript
			return "Stop between %d and %d m" % [n, n + int(ZONE_WIDTH)]
```
REPLACE:
```gdscript
			return "Stop between %d and %d m" % [n, n + int(ZONE_WIDTH)]
		"fight":
			return "Beat the boss (%d HP)" % n
```

Edit 6 - SEARCH:
```gdscript
			return d >= target and d <= target + ZONE_WIDTH
```
REPLACE:
```gdscript
			return d >= target and d <= target + ZONE_WIDTH
		"fight":
			return result.has("boss_hp") and int(result["boss_hp"]) <= 0
```

Edit 7 - SEARCH:
```gdscript
			return not parts.is_empty()
	return false
```
REPLACE:
```gdscript
			return not parts.is_empty()
	return false


## Boss fight rounds: round 10 and every 10th round after it (a fight takes the place of a boss goal).
static func is_fight_round(round_number: int) -> bool:
	return round_number >= FIGHT_FROM_ROUND and round_number % FIGHT_EVERY == 0
```

## Acceptance criteria
- `RogueGoals.FIGHT_FROM_ROUND` and `FIGHT_EVERY` are 10; `is_fight_round(r)` is true for 10, 20, 30...; those rounds are never lucky.
- For `{"type": "fight", "target": max_hp}`: `check` is `boss_hp <= 0` (false without `boss_hp`), `progress_ratio` is 1 - boss_hp / max_hp,
  `progress_text` is "Boss HP 3/12" and `describe("fight", 12)` is "Beat the boss (12 HP)".
