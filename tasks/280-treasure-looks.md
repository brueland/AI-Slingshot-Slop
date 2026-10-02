---
id: 280-treasure-looks
status: ready
tests: [tests/acceptance/test_280_treasure_looks.gd]
files: [scripts/game/course_view.gd, scripts/game/feedback.gd, scripts/ui/perk_chips.gd]
---

# How treasures look

The treasures get noticed: special stars are drawn bigger and purple, finding one (or a balloon hat) pops up
"Star Magnet found!" / "Cowboy Hat found!" (Feedback keeps the watched shot), and the special perks get their own
colors in the HUD's perk boxes.

**1. `scripts/game/course_view.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds three lines in `build()`'s star case; nothing else changes.

Edit 1 - SEARCH:
```gdscript
			star_indices.append(i)
```
REPLACE:
```gdscript
			star_indices.append(i)
			if item.has("special"):
				sprite.modulate = Color(0.85, 0.45, 1.0)
				sprite.scale = Vector2(0.75, 0.75)
```

**2. `scripts/game/feedback.gd`**: exactly these 4 SEARCH/REPLACE edit(s). Edits 2-4 add lines at the start of `watch()`, `_on_star_collected()` and `_on_balloon_popped()`; nothing else changes.

Edit 1 - SEARCH:
```gdscript
var balloon_view: BalloonView
```
REPLACE:
```gdscript
var balloon_view: BalloonView
## The shot being watched (its course and balloons say what was found).
var shot: RunSession
```

Edit 2 - SEARCH:
```gdscript
func watch(session: RunSession) -> void:
```
REPLACE:
```gdscript
func watch(session: RunSession) -> void:
	shot = session
```

Edit 3 - SEARCH:
```gdscript
func _on_star_collected(index: int) -> void:
```
REPLACE:
```gdscript
func _on_star_collected(index: int) -> void:
	if shot != null and index < shot.course.size() and shot.course[index].has("special"):
		_say("%s found!" % SpecialStars.get_def(str(shot.course[index]["special"])).get("name", ""), Color(0.85, 0.5, 1.0))
```

Edit 4 - SEARCH:
```gdscript
func _on_balloon_popped(index: int) -> void:
```
REPLACE:
```gdscript
func _on_balloon_popped(index: int) -> void:
	if shot != null and index < shot.balloons.hats.size() and shot.balloons.hats[index] != "":
		_say("%s found!" % Hats.get_def(shot.balloons.hats[index]).get("name", ""), Color(1.0, 0.8, 0.3))
```

**3. `scripts/ui/perk_chips.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds one line of colors to COLORS; nothing else changes.

Edit 1 - SEARCH:
```gdscript
	"feather": Color(0.34, 0.42, 0.78), "steady": Color(0.52, 0.33, 0.72),
}
```
REPLACE:
```gdscript
	"feather": Color(0.34, 0.42, 0.78), "steady": Color(0.52, 0.33, 0.72),
	"magnet": Color(0.6, 0.28, 0.78), "super_ball": Color(0.82, 0.3, 0.55), "jet_pack": Color(0.3, 0.32, 0.72),
}
```

## Acceptance criteria
- Special stars: modulate (0.85, 0.45, 1.0) and scale 0.75; a "<name> found!" popup for special stars and hat balloons.
- PerkChips.COLORS has the three special perks.
