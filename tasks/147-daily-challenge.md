---
id: 147-daily-challenge
status: ready
tests: [tests/acceptance/test_147_daily_challenge.gd]
files: [scripts/core/daily.gd, scripts/core/progress.gd, scripts/game/main.gd]
---

# Classic daily challenge

A classic daily challenge: fly `Daily.challenge_distance(today)` (150-450 m, the same for everyone that day) to get
a "Daily challenge done!" toast, once a day.

**1. `scripts/core/daily.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
static func today() -> Dictionary:
```
REPLACE:
```gdscript
## Today's classic challenge: fly this far (150-450 m, the same for everyone on that day).
static func challenge_distance(date: Dictionary) -> float:
	return 150.0 + posmod(seed_for(date), 7) * 50.0


static func today() -> Dictionary:
```

**2. `scripts/core/progress.gd`**: exactly these 4 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var shake_on: bool = true
```
REPLACE:
```gdscript
var shake_on: bool = true
## The day ("2026-09-30") the classic daily challenge was last done.
var challenge_day: String = ""
```

Edit 2 - SEARCH:
```gdscript
		"shake_on": shake_on,
```
REPLACE:
```gdscript
		"shake_on": shake_on,
		"challenge_day": challenge_day,
```

Edit 3 - SEARCH:
```gdscript
	p.shake_on = bool(data.get("shake_on", true))
```
REPLACE:
```gdscript
	p.shake_on = bool(data.get("shake_on", true))
	p.challenge_day = str(data.get("challenge_day", ""))
```

Edit 4 - SEARCH:
```gdscript
func level_of(id: String) -> int:
```
REPLACE:
```gdscript
## Marks the daily challenge of `date` done when `distance` reaches it (once a day). Returns true when it just got done.
func try_challenge(distance: float, date: Dictionary) -> bool:
	var key := Daily.key_for(date)
	if challenge_day == key or distance < Daily.challenge_distance(date):
		return false
	challenge_day = key
	return true


func level_of(id: String) -> int:
```

**3. `scripts/game/main.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	progress.record_lifetime(last_result)
```
REPLACE:
```gdscript
	progress.record_lifetime(last_result)
	if progress.try_challenge(last_result["distance"], Daily.today()):
		toast.enqueue("Daily challenge done!", "Come back tomorrow for a new one")
```

## Acceptance criteria
- `challenge_distance` is 150 + (seed % 7) * 50 m; `Progress.try_challenge(distance, date)` is true once per day when reached.
- A classic run that reaches it toasts "Daily challenge done!" and saves the day.
