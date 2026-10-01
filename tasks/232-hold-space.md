---
id: 232-hold-space
status: ready
tests: [tests/acceptance/test_232_hold_space.gd]
files: [scripts/game/main.gd, scripts/ui/help_panel.gd]
---

# Space fires the rocket while held

The rocket now burns while the boost key is held (task 231). main.gd already starts it when Space goes down; it
must also stop it when Space comes up. How to play says to hold Space.

**1. `scripts/game/main.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds two lines in `_unhandled_input()`; nothing else in main.gd changes (it must stay under 450 lines).

Edit 1 - SEARCH:
```gdscript
	if event.is_action_pressed("boost"):
		if request_boost():
			get_viewport().set_input_as_handled()
```
REPLACE:
```gdscript
	if event.is_action_pressed("boost"):
		if request_boost():
			get_viewport().set_input_as_handled()
	elif event.is_action_released("boost") and session != null:
		session.release_boost()
```

**2. `scripts/ui/help_panel.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE changes that one line of `LINES`; nothing else changes.

Edit 1 - SEARCH:
```gdscript
	"Press Space in the air to use a boost.",
```
REPLACE:
```gdscript
	"Hold Space in the air to fire the rocket: the longer you hold it, the more push.",
```

## Acceptance criteria
- Releasing Space in flight stops the rocket; pressing it again restarts it while there is fuel.
- A release before the first shot does nothing.
- How to play says "Hold Space".
