---
id: 287-bonk
status: ready
tests: [tests/acceptance/test_287_bonk.gd]
files: [scripts/game/feedback.gd]
---

# Bonk!

Hitting the brick wall (task 285) gets a reaction: Feedback connects the sim's `wall_hit` and says "Bonk!", plays the
bounce sound, shakes the camera and makes the ouch face.

**1. `scripts/game/feedback.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Edit 1 adds one line in `watch()`; edit 2 adds `_on_wall_hit()` at the end of the file. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
		session.sim.boosted.connect(_on_boosted)
```
REPLACE:
```gdscript
		session.sim.boosted.connect(_on_boosted)
		session.sim.wall_hit.connect(_on_wall_hit)
```

Edit 2 - SEARCH:
```gdscript
		camera.shake(5.0, 0.2)
	if audio != null:
		audio.play_sfx("spring")
	add_combo()
```
REPLACE:
```gdscript
		camera.shake(5.0, 0.2)
	if audio != null:
		audio.play_sfx("spring")
	add_combo()


## The alien hit the brick wall behind the slingshot: "Bonk!", a thud and a shake.
func _on_wall_hit() -> void:
	_say("Bonk!", Color(1.0, 0.5, 0.4))
	if audio != null:
		audio.play_sfx("bounce")
	if camera != null:
		camera.shake(6.0, 0.25)
	if projectile_view != null:
		projectile_view.set_mood("ouch", 0.8)
```

## Acceptance criteria
- `wall_hit` makes a "Bonk!" popup, the "bounce" sound, a shake and the ouch face.
