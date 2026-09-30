---
id: 192-wind-sock-world
status: ready
tests: [tests/acceptance/test_192_wind_sock_world.gd]
files: [scripts/game/weather_fx.gd, scripts/game/world_builder.gd]
---

# Windsock by the slingshot

The windsock stands near the slingshot, and WeatherFx points it whenever it shows a shot's weather.

**1. `scripts/game/weather_fx.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var canvas: Node2D
```
REPLACE:
```gdscript
var canvas: Node2D
## The windsock near the slingshot (set by WorldBuilder); show_weather() points it.
var windsock: WindSock
```

Edit 2 - SEARCH:
```gdscript
	canvas.visible = weather != "calm"
```
REPLACE:
```gdscript
	canvas.visible = weather != "calm"
	if windsock != null:
		windsock.set_weather(weather)
```

**2. `scripts/game/world_builder.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	main.kites = Kites.new()
	main.add_child(main.kites)
```
REPLACE:
```gdscript
	main.kites = Kites.new()
	main.add_child(main.kites)
	var sock := WindSock.new()
	main.add_child(sock)
```

Edit 2 - SEARCH:
```gdscript
	main.weather_fx = WeatherFx.new()
	main.add_child(main.weather_fx)
```
REPLACE:
```gdscript
	main.weather_fx = WeatherFx.new()
	main.add_child(main.weather_fx)
	main.weather_fx.windsock = sock
```

## Acceptance criteria
- WorldBuilder adds one WindSock right after the kites and gives it to `weather_fx.windsock`.
- `WeatherFx.show_weather` calls `windsock.set_weather`; classic shots are calm.
