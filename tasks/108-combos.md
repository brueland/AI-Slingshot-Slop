---
id: 108-combos
status: ready
tests: [tests/acceptance/test_108_combos.gd]
files: [scripts/game/feedback.gd]
---

# Combo popups

Lively moments (a star, a spring, a balloon pop, or a hard bounce of 8 m/s or more) within 1.2 s of each other build
a combo. From the third one a "Combo xN!" popup appears. A new shot starts without a combo.

**`scripts/game/feedback.gd`**: exactly these 7 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes. Every existing function stays.

Edit 1 - SEARCH:
```gdscript
var bounces_seen: int = 0
```
REPLACE:
```gdscript
var bounces_seen: int = 0
var combo: int = 0
var combo_left: float = 0.0

## Lively moments (stars, springs, balloons, hard bounces) this close together make a combo.
const COMBO_WINDOW: float = 1.2
```

Edit 2 - SEARCH:
```gdscript
	bounces_seen = 0
	projectile_view.set_mood("")
```
REPLACE:
```gdscript
	bounces_seen = 0
	combo = 0
	combo_left = 0.0
	projectile_view.set_mood("")
```

Edit 3 - SEARCH:
```gdscript
## Confetti and a big popup for great moments:```
REPLACE:
```gdscript
func _process(delta: float) -> void:
	tick_combo(delta)


func tick_combo(delta: float) -> void:
	if combo_left > 0.0:
		combo_left = maxf(combo_left - delta, 0.0)
		if combo_left <= 0.0:
			combo = 0


## Counts a lively moment. From the third one within COMBO_WINDOW of the last, pops up "Combo xN!".
## Returns the combo count.
func add_combo() -> int:
	combo = combo + 1 if combo_left > 0.0 else 1
	combo_left = COMBO_WINDOW
	if combo >= 3:
		var popup := FloatingText.new()
		popup.setup("Combo x%d!" % combo, Color(0.5, 1.0, 1.0))
		popup.position = projectile_view.position + Vector2(-40.0, -100.0)
		popups.add_child(popup)
	return combo


## Confetti and a big popup for great moments:```

Edit 4 - SEARCH:
```gdscript
	audio.play_sfx("star")
```
REPLACE:
```gdscript
	audio.play_sfx("star")
	add_combo()
```

Edit 5 - SEARCH:
```gdscript
	audio.play_sfx("spring")
	camera.shake(10.0, 0.35)
```
REPLACE:
```gdscript
	audio.play_sfx("spring")
	camera.shake(10.0, 0.35)
	add_combo()
```

Edit 6 - SEARCH:
```gdscript
	if impact_speed >= 8.0:
		camera.shake(4.0, 0.2)
```
REPLACE:
```gdscript
	if impact_speed >= 8.0:
		camera.shake(4.0, 0.2)
		add_combo()
```

Edit 7 - SEARCH:
```gdscript
	audio.play_sfx("spring")
	projectile_view.set_mood("wow", 0.8)
```
REPLACE:
```gdscript
	audio.play_sfx("spring")
	projectile_view.set_mood("wow", 0.8)
	add_combo()
```

## Acceptance criteria
- `add_combo()` counts up when called within `COMBO_WINDOW` (1.2 s) of the last one, else starts at 1;
  `tick_combo(delta)` ends the combo after 1.2 s without one.
- Stars, springs, balloon pops and hard bounces add to the combo; from 3 a "Combo xN!" popup appears.
- `watch()` resets the combo for every new shot.
