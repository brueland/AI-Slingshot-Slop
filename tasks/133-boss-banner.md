---
id: 133-boss-banner
status: ready
tests: [tests/acceptance/test_133_boss_banner.gd]
files: [scripts/ui/hud.gd, scripts/ui/ui_root.gd]
---

# Boss banner

During a roguelike boss round the HUD shows "BOSS ROUND!" at the top center.

**1. `scripts/ui/hud.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var perks_label: Label
```
REPLACE:
```gdscript
var perks_label: Label
var boss_label: Label
```

Edit 2 - SEARCH:
```gdscript
	# Hint label at bottom center
```
REPLACE:
```gdscript
	# Boss banner at the top center
	boss_label = Label.new()
	boss_label.text = "BOSS ROUND!"
	boss_label.add_theme_font_size_override("font_size", 34)
	boss_label.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45))
	boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_label.anchor_left = 0.5
	boss_label.anchor_right = 0.5
	boss_label.offset_left = -200
	boss_label.offset_right = 200
	boss_label.offset_top = 16
	boss_label.offset_bottom = 60
	boss_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boss_label.hide()
	add_child(boss_label)
	
	# Hint label at bottom center
```

Edit 3 - SEARCH:
```gdscript
func hide_hint() -> void:
```
REPLACE:
```gdscript
func show_boss(on: bool) -> void:
	boss_label.visible = on


func hide_hint() -> void:
```

**2. `scripts/ui/ui_root.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
		hud.show_perks(RoguePerks.summary(main.rogue.perks))
```
REPLACE:
```gdscript
		hud.show_perks(RoguePerks.summary(main.rogue.perks))
		hud.show_boss(str(main.rogue.goal.get("type", "")) == "boss")
```

Edit 2 - SEARCH:
```gdscript
		hud.show_perks("")
```
REPLACE:
```gdscript
		hud.show_perks("")
		hud.show_boss(false)
```

## Acceptance criteria
- The banner is visible during boss rounds only (never in classic) and fits on screen.
