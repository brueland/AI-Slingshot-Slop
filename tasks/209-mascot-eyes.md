---
id: 209-mascot-eyes
status: ready
tests: [tests/acceptance/test_209_mascot_eyes.gd]
files: [scripts/ui/title_mascot.gd]
---

# The mascot watches you

The title mascot's eyes follow the mouse, and poking it makes it look surprised for a moment.

**`scripts/ui/title_mascot.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Edit 1 is in `_process()` (the eyes follow the mouse), Edit 2 in `poke()`. Each REPLACE keeps the SEARCH lines and adds one line; nothing else changes.

Edit 1 - SEARCH:
```gdscript
	time += delta
	poke_left = maxf(0.0, poke_left - delta)
```
REPLACE:
```gdscript
	time += delta
	poke_left = maxf(0.0, poke_left - delta)
	decor.set_face(decor.face, (get_local_mouse_position() - center()).limit_length(60.0) / 60.0)
```

Edit 2 - SEARCH:
```gdscript
	poke_left = 0.4
```
REPLACE:
```gdscript
	poke_left = 0.4
	decor.set_mood("wow", 0.6)
```

## Acceptance criteria
- Every frame the mascot's pupils look toward the mouse (length at most 1).
- `poke()` sets the "wow" mood for 0.6 s.
