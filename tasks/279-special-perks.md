---
id: 279-special-perks
status: ready
tests: [tests/acceptance/test_279_special_perks.gd]
files: [scripts/core/rogue_perks.gd, scripts/core/rogue_run.gd, scripts/game/main.gd]
---

# Special perks

The special perks (task 278) join the roguelike. `RoguePerks.get_def` knows them, `apply` gives Super Ball (+0.15
bounciness) and Jet Pack (+2 rocket tanks), and `offer` can offer the found ones. A RogueRun starts with the
special perks found so far (main.gd passes `progress.found`) and adds ones found during the run; Star Magnet
(+1.5 m star reach) is applied in `stats()`.

**1. `scripts/core/rogue_perks.gd`**: exactly these 4 SEARCH/REPLACE edit(s). Edit 1 changes the last line of `get_def()`; edit 3 changes `offer()`'s signature; the others keep the SEARCH lines and add the new ones. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
static func get_def(id: String) -> Dictionary:
	for p in LIST:
		if p["id"] == id:
			return p
	return {}
```
REPLACE:
```gdscript
static func get_def(id: String) -> Dictionary:
	for p in LIST:
		if p["id"] == id:
			return p
	return SpecialStars.get_def(id)
```

Edit 2 - SEARCH:
```gdscript
			"feather":
				s.drag *= 0.6
				s.max_speed *= 0.9
```
REPLACE:
```gdscript
			"feather":
				s.drag *= 0.6
				s.max_speed *= 0.9
			"super_ball":
				s.restitution = minf(s.restitution + 0.15, MAX_RESTITUTION)
			"jet_pack":
				s.boost_charges += 2
```

Edit 3 - SEARCH:
```gdscript
static func offer(offer_seed: int, owned: Array, count: int = 3) -> Array[String]:
```
REPLACE:
```gdscript
## `specials`: the special perks found so far (see SpecialStars); they can be offered too.
static func offer(offer_seed: int, owned: Array, count: int = 3, specials: Array = []) -> Array[String]:
```

Edit 4 - SEARCH:
```gdscript
		pool.append(p["id"])
	var rng := RandomNumberGenerator.new()
```
REPLACE:
```gdscript
		pool.append(p["id"])
	for id in specials:
		pool.append(str(id))
	var rng := RandomNumberGenerator.new()
```

**2. `scripts/core/rogue_run.gd`**: exactly these 7 SEARCH/REPLACE edit(s). Edit 2 changes `start()`'s signature; edits 6 and 7 pass `specials` to the two offers; the others keep the SEARCH lines and add the new ones. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var last_path: PackedVector2Array = PackedVector2Array()
```
REPLACE:
```gdscript
var last_path: PackedVector2Array = PackedVector2Array()
## The special perks found (in earlier games and this run): they can be offered.
var specials: Array[String] = []
```

Edit 2 - SEARCH:
```gdscript
func start(new_seed: int) -> void:
```
REPLACE:
```gdscript
func start(new_seed: int, found: Array = []) -> void:
```

Edit 3 - SEARCH:
```gdscript
	last_path = PackedVector2Array()
```
REPLACE:
```gdscript
	last_path = PackedVector2Array()
	specials.clear()
	for id in found:
		if SpecialStars.is_perk(str(id)) and not specials.has(str(id)):
			specials.append(str(id))
```

Edit 4 - SEARCH:
```gdscript
	s.boss = fight
```
REPLACE:
```gdscript
	s.boss = fight
	s.pickup_radius += 1.5 * perks.count("magnet")
```

Edit 5 - SEARCH:
```gdscript
		stars_gained.append(boost)
```
REPLACE:
```gdscript
		stars_gained.append(boost)
	for id in result.get("found", []):
		if SpecialStars.is_perk(str(id)) and not specials.has(str(id)):
			specials.append(str(id))
```

Edit 6 - SEARCH:
```gdscript
		offer = RoguePerks.offer(run_seed * 100 + shots, perks)
```
REPLACE:
```gdscript
		offer = RoguePerks.offer(run_seed * 100 + shots, perks, 3, specials)
```

Edit 7 - SEARCH:
```gdscript
		offer = RoguePerks.offer(run_seed * 100 + shots + 7777 * (k + 1), perks)
```
REPLACE:
```gdscript
		offer = RoguePerks.offer(run_seed * 100 + shots + 7777 * (k + 1), perks, 3, specials)
```

**3. `scripts/game/main.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE passes `progress.found` to `rogue.start()`; nothing else in main.gd changes.

Edit 1 - SEARCH:
```gdscript
	rogue.start(run_seed if run_seed > 0 else randi_range(1, 99999))
```
REPLACE:
```gdscript
	rogue.start(run_seed if run_seed > 0 else randi_range(1, 99999), progress.found)
```

## Acceptance criteria
- Special perks are offered only once found (`RogueRun.specials`), from earlier games or this run.
- Super Ball, Jet Pack and Star Magnet work as described.
