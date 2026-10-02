---
id: 246-hud-perk-boxes
status: ready
tests: [tests/acceptance/test_246_hud_perk_boxes.gd, tests/acceptance/test_132_hud_perks.gd, tests/acceptance/test_136c_checkpoint_depth.gd]
files: [scripts/ui/hud.gd, scripts/ui/ui_root.gd]
---

# The right panel stays on screen

Late in a roguelike run (round 18) the HUD's right panel grew past the edge of the screen: a boss goal like "Goal:
BOSS: Bounce 5 times + Reach 55 m high" made it wider, and the perks were one long line of text. Now the goal
lines wrap at the panel's width, and the perks are boxes with counts (`PerkChips`, task 245). `show_perks` takes
the perk ids. Two older tests are updated for the boxes (checkpoint 136c's deliberate miss also gets a goal it
surely misses: a daily run's round 2 can be met by its tiny shot, depending on the date).

**1. `scripts/ui/hud.gd`**: exactly these 5 SEARCH/REPLACE edit(s). Edit 1 replaces the `perks_label` variable with `perk_chips`; edits 2 and 3 add two lines each; edit 4 replaces the whole `perks_label` block in `_ready()` with two lines; edit 5 replaces `show_perks()`. Nothing else in hud.gd changes (it must stay under 300 lines).

Edit 1 - SEARCH:
```gdscript
var perks_label: Label
```
REPLACE:
```gdscript
var perk_chips: PerkChips
```

Edit 2 - SEARCH:
```gdscript
	goal_label.add_theme_font_size_override("font_size", 22)
```
REPLACE:
```gdscript
	goal_label.add_theme_font_size_override("font_size", 22)
	goal_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	goal_label.custom_minimum_size = Vector2(300, 0)
```

Edit 3 - SEARCH:
```gdscript
	goal_progress_label.add_theme_font_size_override("font_size", 20)
```
REPLACE:
```gdscript
	goal_progress_label.add_theme_font_size_override("font_size", 20)
	goal_progress_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	goal_progress_label.custom_minimum_size = Vector2(300, 0)
```

Edit 4 - SEARCH:
```gdscript
	perks_label = Label.new()
	perks_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	perks_label.custom_minimum_size = Vector2(300, 0)
	perks_label.add_theme_font_size_override("font_size", 16)
	perks_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	perks_label.hide()
	right_container.add_child(perks_label)
```
REPLACE:
```gdscript
	perk_chips = PerkChips.new()
	right_container.add_child(perk_chips)
```

Edit 5 - SEARCH:
```gdscript
## Roguelike: the perks taken so far, under the goal (hidden when `text` is empty).
func show_perks(text: String) -> void:
	perks_label.text = "Perks: " + text
	perks_label.visible = text != ""
```
REPLACE:
```gdscript
## Roguelike: the perks taken so far as boxes with counts, under the goal (hidden when there are none).
func show_perks(perk_ids: Array) -> void:
	perk_chips.show_perks(perk_ids)
```

**2. `scripts/ui/ui_root.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Each REPLACE changes the argument of one `show_perks` call in `refresh()`; nothing else changes.

Edit 1 - SEARCH:
```gdscript
		hud.show_perks(RoguePerks.summary(main.rogue.perks))
```
REPLACE:
```gdscript
		hud.show_perks(main.rogue.perks)
```

Edit 2 - SEARCH:
```gdscript
		hud.show_perks("")
```
REPLACE:
```gdscript
		hud.show_perks([])
```

## Acceptance criteria
- `hud.perk_chips` (a PerkChips in the right panel, where perks_label was) shows the run's perks; `show_perks(ids)`.
- `goal_label` and `goal_progress_label` wrap at 300 px, so the right panel keeps its width and stays on screen.
