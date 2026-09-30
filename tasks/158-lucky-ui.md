---
id: 158-lucky-ui
status: ready
tests: [tests/acceptance/test_158_lucky_ui.gd]
files: [scripts/ui/hud.gd, scripts/ui/ui_root.gd, scripts/ui/rogue_panel.gd]
---

# Lucky rounds on screen

A lucky round shows "Lucky round! Beat it for a reroll" on the HUD; after meeting it the perk panel says
"Lucky! Goal met, +1 reroll".

**1. `scripts/ui/hud.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var boss_label: Label
```
REPLACE:
```gdscript
var boss_label: Label
var lucky_label: Label
```

Edit 2 - SEARCH:
```gdscript
	add_child(boss_label)
```
REPLACE:
```gdscript
	add_child(boss_label)
	lucky_label = Label.new()
	lucky_label.text = "Lucky round! Beat it for a reroll"
	lucky_label.add_theme_font_size_override("font_size", 24)
	lucky_label.add_theme_color_override("font_color", Color(0.5, 1.0, 0.5))
	lucky_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lucky_label.anchor_left = 0.5
	lucky_label.anchor_right = 0.5
	lucky_label.offset_left = -240
	lucky_label.offset_right = 240
	lucky_label.offset_top = 64
	lucky_label.offset_bottom = 96
	lucky_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lucky_label.hide()
	add_child(lucky_label)
```

Edit 3 - SEARCH:
```gdscript
func show_boss(on: bool) -> void:
```
REPLACE:
```gdscript
func show_lucky(on: bool) -> void:
	lucky_label.visible = on


func show_boss(on: bool) -> void:
```

**2. `scripts/ui/ui_root.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
		hud.show_boss(str(main.rogue.goal.get("type", "")) == "boss")
```
REPLACE:
```gdscript
		hud.show_boss(str(main.rogue.goal.get("type", "")) == "boss")
		hud.show_lucky(RogueGoals.is_lucky_round(main.rogue.round_number, main.rogue.run_seed))
```

Edit 2 - SEARCH:
```gdscript
		hud.show_boss(false)
```
REPLACE:
```gdscript
		hud.show_boss(false)
		hud.show_lucky(false)
```

**3. `scripts/ui/rogue_panel.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes. (The two new lines go right before the existing boss check in `show_outcome()`.)

Edit 1 - SEARCH:
```gdscript
	if outcome.get("boss_beaten", false):
```
REPLACE:
```gdscript
	if outcome.get("lucky", false):
		title_label.text = "Lucky! Goal met, +1 reroll"
	if outcome.get("boss_beaten", false):
```

## Acceptance criteria
- The HUD banner shows only during lucky roguelike rounds and fits on screen.
- The perk panel title after a lucky round is "Lucky! Goal met, +1 reroll".
