---
id: 309-wall-breaker
status: ready
tests: [tests/acceptance/test_309_wall_breaker.gd, tests/acceptance/test_069_achievements.gd]
files: [scripts/core/achievements.gd]
---

# Wall Breaker

Finding the secret gets an achievement: "Wall Breaker" (Find the secret behind the brick wall), earned by a run
whose result found "secret_wall". Older test 069 now expects 7 achievements.

**1. `scripts/core/achievements.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Edit 1 adds an entry at the end of LIST; edit 2 adds a case in `is_earned()`'s match. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
	{"id": "big_spender", "name": "Big Spender", "description": "Own 10 upgrade levels"},
```
REPLACE:
```gdscript
	{"id": "big_spender", "name": "Big Spender", "description": "Own 10 upgrade levels"},
	{"id": "wall_breaker", "name": "Wall Breaker", "description": "Find the secret behind the brick wall"},
```

Edit 2 - SEARCH:
```gdscript
			return owned >= 10
```
REPLACE:
```gdscript
			return owned >= 10
		"wall_breaker":
			return Array(result.get("found", [])).has("secret_wall")
```

## Acceptance criteria
- `Achievements.LIST` ends with wall_breaker; it is earned when `result["found"]` has "secret_wall".
