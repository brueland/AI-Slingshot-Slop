---
id: 152-hat-trail
status: ready
tests: [tests/acceptance/test_152_hat_trail.gd]
files: [scripts/game/trail.gd, scripts/game/main.gd]
---

# Hat trails

Milestone 18 adds final polish. The trail's colors follow the hat: rainbow for the party hat, purple for the
wizard hat, gold for the crown, white otherwise.

**1. `scripts/game/trail.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
const MAX_POINTS: int = 30
```
REPLACE:
```gdscript
const MAX_POINTS: int = 30

var style: String = "none"
```

Edit 2 - SEARCH:
```gdscript
func clear_trail() -> void:
```
REPLACE:
```gdscript
## The trail's colors follow the hat: rainbow (party hat), purple (wizard hat), gold (crown), white otherwise.
func set_style(hat_id: String) -> void:
	style = hat_id
	var fade := Gradient.new()
	match hat_id:
		"party":
			fade.set_color(0, Color(1.0, 0.3, 0.3, 0.0))
			fade.set_color(1, Color(0.7, 0.4, 1.0, 0.8))
			fade.add_point(0.33, Color(1.0, 0.85, 0.2, 0.4))
			fade.add_point(0.66, Color(0.3, 0.8, 1.0, 0.6))
		"wizard":
			fade.set_color(0, Color(0.7, 0.4, 1.0, 0.0))
			fade.set_color(1, Color(0.7, 0.4, 1.0, 0.8))
		"crown":
			fade.set_color(0, Color(1.0, 0.85, 0.3, 0.0))
			fade.set_color(1, Color(1.0, 0.85, 0.3, 0.8))
		_:
			fade.set_color(0, Color(1, 1, 1, 0.0))
			fade.set_color(1, Color(1, 1, 1, 0.7))
	gradient = fade


func clear_trail() -> void:
```

**2. `scripts/game/main.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	trail.clear_trail()
```
REPLACE:
```gdscript
	trail.clear_trail()
	trail.set_style(progress.hat)
```

## Acceptance criteria
- `Trail.set_style(hat)` sets the gradient (4 colors for the party hat); every shot uses `progress.hat`.
