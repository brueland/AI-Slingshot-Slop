---
id: 011-progress-purchases
status: ready
tests: [tests/acceptance/test_011_progress_purchases.gd]
files: [scripts/core/progress.gd]
read: [scripts/core/upgrade_catalog.gd, scripts/core/player_stats.gd]
---

# Progress: coins, levels and buying upgrades

Create `scripts/core/progress.gd`, the player's saved progress.

```gdscript
class_name Progress
extends RefCounted
## The player's saved progress: coins, upgrade levels and records. See docs/DESIGN.md section 9.

var coins: int = 0
var levels: Dictionary = {}          # upgrade id -> level (missing = 0)
var best_distance: float = 0.0
var total_runs: int = 0
var goal_reached: bool = false
```

Functions:
- `func level_of(id: String) -> int`: `int(levels.get(id, 0))`
- `func add_coins(amount: int) -> void`: adds only when `amount > 0`.
- `func next_cost(id: String) -> int`: `UpgradeCatalog.cost(id, level_of(id))` (-1 = can't buy).
- `func can_buy(id: String) -> bool`: next cost is >= 0 and `coins >= next cost`.
- `func buy(id: String) -> bool`: if `can_buy(id)`: subtract the cost, set `levels[id] = level_of(id) + 1`,
  return true. Otherwise change nothing and return false.
- `func stats() -> PlayerStats`: `PlayerStats.from_levels(levels)`

## Acceptance criteria
- With 100 coins, buying power costs 80 (20 left, level 1); the next power level costs 136 and fails.
- Unknown and maxed upgrades can't be bought; failed purchases cost nothing.
- `stats()` reflects the levels (power 1 gives max_speed 27.5).
