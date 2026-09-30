---
id: 207-face-picking
status: ready
tests: [tests/acceptance/test_207_face_picking.gd]
files: [scripts/game/alien_face.gd, scripts/game/projectile_view.gd]
---

# Faces in flight

In flight the alien picks its face from how it flies (wee when zooming, scared when falling fast, happy otherwise)
and looks where it is going; a hard bounce makes it wince.

**1. `scripts/game/alien_face.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE keeps the SEARCH line and adds two constants and two functions after it; nothing else changes.

Edit 1 - SEARCH:
```gdscript
const EYE_R := Vector2(4.4, -2.4)
```
REPLACE:
```gdscript
const EYE_R := Vector2(4.4, -2.4)
## Falling faster than this (m/s) looks scary; flying faster than WEE_SPEED is fun.
const SCARED_FALL_SPEED: float = 14.0
const WEE_SPEED: float = 16.0


## Which face the alien makes in flight: a hard bounce (ouch_left > 0) first, then falling fast (scared),
## flying fast (wee), and happy otherwise (also while rolling on the ground).
static func pick(velocity: Vector2, airborne: bool, ouch_left: float) -> String:
	if ouch_left > 0.0:
		return "ouch"
	if airborne and velocity.y < -SCARED_FALL_SPEED:
		return "scared"
	if airborne and velocity.length() > WEE_SPEED:
		return "wee"
	return "happy"


## Where the pupils look: along the flight (the sim's y is up, the screen's is down), or ahead when still.
static func look_for(velocity: Vector2) -> Vector2:
	if velocity.length() < 1.0:
		return Vector2(0.5, 0.0)
	return Vector2(velocity.x, -velocity.y).normalized()
```

**2. `scripts/game/projectile_view.gd`**: exactly these 4 SEARCH/REPLACE edit(s). Edits 1-3 keep their SEARCH lines and add new ones; Edit 4 adds a function above the wobble comment and keeps it. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var size_scale: float = 1.0
```
REPLACE:
```gdscript
var size_scale: float = 1.0
## Seconds left of the "ouch" face after a hard bounce.
var ouch_left: float = 0.0
```

Edit 2 - SEARCH:
```gdscript
	advance_wobble(delta)
	_sync_decor()
```
REPLACE:
```gdscript
	advance_wobble(delta)
	_sync_decor()
	ouch_left = maxf(0.0, ouch_left - delta)
```

Edit 3 - SEARCH:
```gdscript
	rotation = sim.position.x / Balance.PROJECTILE_RADIUS
```
REPLACE:
```gdscript
	rotation = sim.position.x / Balance.PROJECTILE_RADIUS
	var airborne := sim.is_airborne() and not sim.stopped
	decor.set_face(AlienFace.pick(sim.velocity, airborne, ouch_left), AlienFace.look_for(sim.velocity))
```

Edit 4 - SEARCH:
```gdscript
## Jelly wobble after a bounce: the alien squashes and stretches for WOBBLE_SECONDS, then is round again.
```
REPLACE:
```gdscript
## A hard bounce: the alien winces (the "ouch" face) for 0.35 s.
func ouch() -> void:
	ouch_left = 0.35
	decor.set_face("ouch", decor.look)


## Jelly wobble after a bounce: the alien squashes and stretches for WOBBLE_SECONDS, then is round again.
```

## Acceptance criteria
- `AlienFace.pick(velocity, airborne, ouch_left)` and `AlienFace.look_for(velocity)`.
- `ProjectileView.sync_from` sets the face every frame; `ouch()` shows "ouch" for 0.35 s (`ouch_left`).
