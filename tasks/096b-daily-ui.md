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

**4. `scripts/game/main.gd`**: exactly these six SEARCH/REPLACE edits. Each REPLACE keeps the SEARCH lines and
adds the new lines; do not change or remove anything else (no other variable or function is touched, and
`choose_rogue_perk()` must stay).

Edit 1 - SEARCH:
```gdscript
var rogue_outcome: Dictionary = {}
```
REPLACE:
```gdscript
var rogue_outcome: Dictionary = {}
var daily_key: String = ""
```

Edit 2 - SEARCH:
```gdscript
	mode = "rogue"
	rogue = RogueRun.new()
```
REPLACE:
```gdscript
	mode = "rogue"
	daily_key = ""
	rogue = RogueRun.new()
```

Edit 3 - SEARCH:
```gdscript
func choose_rogue_perk(id: String) -> bool:
```
REPLACE:
```gdscript
## Today's roguelike run (or the run of `date`): the same seed for everyone on that day.
func start_daily(date: Dictionary = {}) -> void:
	if state != State.TITLE:
		return
	var day := date if not date.is_empty() else Daily.today()
	start_rogue(Daily.seed_for(day))
	daily_key = Daily.key_for(day)


func choose_rogue_perk(id: String) -> bool:
```

Edit 4 - SEARCH:
```gdscript
			progress.best_rogue_round = maxi(progress.best_rogue_round, rogue.rounds_cleared)
```
REPLACE:
```gdscript
			progress.best_rogue_round = maxi(progress.best_rogue_round, rogue.rounds_cleared)
			if daily_key != "":
				Daily.record(progress.daily_best, daily_key, rogue.rounds_cleared)
```

Edit 5 - SEARCH:
```gdscript
	title_panel.rogue_pressed.connect(start_rogue)
```
REPLACE:
```gdscript
	title_panel.rogue_pressed.connect(start_rogue)
	title_panel.daily_pressed.connect(start_daily)
```

Edit 6 - SEARCH:
```gdscript
func go_to_title() -> void:
	mode = "classic"
```
REPLACE:
```gdscript
func go_to_title() -> void:
	mode = "classic"
	daily_key = ""
```

## Acceptance criteria
- The title's "Daily Run" button plays today's run; `start_daily(date)` plays that date's run.
- When a daily run ends, its best is saved and the run-over screen says
  "Daily run 2026-09-29 - best today: 3 rounds"; normal runs hide that line.
