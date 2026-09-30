---
id: 125-hat-celebration
status: ready
tests: [tests/acceptance/test_125_hat_celebration.gd]
files: [scripts/game/feedback.gd]
---

# Celebrate new hats

A run that unlocks a hat, with nothing bigger to celebrate, throws confetti with "New hat!".

**`scripts/game/feedback.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	elif bool(result.get("goal_met", false)):
		text = "Goal!"
```
REPLACE:
```gdscript
	elif bool(result.get("goal_met", false)):
		text = "Goal!"
	elif not (result.get("new_hats", []) as Array).is_empty():
		text = "New hat!"
```

## Acceptance criteria
- `celebrate({"new_hats": ["chef"]})` returns "New hat!"; a new best, milestone or goal still comes first.
