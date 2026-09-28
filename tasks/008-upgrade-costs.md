---
id: 008-upgrade-costs
status: ready
tests: [tests/acceptance/test_008_upgrade_costs.gd]
files: [scripts/core/upgrade_catalog.gd]
---

# Upgrade costs

Add two static functions to `scripts/core/upgrade_catalog.gd` (keep everything that is there).

```gdscript
static func cost(id: String, level: int) -> int:
	if not is_valid(id) or level < 0 or level >= max_level(id):
		return -1
	var d := get_def(id)
	return roundi(float(d["base_cost"]) * pow(float(d["growth"]), level))


static func is_maxed(id: String, level: int) -> bool:
	return level >= max_level(id)
```

`cost(id, level)` is the price of the **next** level when the upgrade is currently at `level`, so
`cost("power", 0)` = 80 (buying level 1) and `cost("power", 1)` = 136. Use `roundi` (round to nearest), not `int()`.
-1 means "can't buy": unknown id, negative level, or already at max level.

## Acceptance criteria
- power: 80, 136, 231; aero at level 3: 700; boosts at level 2: 1452 and at level 3: -1 (max).
- Every cost equals `roundi(base_cost * growth^level)` and rises with the level.
