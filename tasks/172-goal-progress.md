---
id: 172-goal-progress
status: ready
tests: [tests/acceptance/test_172_goal_progress.gd]
files: [scripts/core/rogue_goals.gd]
---

# How close to the goal

Milestone 21 makes roguelike goals easier to read. First, two helpers in RogueGoals: how close a shot came to a
goal (0 to 1) and a short live readout like "34/50 m".

**`scripts/core/rogue_goals.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds three functions above `describe()` and keeps `describe()`'s first line; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
static func describe(type: String, target: float) -> String:
```
REPLACE:
```gdscript
## How close `result` came to `goal`: 0.0 (nowhere) to 1.0 (met). A boss goal counts its weakest part.
static func progress_ratio(goal: Dictionary, result: Dictionary) -> float:
	var target := float(goal.get("target", 0.0))
	match str(goal.get("type", "")):
		"distance":
			return _ratio(float(result.get("distance", 0.0)), target)
		"height":
			return _ratio(float(result.get("max_height", 0.0)), target)
		"bounces":
			return _ratio(float(result.get("bounces", 0)), target)
		"stars":
			return _ratio(float(result.get("stars", 0)), target)
		"zone":
			if check(goal, result):
				return 1.0
			var d := float(result.get("distance", 0.0))
			if d > target:
				return clampf((target + ZONE_WIDTH) / d, 0.0, 0.99)
			return _ratio(d, target)
		"boss":
			var parts: Array = goal.get("parts", [])
			var lowest := 0.0 if parts.is_empty() else 1.0
			for part in parts:
				lowest = minf(lowest, progress_ratio(part, result))
			return lowest
	return 0.0


static func _ratio(value: float, target: float) -> float:
	if target <= 0.0:
		return 1.0
	return clampf(value / target, 0.0, 1.0)


## The live goal readout for the HUD, like "34/50 m" or "2/3 bounces". A boss goal joins its parts with "  +  ".
static func progress_text(goal: Dictionary, result: Dictionary) -> String:
	var n := int(float(goal.get("target", 0.0)))
	match str(goal.get("type", "")):
		"distance":
			return "%d/%d m" % [int(float(result.get("distance", 0.0))), n]
		"height":
			return "%d/%d m high" % [int(float(result.get("max_height", 0.0))), n]
		"bounces":
			return "%d/%d bounces" % [int(result.get("bounces", 0)), n]
		"stars":
			return "%d/%d stars" % [int(result.get("stars", 0)), n]
		"zone":
			return "%d m (stop at %d-%d m)" % [int(float(result.get("distance", 0.0))), n, n + int(ZONE_WIDTH)]
		"boss":
			var texts := PackedStringArray()
			for part in goal.get("parts", []):
				texts.append(progress_text(part, result))
			return "  +  ".join(texts)
	return ""


static func describe(type: String, target: float) -> String:
```

## Acceptance criteria
- `progress_ratio(goal, result)` is 0-1 for every goal type; a zone overshoot counts too; a boss goal uses its weakest part.
- `progress_text(goal, result)` reads like `34/50 m`, `5/20 m high`, `3/4 bounces`, `0/2 stars`, `45 m (stop at 40-52 m)`.
