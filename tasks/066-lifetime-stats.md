---
id: 066-lifetime-stats
status: ready
tests: [tests/acceptance/test_066_lifetime_stats.gd]
files: [scripts/core/progress.gd, scripts/game/main.gd]
---

# Lifetime stats and recent runs

**1. `scripts/core/progress.gd`** (keep everything):
```gdscript
var lifetime: Dictionary = {"distance": 0.0, "stars": 0, "bounces": 0, "best_height": 0.0}
var recent_distances: Array[float] = []

const RECENT_RUNS: int = 10


## Adds a finished run's numbers to the lifetime totals and the recent-distance list.
func record_lifetime(result: Dictionary) -> void:
	lifetime["distance"] = float(lifetime["distance"]) + maxf(0.0, float(result.get("distance", 0.0)))
	lifetime["stars"] = int(lifetime["stars"]) + int(result.get("stars", 0))
	lifetime["bounces"] = int(lifetime["bounces"]) + int(result.get("bounces", 0))
	lifetime["best_height"] = maxf(float(lifetime["best_height"]), float(result.get("max_height", 0.0)))
	recent_distances.append(float(result.get("distance", 0.0)))
	while recent_distances.size() > RECENT_RUNS:
		recent_distances.pop_front()
```
- `to_dict()` also returns `"lifetime": lifetime.duplicate()` and `"recent_distances": recent_distances.duplicate()`.
- `from_dict()` (before `return p`): if `data.get("lifetime")` is a Dictionary, read `distance` and `best_height`
  as `maxf(0.0, float(...))` and `stars` and `bounces` as `maxi(0, int(...))` (missing keys = 0); if
  `data.get("recent_distances")` is an Array, append `float(value)` for each and then drop the oldest until at most
  `RECENT_RUNS` remain. Old saves without these keys keep the zero defaults.

**2. `scripts/game/main.gd`:** in `_finish_run()`, right after the `record_run(...)` line (before saving):
`progress.record_lifetime(last_result)`.

## Acceptance criteria
- Totals add up, best height is a maximum, the recent list keeps the newest 10 in order.
- Everything survives to_dict -> JSON -> from_dict (ints stay ints); bad or old saves are repaired.
- Every finished run in main is recorded and saved.
