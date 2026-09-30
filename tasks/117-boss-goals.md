---
id: 117-boss-goals
status: ready
tests: [tests/acceptance/test_117_boss_goals.gd]
files: [scripts/core/rogue_goals.gd]
---

# Roguelike boss goals

From round 12, every 6th roguelike round is a boss round: two goals of different types at once (never distance
together with zone, which could clash), e.g. "BOSS: Fly at least 139 m + Bounce 4 times". A boss goal is met only
when both parts are. Task 118 uses it in the run.

**`scripts/core/rogue_goals.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
const STARS_FROM_ROUND: int = 4
```
REPLACE:
```gdscript
const STARS_FROM_ROUND: int = 4
## Boss rounds: from BOSS_FROM_ROUND on, every BOSS_EVERY rounds, two goals at once.
const BOSS_FROM_ROUND: int = 12
const BOSS_EVERY: int = 6
```

Edit 2 - SEARCH:
```gdscript
static func describe(type: String, target: float) -> String:
```
REPLACE:
```gdscript
static func is_boss_round(round_number: int) -> bool:
	return round_number >= BOSS_FROM_ROUND and round_number % BOSS_EVERY == 0


## A boss goal: two goals of different types at once (never distance together with zone, which could clash).
static func make_boss_goal(round_number: int, run_seed: int) -> Dictionary:
	var first := make_goal(round_number, run_seed)
	var second := make_goal(round_number, run_seed + 1)
	var k := 1
	while k < 50 and (second["type"] == first["type"] or (first["type"] in ["distance", "zone"] and second["type"] in ["distance", "zone"])):
		k += 1
		second = make_goal(round_number, run_seed + k)
	return {"type": "boss", "target": 0.0, "round": round_number, "parts": [first, second],
		"text": "BOSS: %s + %s" % [first["text"], second["text"]]}


static func describe(type: String, target: float) -> String:
```

Edit 3 - SEARCH:
```gdscript
			return d >= target and d <= target + ZONE_WIDTH
	return false
```
REPLACE:
```gdscript
			return d >= target and d <= target + ZONE_WIDTH
		"boss":
			var parts: Array = goal.get("parts", [])
			for part in parts:
				if not check(part, result):
					return false
			return not parts.is_empty()
	return false
```

## Acceptance criteria
- `is_boss_round(r)`: true for 12, 18, 24, ...; false before 12 and in between.
- `make_boss_goal(r, seed)`: type "boss", two parts of different types (the first is `make_goal(r, seed)`), text
  "BOSS: <first> + <second>", the same for the same round and seed.
- `check` meets a boss goal only when every part is met; other goals are unchanged.
