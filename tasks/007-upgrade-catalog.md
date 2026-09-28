---
id: 007-upgrade-catalog
status: ready
tests: [tests/acceptance/test_007_upgrade_catalog.gd]
files: [scripts/core/upgrade_catalog.gd]
---

# Upgrade catalog: the 9 upgrades

Create `scripts/core/upgrade_catalog.gd` with the table of upgrades and lookup functions. Everything is
`static` or `const`; nothing needs an instance.

```gdscript
class_name UpgradeCatalog
extends RefCounted
## The 9 upgrades. See docs/DESIGN.md section 4.

const CATEGORIES: Array[String] = ["launcher", "projectile", "score"]
const CATEGORY_NAMES: Dictionary = {"launcher": "Slingshot", "projectile": "Projectile", "score": "Score"}

const UPGRADES: Dictionary = {
	"power": {"name": "Band Power", "category": "launcher", "max_level": 10, "base_cost": 80, "growth": 1.7,
		"per_level": 0.25, "description": "+25% launch speed per level"},
	...
}
```

Put the 9 entries in `UPGRADES` in exactly this order, each with the keys
`name, category, max_level, base_cost, growth, per_level, description` (description: any short text):

| id | name | category | max_level | base_cost | growth | per_level |
|---|---|---|---|---|---|---|
| power | Band Power | launcher | 10 | 80 | 1.7 | 0.25 |
| height | Tall Frame | launcher | 5 | 60 | 1.7 | 1.5 |
| guide | Aim Guide | launcher | 5 | 25 | 1.5 | 6 |
| aero | Aerodynamics | projectile | 5 | 120 | 1.8 | 0.18 |
| bounce | Bouncy Shell | projectile | 5 | 100 | 1.8 | 0.08 |
| boosts | Rocket Boosts | projectile | 3 | 300 | 2.2 | 1 |
| multiplier | Score Multiplier | score | 5 | 200 | 1.9 | 0.25 |
| star_value | Star Polish | score | 5 | 80 | 1.7 | 5 |
| bounce_bonus | Style Points | score | 5 | 60 | 1.7 | 3 |

Static functions:
- `static func ids() -> Array[String]`: the 9 ids in table order (loop over `UPGRADES` and append each key).
- `static func is_valid(id: String) -> bool`: `UPGRADES.has(id)`
- `static func get_def(id: String) -> Dictionary`: the entry, or `{}` if unknown (`UPGRADES.get(id, {})`).
- `static func max_level(id: String) -> int`: `max_level` of the entry, 0 if unknown.
- `static func ids_in_category(category: String) -> Array[String]`: ids whose category matches, in table order.

## Acceptance criteria
- The table matches exactly; unknown ids give `{}`, 0, false or an empty array.
