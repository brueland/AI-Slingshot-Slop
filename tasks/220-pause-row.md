---
id: 220-pause-row
status: ready
tests: [tests/acceptance/test_220_pause_row.gd]
files: [scripts/ui/pause_menu.gd]
---

# Pause menu in a row

With the bigger font the pause menu grew into the options panel. Its buttons now sit in one row near the bottom.

**`scripts/ui/pause_menu.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE lowers the menu (96 px above the bottom instead of 140) and lays its buttons out in a row (HBoxContainer instead of VBoxContainer). Nothing else changes.

Edit 1 - SEARCH:
```gdscript
	offset_top -= 140.0
	offset_bottom -= 140.0
	var box := VBoxContainer.new()
```
REPLACE:
```gdscript
	offset_top -= 96.0
	offset_bottom -= 96.0
	var box := HBoxContainer.new()
```

## Acceptance criteria
- The pause menu's buttons are in an HBoxContainer, 96 px above the bottom: clear of the Paused text, the options panel, the course bar and the Menu button.
