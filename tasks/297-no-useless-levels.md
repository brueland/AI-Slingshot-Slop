---
id: 297-no-useless-levels
status: ready
tests: [tests/acceptance/test_297_no_useless_levels.gd, tests/acceptance/test_007_upgrade_catalog.gd, tests/acceptance/test_272_uncapped_upgrades.gd]
files: [scripts/core/upgrade_catalog.gd]
---

# No useless upgrade levels

Since task 272 every upgrade went to level 25, but two of them stop doing anything long before that. Aim Guide adds
6 preview dots per level, and at level 12 (78 dots) every aim's dots already reach the edge of the screen; Bouncy
Shell's bounciness reaches its 0.9 cap at level 8. Those two now stop there (MAX in the shop); saves with higher
levels are capped when loaded. Two older tests are updated.

**1. `scripts/core/upgrade_catalog.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Edit 1 changes the comment; edits 2 and 3 change one `max_level` each. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
## Every upgrade goes to level 25: prices keep growing, so in practice there is always a next level.
```
REPLACE:
```gdscript
## Upgrades go to level 25 (prices keep growing, so in practice there is always a next level), except Aim Guide
## (12: more dots would be off the screen) and Bouncy Shell (8: bounciness stops at 0.9 there).
```

Edit 2 - SEARCH:
```gdscript
	"guide": {"name": "Aim Guide", "category": "launcher", "max_level": 25, "base_cost": 25, "growth": 1.5,
```
REPLACE:
```gdscript
	"guide": {"name": "Aim Guide", "category": "launcher", "max_level": 12, "base_cost": 25, "growth": 1.5,
```

Edit 3 - SEARCH:
```gdscript
	"bounce": {"name": "Bouncy Shell", "category": "projectile", "max_level": 25, "base_cost": 100, "growth": 1.8,
```
REPLACE:
```gdscript
	"bounce": {"name": "Bouncy Shell", "category": "projectile", "max_level": 8, "base_cost": 100, "growth": 1.8,
```

## Acceptance criteria
- `max_level` is 12 for guide and 8 for bounce; every other upgrade stays at 25.
