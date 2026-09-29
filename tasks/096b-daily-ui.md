---
id: 096b-daily-ui
status: ready
tests: [tests/acceptance/test_096b_daily_ui.gd]
files: [scripts/ui/title_panel.gd, scripts/ui/rogue_over_panel.gd, scripts/ui/ui_root.gd, scripts/game/main.gd]
read: [scripts/core/daily.gd]
---

# Daily Run (part 2: in the game)

A "Daily Run" button on the title starts today's roguelike run (task 096 added `Daily` and `Progress.daily_best`).
When a daily run ends its best is saved, and the run-over screen shows it. Use small SEARCH/REPLACE edits.

**1. `scripts/ui/title_panel.gd`:** add `signal daily_pressed` on the line after `signal rogue_pressed`, declare the
variable on the line right after `var rogue_button: Button`:
```gdscript
var daily_button: Button
```
and in `_ready()` right after `box.add_child(rogue_button)`:
```gdscript
	daily_button = Button.new()
	daily_button.text = "Daily Run"
	daily_button.pressed.connect(func(): daily_pressed.emit())
	box.add_child(daily_button)
```

**2. `scripts/ui/rogue_over_panel.gd`:** declare the variable on the line right after `var perks_label: Label`:
```gdscript
var daily_label: Label
```
and in `_ready()` right before `back_button = Button.new()`:
```gdscript
	daily_label = Label.new()
	daily_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	daily_label.hide()
	box.add_child(daily_label)
```

**3. `scripts/ui/ui_root.gd`:** in `refresh()`, right after the `show_rogue_screens(...)` line:
```gdscript
	var daily_key: String = main.daily_key
	rogue_over_panel.daily_label.visible = daily_key != ""
	rogue_over_panel.daily_label.text = "Daily run %s - best today: %d rounds" % [daily_key, int(progress.daily_best.get(daily_key, 0))]
```

**4. `scripts/game/main.gd`**: six small edits. `start_rogue()`, `_finish_run()`, `_build_ui()` and `go_to_title()`
already exist: **add lines inside them, never declare them again** (a second `func start_rogue` is a parse error).
The only new function is `start_daily()`.
- Declare the variable on the line right after `var rogue_outcome: Dictionary = {}`:
  ```gdscript
  var daily_key: String = ""
  ```
- Inside the existing `start_rogue()`, add one line right after `mode = "rogue"`:
  ```gdscript
  	daily_key = ""
  ```
- Add this new function right before the existing `func choose_rogue_perk(`:
  ```gdscript
  ## Today's roguelike run (or the run of `date`): the same seed for everyone on that day.
  func start_daily(date: Dictionary = {}) -> void:
  	if state != State.TITLE:
  		return
  	var day := date if not date.is_empty() else Daily.today()
  	start_rogue(Daily.seed_for(day))
  	daily_key = Daily.key_for(day)
  ```
- Inside the existing `_finish_run()`, inside `if rogue.is_over():`, right after the `progress.best_rogue_round = ...` line:
  ```gdscript
  			if daily_key != "":
  				Daily.record(progress.daily_best, daily_key, rogue.rounds_cleared)
  ```
- Inside the existing `_build_ui()`, right after `title_panel.rogue_pressed.connect(start_rogue)`:
  ```gdscript
  	title_panel.daily_pressed.connect(start_daily)
  ```
- Inside the existing `go_to_title()`, right after `mode = "classic"`:
  ```gdscript
  	daily_key = ""
  ```

## Acceptance criteria
- The title's "Daily Run" button plays today's run; `start_daily(date)` plays that date's run.
- When a daily run ends, its best is saved and the run-over screen says
  "Daily run 2026-09-29 - best today: 3 rounds"; normal runs hide that line.
