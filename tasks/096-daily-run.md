---
id: 096-daily-run
status: ready
tests: [tests/acceptance/test_096_daily_run.gd]
files: [scripts/core/daily.gd, scripts/core/progress.gd]
---

# Daily Run (part 1: seed and saving)

The Daily Run is a roguelike run whose seed is the date, so everyone gets the same goals, courses and perk offers
that day. This task adds the seed/key helpers and saves the best rounds per day (last 30 days). Task 096b adds the
title button and the run-over line. Only these two files change; use small SEARCH/REPLACE edits.

**1. Create the file `scripts/core/daily.gd` with exactly this code** (use that exact path as the edit's file name):
```gdscript
class_name Daily
extends RefCounted
## The daily roguelike run: the same seed (so the same goals, courses and perk offers) for everyone on a day.

const KEEP_DAYS: int = 30


## "2026-09-29" for a date Dictionary with year, month and day (like Time.get_date_dict_from_system()).
static func key_for(date: Dictionary) -> String:
	return "%04d-%02d-%02d" % [int(date.get("year", 2000)), int(date.get("month", 1)), int(date.get("day", 1))]


## 20260929 for 2026-09-29.
static func seed_for(date: Dictionary) -> int:
	return int(date.get("year", 2000)) * 10000 + int(date.get("month", 1)) * 100 + int(date.get("day", 1))


static func today() -> Dictionary:
	return Time.get_date_dict_from_system()


## Records a daily result (keeps the best per day and only the newest KEEP_DAYS days).
static func record(bests: Dictionary, key: String, rounds: int) -> void:
	bests[key] = maxi(int(bests.get(key, 0)), rounds)
	var keys := bests.keys()
	keys.sort()
	while keys.size() > KEEP_DAYS:
		bests.erase(keys.pop_front())
```

**2. `scripts/core/progress.gd`** (three small edits; without the first one every test fails with
`Invalid assignment of property or key 'daily_best'`):
- **Declare the variable** at the top of the class, on the line right after `var best_path: Array = []`:
  ```gdscript
  var daily_best: Dictionary = {}
  ```
- In `to_dict()`, add this entry to the returned Dictionary (after the `"best_path"` entry):
  ```gdscript
  		"daily_best": daily_best.duplicate(),
  ```
- In `from_dict()`, right before the line `var hat_id := str(data.get("hat", "none"))`:
```gdscript
	var daily_data = data.get("daily_best")
	if typeof(daily_data) == TYPE_DICTIONARY:
		for key in daily_data:
			Daily.record(p.daily_best, str(key), maxi(0, int(daily_data[key])))
```

## Acceptance criteria
- `Daily.key_for` gives "2026-09-29", `seed_for` gives 20260929; `record` keeps the best per day, 30 days.
- `Progress.daily_best` is saved and loaded (days as keys, rounds as ints); old saves have none.
