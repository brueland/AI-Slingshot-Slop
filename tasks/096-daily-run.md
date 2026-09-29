---
id: 096-daily-run
status: ready
tests: [tests/acceptance/test_096_daily_run.gd]
files: [scripts/core/daily.gd, scripts/core/progress.gd, scripts/ui/title_panel.gd, scripts/ui/rogue_over_panel.gd, scripts/ui/ui_root.gd, scripts/game/main.gd]
---

# Daily Run

A "Daily Run" button on the title starts a roguelike run whose seed is today's date, so everyone gets the same
goals, courses and perk offers that day. The best rounds per day are saved (last 30 days) and shown on the
run-over screen.

**1. Create the file `scripts/core/daily.gd` with exactly this code** (use that exact path as the edit's file name):
```gdscript
class_name Daily
extends RefCounted
## The daily roguelike run: the same seed (so the same goals, courses and perk offers) for everyone on a day.

const KEEP_DAYS: int = 30


## "2026-09-29" for a date Dictionary with year, month and day (like Time.get_date_dict_from_system()).
static func key_for(date: Dictionary) -> String:
	return "%04d-%02d-%02d" % [int(date.get("year", 2000)), int(date.get("month", 1)), int(date.get("day", 1))]


## 20260929 for 2026-09-29.
static func seed_for(date: Dictionary) -> int:
	return int(date.get("year", 2000)) * 10000 + int(date.get("month", 1)) * 100 + int(date.get("day", 1))


static func today() -> Dictionary:
	return Time.get_date_dict_from_system()


## Records a daily result (keeps the best per day and only the newest KEEP_DAYS days).
static func record(bests: Dictionary, key: String, rounds: int) -> void:
	bests[key] = maxi(int(bests.get(key, 0)), rounds)
	var keys := bests.keys()
	keys.sort()
	while keys.size() > KEEP_DAYS:
		bests.erase(keys.pop_front())
```

**2. `scripts/core/progress.gd`:** **declare** `var daily_best: Dictionary = {}` after `var best_path ...`;
`to_dict()` adds `"daily_best": daily_best.duplicate(),`; in `from_dict()`, right before the line
`var hat_id := str(data.get("hat", "none"))`:
```gdscript
	var daily_data = data.get("daily_best")
	if typeof(daily_data) == TYPE_DICTIONARY:
		for key in daily_data:
			Daily.record(p.daily_best, str(key), maxi(0, int(daily_data[key])))
```

**3. `scripts/ui/title_panel.gd`:** add `signal daily_pressed` after `signal rogue_pressed`, `var daily_button: Button`
after `var rogue_button: Button`, and in `_ready()` right after `box.add_child(rogue_button)`:
```gdscript
	daily_button = Button.new()
	daily_button.text = "Daily Run"
	daily_button.pressed.connect(func(): daily_pressed.emit())
	box.add_child(daily_button)
```

**4. `scripts/ui/rogue_over_panel.gd`:** **declare** `var daily_label: Label` after `var perks_label: Label`, and in
`_ready()` right before `back_button = Button.new()`:
```gdscript
	daily_label = Label.new()
	daily_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	daily_label.hide()
	box.add_child(daily_label)
```

**5. `scripts/ui/ui_root.gd`:** in `refresh()`, right after the `show_rogue_screens(...)` line:
```gdscript
	var daily_key: String = main.daily_key
	rogue_over_panel.daily_label.visible = daily_key != ""
	rogue_over_panel.daily_label.text = "Daily run %s - best today: %d rounds" % [daily_key, int(progress.daily_best.get(daily_key, 0))]
```

**6. `scripts/game/main.gd`** (only these edits):
- **Declare** `var daily_key: String = ""` after `var rogue_outcome ...`.
- In `start_rogue()`, right after `mode = "rogue"`: `daily_key = ""`
- Add this function right before `choose_rogue_perk()`:
  ```gdscript
  ## Today's roguelike run (or the run of `date`): the same seed for everyone on that day.
  func start_daily(date: Dictionary = {}) -> void:
  	if state != State.TITLE:
  		return
  	var day := date if not date.is_empty() else Daily.today()
  	start_rogue(Daily.seed_for(day))
  	daily_key = Daily.key_for(day)
  ```
- In `_finish_run()`, inside `if rogue.is_over():`, right after the `progress.best_rogue_round = ...` line:
  ```gdscript
  			if daily_key != "":
  				Daily.record(progress.daily_best, daily_key, rogue.rounds_cleared)
  ```
- In `_build_ui()`, right after `title_panel.rogue_pressed.connect(start_rogue)`:
  `title_panel.daily_pressed.connect(start_daily)`
- In `go_to_title()`, right after `mode = "classic"`: `daily_key = ""`

## Acceptance criteria
- `Daily.key_for` gives "2026-09-29", `seed_for` gives 20260929; `record` keeps the best per day, 30 days.
- The title's "Daily Run" button plays today's run; `start_daily(date)` plays that date's run.
- When a daily run ends, its best is saved and the run-over screen says
  "Daily run 2026-09-29 - best today: 3 rounds"; normal runs hide that line.
