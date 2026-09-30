---
id: 121-boing-splat
status: ready
tests: [tests/acceptance/test_121_boing_splat.gd]
files: [scripts/game/feedback.gd]
---

# Boing! and Splat!

Milestone 14 adds juice. Springs say "Boing!" and mud says "Splat!" with a spray of mud.

**`scripts/game/feedback.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes. Every existing function stays.

Edit 1 - SEARCH:
```gdscript
		session.tracker.spring_hit.connect(_on_spring_hit)
```
REPLACE:
```gdscript
		session.tracker.spring_hit.connect(_on_spring_hit)
		session.tracker.mud_hit.connect(_on_mud_hit)
```

Edit 2 - SEARCH:
```gdscript
		if effects != null:
			effects.spawn_burst(course_view.sprites[index].position)
```
REPLACE:
```gdscript
		if effects != null:
			effects.spawn_burst(course_view.sprites[index].position)
	_say("Boing!", Color(0.6, 1.0, 0.6))
```

Edit 3 - SEARCH:
```gdscript
func _on_balloon_popped(index: int) -> void:
```
REPLACE:
```gdscript
## A short popup above the alien.
func _say(text: String, color: Color) -> void:
	if popups == null or projectile_view == null:
		return
	var popup := FloatingText.new()
	popup.setup(text, color)
	popup.position = projectile_view.position + Vector2(-24.0, -56.0)
	popups.add_child(popup)


func _on_mud_hit(_index: int) -> void:
	_say("Splat!", Color(0.6, 0.45, 0.3))
	if effects != null and projectile_view != null:
		effects.spawn_dust(projectile_view.position + Vector2(0, 12), 20.0)


func _on_balloon_popped(index: int) -> void:
```

## Acceptance criteria
- A spring hit pops up "Boing!"; a mud hit pops up "Splat!" and spawns one dust effect.
