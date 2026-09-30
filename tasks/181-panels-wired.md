---
id: 181-panels-wired
status: ready
tests: [tests/acceptance/test_181_panels_wired.gd]
files: [scripts/ui/ui_root.gd]
---

# Open the new panels

UiRoot builds the How to play and Achievements panels (themed like every other screen) and wires the title's new buttons to them.

**`scripts/ui/ui_root.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var rogue_over_panel: RogueOverPanel
```
REPLACE:
```gdscript
var rogue_over_panel: RogueOverPanel
var help_panel: HelpPanel
var achievements_panel: AchievementsPanel
```

Edit 2 - SEARCH:
```gdscript
	wardrobe_panel = WardrobePanel.new()
	add_child(wardrobe_panel)
```
REPLACE:
```gdscript
	wardrobe_panel = WardrobePanel.new()
	add_child(wardrobe_panel)
	help_panel = HelpPanel.new()
	add_child(help_panel)
	achievements_panel = AchievementsPanel.new()
	add_child(achievements_panel)
```

Edit 3 - SEARCH:
```gdscript
	credits_panel.closed.connect(credits_panel.hide)
```
REPLACE:
```gdscript
	credits_panel.closed.connect(credits_panel.hide)
	title_panel.help_pressed.connect(help_panel.show)
	help_panel.closed.connect(help_panel.hide)
	title_panel.achievements_pressed.connect(func(): achievements_panel.show_list(main.progress))
	achievements_panel.closed.connect(achievements_panel.hide)
```

## Acceptance criteria
- `ui_layer.help_panel` and `ui_layer.achievements_panel` exist, themed, and open from the title; Close hides them.
- The Achievements panel shows main's progress.
