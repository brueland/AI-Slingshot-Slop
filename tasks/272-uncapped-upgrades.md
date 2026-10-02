---
id: 272-uncapped-upgrades
status: ready
tests: [tests/acceptance/test_272_uncapped_upgrades.gd, tests/acceptance/test_007_upgrade_catalog.gd, tests/acceptance/test_008_upgrade_costs.gd, tests/acceptance/test_009_player_stats.gd, tests/acceptance/test_011_progress_purchases.gd, tests/acceptance/test_033_shop_rows.gd, tests/acceptance/test_014_progress_dict.gd, tests/acceptance/test_035_main_ui.gd]
files: [scripts/core/upgrade_catalog.gd, scripts/core/player_stats.gd, scripts/ui/shop_panel.gd]
---

# Upgrades without a cap

Milestone 38 takes the caps off classic mode. Upgrades stopped at 3 to 10 levels; now every upgrade goes to level 25
(prices keep growing, so in practice there is always a next level). Past their old 5 levels, drag keeps dropping
10% per level and bounciness rises 0.02 per level (never past 0.9), so nothing breaks. The shop shows the level
without a maximum ("Lv 7"). Seven older tests are updated for the new limits.

**1. `scripts/core/upgrade_catalog.gd`**: exactly these 10 SEARCH/REPLACE edit(s). Edit 1 adds a comment; edits 2-10 change `max_level` to 25 in one line each. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
const UPGRADES: Dictionary = {
```
REPLACE:
```gdscript
## Every upgrade goes to level 25: prices keep growing, so in practice there is always a next level.
const UPGRADES: Dictionary = {
```

Edit 2 - SEARCH:
```gdscript
	"power": {"name": "Band Power", "category": "launcher", "max_level": 10, "base_cost": 80, "growth": 1.7,
```
REPLACE:
```gdscript
	"power": {"name": "Band Power", "category": "launcher", "max_level": 25, "base_cost": 80, "growth": 1.7,
```

Edit 3 - SEARCH:
```gdscript
	"height": {"name": "Tall Frame", "category": "launcher", "max_level": 5, "base_cost": 60, "growth": 1.7,
```
REPLACE:
```gdscript
	"height": {"name": "Tall Frame", "category": "launcher", "max_level": 25, "base_cost": 60, "growth": 1.7,
```

Edit 4 - SEARCH:
```gdscript
	"guide": {"name": "Aim Guide", "category": "launcher", "max_level": 5, "base_cost": 25, "growth": 1.5,
```
REPLACE:
```gdscript
	"guide": {"name": "Aim Guide", "category": "launcher", "max_level": 25, "base_cost": 25, "growth": 1.5,
```

Edit 5 - SEARCH:
```gdscript
	"aero": {"name": "Aerodynamics", "category": "projectile", "max_level": 5, "base_cost": 120, "growth": 1.8,
```
REPLACE:
```gdscript
	"aero": {"name": "Aerodynamics", "category": "projectile", "max_level": 25, "base_cost": 120, "growth": 1.8,
```

Edit 6 - SEARCH:
```gdscript
	"bounce": {"name": "Bouncy Shell", "category": "projectile", "max_level": 5, "base_cost": 100, "growth": 1.8,
```
REPLACE:
```gdscript
	"bounce": {"name": "Bouncy Shell", "category": "projectile", "max_level": 25, "base_cost": 100, "growth": 1.8,
```

Edit 7 - SEARCH:
```gdscript
	"multiplier": {"name": "Score Multiplier", "category": "score", "max_level": 5, "base_cost": 200, "growth": 1.9,
```
REPLACE:
```gdscript
	"multiplier": {"name": "Score Multiplier", "category": "score", "max_level": 25, "base_cost": 200, "growth": 1.9,
```

Edit 8 - SEARCH:
```gdscript
	"star_value": {"name": "Star Polish", "category": "score", "max_level": 5, "base_cost": 80, "growth": 1.7,
```
REPLACE:
```gdscript
	"star_value": {"name": "Star Polish", "category": "score", "max_level": 25, "base_cost": 80, "growth": 1.7,
```

Edit 9 - SEARCH:
```gdscript
	"bounce_bonus": {"name": "Style Points", "category": "score", "max_level": 5, "base_cost": 60, "growth": 1.7,
```
REPLACE:
```gdscript
	"bounce_bonus": {"name": "Style Points", "category": "score", "max_level": 25, "base_cost": 60, "growth": 1.7,
```

Edit 10 - SEARCH:
```gdscript
	"boosts": {"name": "Rocket Boosts", "category": "projectile", "max_level": 3, "base_cost": 300, "growth": 2.2,
```
REPLACE:
```gdscript
	"boosts": {"name": "Rocket Boosts", "category": "projectile", "max_level": 25, "base_cost": 300, "growth": 2.2,
```

**2. `scripts/core/player_stats.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Each REPLACE changes how one stat is computed in `from_levels()`; nothing else changes.

Edit 1 - SEARCH:
```gdscript
	ps.drag = Balance.BASE_DRAG * (1.0 - 0.18 * _level(levels, "aero"))
```
REPLACE:
```gdscript
	# past their first 5 levels, drag and bounciness keep improving but more slowly (bounciness never past 0.9)
	var aero := _level(levels, "aero")
	ps.drag = Balance.BASE_DRAG * (1.0 - 0.18 * mini(aero, 5)) * pow(0.9, maxi(aero - 5, 0))
```

Edit 2 - SEARCH:
```gdscript
	ps.restitution = Balance.BASE_RESTITUTION + 0.08 * _level(levels, "bounce")
```
REPLACE:
```gdscript
	var bounce := _level(levels, "bounce")
	ps.restitution = minf(Balance.BASE_RESTITUTION + 0.08 * mini(bounce, 5) + 0.02 * maxi(bounce - 5, 0), RoguePerks.MAX_RESTITUTION)
```

**3. `scripts/ui/shop_panel.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Each REPLACE drops the maximum from one row text; nothing else changes.

Edit 1 - SEARCH:
```gdscript
			buttons[id].text = "%s  Lv %d/%d  MAX" % [d["name"], level, int(d["max_level"])]
```
REPLACE:
```gdscript
			buttons[id].text = "%s  Lv %d  MAX" % [d["name"], level]
```

Edit 2 - SEARCH:
```gdscript
			buttons[id].text = "%s  Lv %d/%d  %d coins" % [d["name"], level, int(d["max_level"]), cost]
```
REPLACE:
```gdscript
			buttons[id].text = "%s  Lv %d  %d coins" % [d["name"], level, cost]
```

## Acceptance criteria
- Every upgrade's `max_level` is 25; drag uses `(1 - 0.18 * min(L, 5)) * 0.9^max(L - 5, 0)`, bounciness `+0.08 * min(L, 5) + 0.02 * max(L - 5, 0)` capped at 0.9.
- Shop rows read "Band Power  Lv 1  136 coins" and "... Lv 25  MAX".
