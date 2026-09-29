---
id: 085-wardrobe
status: ready
tests: [tests/acceptance/test_085_wardrobe.gd]
files: [scripts/ui/wardrobe_panel.gd, scripts/ui/ui_root.gd, scripts/ui/title_panel.gd, scripts/game/main.gd]
read: [scripts/core/hats.gd, scripts/game/projectile_view.gd]
---

# Wardrobe screen

**1. Create `scripts/ui/wardrobe_panel.gd` with exactly this code:**
```gdscript
class_name WardrobePanel
extends PanelContainer
## Pick a hat for the alien. Locked hats show how to unlock them.

signal hat_chosen(id: String)
signal closed

var title_label: Label
var hat_buttons: Dictionary = {}
var close_button: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	custom_minimum_size = Vector2(420, 0)
	var box := VBoxContainer.new()
	add_child(box)
	title_label = Label.new()
	title_label.text = "Wardrobe"
	title_label.add_theme_font_size_override("font_size", 32)
	box.add_child(title_label)
	for entry in Hats.LIST:
		var id: String = entry["id"]
		var button := Button.new()
		button.text = entry["name"]
		button.pressed.connect(func(): hat_chosen.emit(id))
		box.add_child(button)
		hat_buttons[id] = button
	close_button = Button.new()
	close_button.text = "Done"
	close_button.pressed.connect(func(): closed.emit())
	box.add_child(close_button)
	hide()


func show_hats(progress: Progress) -> void:
	for entry in Hats.LIST:
		var id: String = entry["id"]
		var button: Button = hat_buttons[id]
		var open := Hats.is_unlocked(id, progress)
		button.disabled = not open
		if not open:
			button.text = "Locked - %s" % entry["hint"]
		elif id == progress.hat:
			button.text = "%s (wearing)" % entry["name"]
		else:
			button.text = entry["name"]
	show()
```

**2. `scripts/ui/ui_root.gd`:** add `var wardrobe_panel: WardrobePanel` after `var rogue_over_panel ...`, and in
`_ready()` right after `add_child(rogue_over_panel)` (before the theme loop):
```gdscript
	wardrobe_panel = WardrobePanel.new()
	add_child(wardrobe_panel)
```

**3. `scripts/ui/title_panel.gd`:** add `signal wardrobe_pressed` after `signal rogue_pressed`, `var wardrobe_button: Button`
after `var rogue_button: Button`, and in `_ready()` right after `box.add_child(rogue_button)`:
```gdscript
	wardrobe_button = Button.new()
	wardrobe_button.text = "Wardrobe"
	wardrobe_button.pressed.connect(func(): wardrobe_pressed.emit())
	box.add_child(wardrobe_button)
```

**4. `scripts/game/main.gd`** (only these edits):
- **Declare** `var wardrobe_panel: WardrobePanel` after `var toast: Toast`.
- In `_build_ui()`: after `toast = ui_layer.toast` add `wardrobe_panel = ui_layer.wardrobe_panel`, and after
  `ui_layer.rogue_over_panel.back_pressed.connect(go_to_title)` add:
  ```gdscript
  	title_panel.wardrobe_pressed.connect(func(): wardrobe_panel.show_hats(progress))
  	wardrobe_panel.hat_chosen.connect(choose_hat)
  	wardrobe_panel.closed.connect(wardrobe_panel.hide)
  ```
- In `_ready()`, right after the `feedback.setup(...)` line: `projectile_view.set_hat(progress.hat)`
- In `reset_progress()`, right after `progress = Progress.new()`: `projectile_view.set_hat(progress.hat)`
- Add this function right before `open_options()`:
  ```gdscript
  func choose_hat(id: String) -> bool:
  	if not Hats.is_unlocked(id, progress):
  		return false
  	progress.hat = id
  	projectile_view.set_hat(id)
  	save_progress()
  	wardrobe_panel.show_hats(progress)
  	return true
  ```

## Acceptance criteria
- The title has a "Wardrobe" button that opens a centered, themed panel with one button per hat and "Done".
- Locked hats are disabled and read "Locked - <hint>"; the worn hat reads "<name> (wearing)".
- Choosing an unlocked hat wears it, saves it, and it is worn again after a restart; a reset takes it off.
