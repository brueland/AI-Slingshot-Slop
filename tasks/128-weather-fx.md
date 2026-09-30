---
id: 128-weather-fx
status: ready
tests: [tests/acceptance/test_128_weather_fx.gd]
files: [scripts/game/weather_fx.gd, scripts/game/world_builder.gd, scripts/game/main.gd]
read: [scripts/core/rogue_weather.gd]
---

# Weather on screen

The roguelike weather becomes visible: wind streaks (tailwind/headwind), rain (soggy ground), rising sparkles
(springy ground) and a haze (thick air), drawn above the world and under the UI. Calm and classic shots show
nothing.

**1. Create the file `scripts/game/weather_fx.gd` with exactly this code** (use that exact path as the edit's file name):
```gdscript
class_name WeatherFx
extends CanvasLayer
## Screen effects for the roguelike weather: wind streaks (tailwind/headwind), rain (soggy ground), rising sparkles
## (springy ground) and a haze (thick air). Calm shows nothing. Drawn above the world and under the UI.

const COUNT: int = 40

var weather: String = "calm"
var time: float = 0.0
var canvas: Node2D


func _ready() -> void:
	layer = 1
	canvas = Node2D.new()
	add_child(canvas)
	canvas.draw.connect(_draw_weather)
	canvas.visible = false


func show_weather(id: String) -> void:
	weather = id if not RogueWeather.get_def(id).is_empty() else "calm"
	canvas.visible = weather != "calm"
	canvas.queue_redraw()


func _process(delta: float) -> void:
	time += delta
	if weather != "calm":
		canvas.queue_redraw()


## Where particle `i` is at time `t` on a screen of `size`: particles drift with `velocity` and wrap around.
static func particle_position(i: int, t: float, size: Vector2, velocity: Vector2) -> Vector2:
	var start := Vector2(fposmod(i * 97.0, size.x), fposmod(i * 57.0, size.y))
	return Vector2(fposmod(start.x + velocity.x * t, size.x), fposmod(start.y + velocity.y * t, size.y))


static func velocity_for(id: String) -> Vector2:
	match id:
		"tailwind":
			return Vector2(420, 30)
		"headwind":
			return Vector2(-420, 30)
		"soggy":
			return Vector2(-40, 520)
		"springy":
			return Vector2(0, -60)
	return Vector2.ZERO


func _draw_weather() -> void:
	var size := canvas.get_viewport_rect().size
	if weather == "thick_air":
		canvas.draw_rect(Rect2(Vector2.ZERO, size), Color(0.8, 0.8, 0.75, 0.18))
		return
	var v := velocity_for(weather)
	for i in COUNT:
		var p := particle_position(i, time, size, v)
		match weather:
			"tailwind", "headwind":
				canvas.draw_line(p, p + v.normalized() * 26.0, Color(1, 1, 1, 0.35), 2.0)
			"soggy":
				canvas.draw_line(p, p + Vector2(-3, 12), Color(0.6, 0.7, 1.0, 0.5), 1.5)
			"springy":
				canvas.draw_circle(p, 2.0, Color(1.0, 1.0, 0.6, 0.6))
```

**2. `scripts/game/world_builder.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	main.add_child(main.feedback)
```
REPLACE:
```gdscript
	main.add_child(main.feedback)
	main.weather_fx = WeatherFx.new()
	main.add_child(main.weather_fx)
```

**3. `scripts/game/main.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var ufo: Ufo
```
REPLACE:
```gdscript
var ufo: Ufo
var weather_fx: WeatherFx
```

Edit 2 - SEARCH:
```gdscript
	ufo.reset()
```
REPLACE:
```gdscript
	ufo.reset()
	weather_fx.show_weather(rogue.weather if mode == "rogue" else "calm")
```

## Acceptance criteria
- `show_weather(id)` shows that weather (unknown ids are calm; calm hides the effect); particles wrap around the screen.
- WorldBuilder adds `weather_fx` (under the UI); every shot shows the roguelike round's weather, classic shows calm.
