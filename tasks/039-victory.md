---
id: 039-victory
status: ready
tests: [tests/acceptance/test_039_victory.gd]
files: [scripts/ui/victory_panel.gd, scripts/game/main.gd]
read: [scripts/ui/results_panel.gd, scripts/core/progress.gd]
---

# Victory at 1000 m

**1. Create `scripts/ui/victory_panel.gd`:**
```gdscript
class_name VictoryPanel
extends PanelContainer
## Shown once, the first time a run reaches GOAL_DISTANCE.

signal continue_pressed

var message_label: Label
var continue_button: Button
```
`_ready()`: centered like the other panels (`custom_minimum_size = Vector2(480, 0)`), a VBoxContainer with
`message_label` (font size 32: `add_theme_font_size_override("font_size", 32)`) and `continue_button` text `"Keep flying"` (pressed -> emit `continue_pressed`);
then `hide()`.

`func show_victory(runs: int) -> void`:
`message_label.text = "You reached %d m in %d runs!" % [int(Balance.GOAL_DISTANCE), runs]`, then `show()`.

**2. Edit `scripts/game/main.gd`:**
- `var victory_panel: VictoryPanel`, created in `_build_ui()` on `ui_layer`; `continue_pressed` -> `continue_to_shop`.
- `continue_to_shop()` works from RESULTS **or** VICTORY.
- In `_finish_run()`: remember `var had_goal := progress.goal_reached` before `record_run`; at the end go to
  `State.VICTORY` if `progress.goal_reached and not had_goal`, otherwise `State.RESULTS` as before.
- In `_update_ui()`: in VICTORY call `victory_panel.show_victory(progress.total_runs)`, otherwise `victory_panel.hide()`.

## Acceptance criteria
- The first run that reaches 1000 m shows "You reached 1000 m in 37 runs!" (for the 37th run); its button opens the shop.
- Later long runs go to RESULTS.
