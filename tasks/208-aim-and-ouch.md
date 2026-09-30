---
id: 208-aim-and-ouch
status: ready
tests: [tests/acceptance/test_208_aim_and_ouch.gd]
files: [scripts/game/main.gd, scripts/game/feedback.gd]
---

# Focus and ouch

While the slingshot is pulled the alien concentrates ("focus"), looking where it will fly; a hard bounce makes it
wince ("ouch").

**1. `scripts/game/main.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Both edits are in `_update_aim()`; each REPLACE keeps the SEARCH lines and adds one line. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
	if not slingshot.dragging:
		trajectory.clear()
		return
```
REPLACE:
```gdscript
	if not slingshot.dragging:
		trajectory.clear()
		projectile_view.decor.set_face("happy", Vector2(0.5, 0.0))
		return
```

Edit 2 - SEARCH:
```gdscript
	projectile_view.position = slingshot.pouch_position() + Vector2(0, -12)
```
REPLACE:
```gdscript
	projectile_view.position = slingshot.pouch_position() + Vector2(0, -12)
	projectile_view.decor.set_face("focus", -slingshot.pull.normalized())
```

**2. `scripts/game/feedback.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The edit is in `_on_bounced()`; the REPLACE keeps the SEARCH lines and adds two lines inside the same `if`. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
	if impact_speed >= 8.0:
		add_combo()
```
REPLACE:
```gdscript
	if impact_speed >= 8.0:
		add_combo()
		if projectile_view != null:
			projectile_view.ouch()
```

## Acceptance criteria
- `_update_aim` shows "focus" (looking along `-slingshot.pull`) while dragging and "happy" otherwise.
- `Feedback._on_bounced` calls `projectile_view.ouch()` for impacts of 8 m/s or more.
