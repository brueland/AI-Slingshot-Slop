---
id: 134-daily-streak
status: ready
tests: [tests/acceptance/test_134_daily_streak.gd]
files: [scripts/core/daily.gd, scripts/ui/rogue_over_panel.gd, scripts/ui/ui_root.gd]
---

# Daily streak

Daily runs count a streak: how many days in a row have a daily result. The run-over screen of a daily run shows
"Daily streak: N days".

**1. `scripts/core/daily.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
static func today() -> Dictionary:
```
REPLACE:
```gdscript
## How many days in a row, up to and including `today_date`, have a daily result in `bests`.
static func streak(bests: Dictionary, today_date: Dictionary) -> int:
	var noon := {"year": int(today_date.get("year", 2000)), "month": int(today_date.get("month", 1)), "day": int(today_date.get("day", 1)), "hour": 12}
	var day_seconds := Time.get_unix_time_from_datetime_dict(noon)
	var count := 0
	while bests.has(key_for(Time.get_date_dict_from_unix_time(day_seconds - count * 86400))):
		count += 1
	return count


static func today() -> Dictionary:
```

**2. `scripts/ui/rogue_over_panel.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var daily_label: Label
```
REPLACE:
```gdscript
var daily_label: Label
var streak_label: Label
```

Edit 2 - SEARCH:
```gdscript
	box.add_child(daily_label)
```
REPLACE:
```gdscript
	box.add_child(daily_label)
	streak_label = Label.new()
	streak_label.add_theme_color_override("font_color", Color(1.0, 0.7, 0.3))
	streak_label.hide()
	box.add_child(streak_label)
```

**3. `scripts/ui/ui_root.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	rogue_over_panel.show_history(progress.rogue_history)
```
REPLACE:
```gdscript
	rogue_over_panel.show_history(progress.rogue_history)
	var streak := Daily.streak(progress.daily_best, Daily.today())
	rogue_over_panel.streak_label.visible = daily_key != "" and streak > 0
	rogue_over_panel.streak_label.text = "Daily streak: %d day%s" % [streak, "" if streak == 1 else "s"]
```

## Acceptance criteria
- `Daily.streak(bests, today)` counts the days in a row ending today (0 when today has no result), across month ends.
- A daily run's run-over screen shows "Daily streak: 1 day" / "N days"; normal runs hide it.
