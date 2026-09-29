---
id: 098-pause-menu
status: ready
tests: [tests/acceptance/test_098_pause_menu.gd]
files: [scripts/ui/pause_menu.gd, scripts/ui/ui_root.gd, scripts/game/main.gd]
---

# Pause menu

While paused, a small menu near the bottom of the screen (clear of the "Paused" text) offers **Resume** and **Quit to title**. The existing
`pause_label` stays as it is.

**1. Create the file `scripts/ui/pause_menu.gd` with exactly this code** (use that exact path as the edit's file name):
```gdscript
class_name PauseMenu
extends PanelContainer
## Buttons near the bottom of the screen while paused: Resume, or quit to the title.

signal resume_pressed
signal quit_pressed

var resume_button: Button
var quit_button: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BEGIN
	custom_minimum_size = Vector2(260, 0)
	offset_top -= 140.0
	offset_bottom -= 140.0
	var box := VBoxContainer.new()
	add_child(box)
	resume_button = Button.new()
	resume_button.text = "Resume"
	resume_button.pressed.connect(func(): resume_pressed.emit())
	box.add_child(resume_button)
	quit_button = Button.new()
	quit_button.text = "Quit to title"
	quit_button.pressed.connect(func(): quit_pressed.emit())
	box.add_child(quit_button)
	hide()
```

**2. `scripts/ui/ui_root.gd`:** add `var pause_menu: PauseMenu` after `var wardrobe_panel: WardrobePanel`, and in
`_ready()` right after `add_child(wardrobe_panel)` (before the theme loop):
```gdscript
	pause_menu = PauseMenu.new()
	add_child(pause_menu)
```

**3. `scripts/game/main.gd`** (only these edits):
- In `_build_ui()`, right after `ui_layer.rogue_panel.reroll_pressed.connect(reroll_perks)`:
  ```gdscript
  	ui_layer.pause_menu.resume_pressed.connect(toggle_pause)
  	ui_layer.pause_menu.quit_pressed.connect(go_to_title)
  ```
- In `go_to_title()`, right after `pause_label.hide()`: `ui_layer.pause_menu.hide()`
- In `toggle_pause()`, right after `pause_label.visible = is_paused`: `ui_layer.pause_menu.visible = is_paused`

## Acceptance criteria
- Pausing shows the themed menu on screen, not overlapping the "Paused" text; Resume unpauses and hides it.
- Quit to title goes to the title, unpaused, with the menu and the Paused text hidden.
