---
id: 228-zone-marker-world
status: ready
tests: [tests/acceptance/test_228_zone_marker_world.gd]
files: [scripts/game/world_builder.gd, scripts/game/main.gd]
---

# The landing zone on the field

WorldBuilder adds the landing zone marker to the world, and every roguelike shot shows it when the goal has a zone.

**1. `scripts/game/world_builder.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	main.add_child(SkyBalloons.new())
```
REPLACE:
```gdscript
	main.add_child(SkyBalloons.new())
	main.zone_marker = ZoneMarker.new()
	main.add_child(main.zone_marker)
```

**2. `scripts/game/main.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Edit 1 adds a variable; Edit 2 adds one line in `_begin_aim()`. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var weather_fx: WeatherFx
```
REPLACE:
```gdscript
var weather_fx: WeatherFx
var zone_marker: ZoneMarker
```

Edit 2 - SEARCH:
```gdscript
	weather_fx.show_weather(rogue.weather if mode == "rogue" else "calm")
```
REPLACE:
```gdscript
	weather_fx.show_weather(rogue.weather if mode == "rogue" else "calm")
	zone_marker.show_goal(rogue.goal if mode == "rogue" else {})
```

## Acceptance criteria
- `main.zone_marker` is built right after the hot-air balloons (behind the course) and shows the goal's zone each shot; hidden in classic.
