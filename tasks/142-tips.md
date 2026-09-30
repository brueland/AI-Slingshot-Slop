---
id: 142-tips
status: ready
tests: [tests/acceptance/test_142_tips.gd]
files: [scripts/core/tips.gd, scripts/ui/ui_root.gd]
---

# Tip of the day

The title screen shows a tip of the day at the bottom of the screen (the same tip all day).

**1. Create the file `scripts/core/tips.gd` with exactly this code** (use that exact path as the edit's file name):
```gdscript
class_name Tips
extends RefCounted
## Tips of the day for the title screen (the same tip all day).

const LIST: Array[String] = [
	"Tip: bigger aliens reach stars more easily (roguelike sizes).",
	"Tip: press R to repeat your last shot once you can see its line.",
	"Tip: fly into party balloons for a free lift.",
	"Tip: springs launch you high - aim for them!",
	"Tip: mud slows you down. Fly over it.",
	"Tip: the Daily Run is the same for everyone today.",
	"Tip: beat a boss round for an extra life.",
	"Tip: Headwind? Take Stronger Bands.",
	"Tip: sheep hop when you land next to them. Black sheep don't care.",
	"Tip: the arrow keys and Enter can aim and launch too.",
]


static func for_date(date: Dictionary) -> String:
	return LIST[posmod(Daily.seed_for(date), LIST.size())]
```

**2. `scripts/ui/ui_root.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var pause_menu: PauseMenu
```
REPLACE:
```gdscript
var pause_menu: PauseMenu
var tip_label: Label
```

Edit 2 - SEARCH:
```gdscript
	pause_menu = PauseMenu.new()
	add_child(pause_menu)
```
REPLACE:
```gdscript
	pause_menu = PauseMenu.new()
	add_child(pause_menu)
	tip_label = Label.new()
	tip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip_label.anchor_left = 0.5
	tip_label.anchor_right = 0.5
	tip_label.anchor_top = 1.0
	tip_label.anchor_bottom = 1.0
	tip_label.offset_left = -420
	tip_label.offset_right = 420
	tip_label.offset_top = -44
	tip_label.offset_bottom = -14
	tip_label.add_theme_color_override("font_color", Color(1.0, 1.0, 0.85))
	tip_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(tip_label)
```

Edit 3 - SEARCH:
```gdscript
	title_panel.visible = state == "TITLE"
```
REPLACE:
```gdscript
	title_panel.visible = state == "TITLE"
	tip_label.visible = title_panel.visible
	tip_label.text = Tips.for_date(Daily.today())
```

## Acceptance criteria
- Ten tips; `Tips.for_date(date)` picks one by the date's seed.
- The tip shows at the bottom of the screen on the title only, under the title panel.
