---
id: 159-weather-hud
status: ready
tests: [tests/acceptance/test_159_weather_hud.gd]
files: [scripts/ui/hud.gd, scripts/ui/ui_root.gd]
---

# Weather on the HUD

The roguelike HUD shows the round's weather under the perks ("Weather: Tailwind"); calm rounds and classic hide it.

**1. `scripts/ui/hud.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var lucky_label: Label
```
REPLACE:
```gdscript
var lucky_label: Label
var weather_label: Label
```

Edit 2 - SEARCH:
```gdscript
	right_container.add_child(perks_label)
```
REPLACE:
```gdscript
	right_container.add_child(perks_label)
	
	weather_label = Label.new()
	weather_label.add_theme_font_size_override("font_size", 18)
	weather_label.add_theme_color_override("font_color", Color(0.7, 0.9, 1.0))
	weather_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	weather_label.hide()
	right_container.add_child(weather_label)
```

Edit 3 - SEARCH:
```gdscript
func show_lucky(on: bool) -> void:
```
REPLACE:
```gdscript
## Roguelike: the round's weather under the perks (hidden when `weather_name` is empty).
func show_weather(weather_name: String) -> void:
	weather_label.text = "Weather: " + weather_name
	weather_label.visible = weather_name != ""


func show_lucky(on: bool) -> void:
```

**2. `scripts/ui/ui_root.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
		hud.show_lucky(RogueGoals.is_lucky_round(main.rogue.round_number, main.rogue.run_seed))
```
REPLACE:
```gdscript
		hud.show_lucky(RogueGoals.is_lucky_round(main.rogue.round_number, main.rogue.run_seed))
		var weather: Dictionary = RogueWeather.get_def(main.rogue.weather)
		hud.show_weather("" if main.rogue.weather == "calm" else str(weather.get("name", "")))
```

Edit 2 - SEARCH:
```gdscript
		hud.show_lucky(false)
```
REPLACE:
```gdscript
		hud.show_lucky(false)
		hud.show_weather("")
```

## Acceptance criteria
- "Weather: <name>" for a non-calm roguelike round; hidden otherwise.
