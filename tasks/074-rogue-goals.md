---
id: 074-rogue-goals
status: ready
tests: [tests/acceptance/test_074_rogue_goals.gd]
files: [scripts/core/rogue_goals.gd]
read: [scripts/core/run_session.gd]
---

# Roguelike goals

The new roguelike mode (tasks 074-080) gives the player one goal per round. There is no last round: targets keep
growing. Round 1 is always "fly 40 m"; later rounds pick one of five goal types from a seeded random generator
(star goals, the hardest, only from round 4), so the player has to think about which perk helps with the next
goal. A goal is checked against the Dictionary that
`RunSession.result()` returns (`distance`, `max_height`, `bounces`, `stars`).

**Create `scripts/core/rogue_goals.gd` with exactly this code:**
```gdscript
class_name RogueGoals
extends RefCounted
## Goals for the roguelike mode. Round 1 is always a distance goal; later rounds pick a random type, and every
## target grows with the round number (there is no last round).

const TYPES: Array[String] = ["distance", "height", "zone", "bounces", "stars"]
const ZONE_WIDTH: float = 12.0
## Star goals need speed perks and a precise aim, so they only show up from this round on.
const STARS_FROM_ROUND: int = 4


static func target_for(type: String, round_number: int) -> float:
	var r := maxi(round_number, 1)
	match type:
		"distance":
			return float(roundi(40.0 * pow(1.12, r - 1)))
		"height":
			return float(roundi(8.0 * pow(1.12, r - 1)))
		"zone":
			return float(roundi(30.0 * pow(1.1, r - 1)))
		"bounces":
			return float(1 + floori(r / 4.0))
		"stars":
			return float(1 + floori(r / 10.0))
	return 0.0


static func make_goal(round_number: int, run_seed: int) -> Dictionary:
	var type := "distance"
	if round_number > 1:
		var rng := RandomNumberGenerator.new()
		rng.seed = run_seed * 7919 + round_number
		var count := TYPES.size() if round_number >= STARS_FROM_ROUND else TYPES.size() - 1
		type = TYPES[rng.randi_range(0, count - 1)]
	var target := target_for(type, round_number)
	return {"type": type, "target": target, "round": round_number, "text": describe(type, target)}


static func describe(type: String, target: float) -> String:
	var n := int(target)
	match type:
		"distance":
			return "Fly at least %d m" % n
		"height":
			return "Reach %d m high" % n
		"bounces":
			return "Bounce %d times" % n
		"stars":
			return "Collect %d star%s" % [n, "" if n == 1 else "s"]
		"zone":
			return "Stop between %d and %d m" % [n, n + int(ZONE_WIDTH)]
	return ""


static func check(goal: Dictionary, result: Dictionary) -> bool:
	var target := float(goal.get("target", 0.0))
	match str(goal.get("type", "")):
		"distance":
			return float(result.get("distance", 0.0)) >= target
		"height":
			return float(result.get("max_height", 0.0)) >= target
		"bounces":
			return int(result.get("bounces", 0)) >= int(target)
		"stars":
			return int(result.get("stars", 0)) >= int(target)
		"zone":
			var d := float(result.get("distance", 0.0))
			return d >= target and d <= target + ZONE_WIDTH
	return false
```

## Acceptance criteria
- Targets per round as in `target_for` (e.g. distance 40, 45, ... 111 m at round 10); no cap; rounds < 1 count as 1.
- `make_goal` is deterministic for the same round and seed, round 1 is distance, rounds 2-3 never have a star
  goal, and all five types appear over many rounds.
- Texts: "Fly at least 63 m", "Reach 9 m high", "Bounce 4 times", "Collect 1 star", "Collect 3 stars",
  "Stop between 44 and 56 m". The zone check includes both edges.
