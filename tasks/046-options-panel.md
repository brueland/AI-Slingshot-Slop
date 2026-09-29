---
id: 046-options-panel
status: ready
tests: [tests/acceptance/test_046_options_panel.gd]
files: [scripts/ui/options_panel.gd, scripts/ui/title_panel.gd, scripts/game/main.gd]
---

# Options panel with volume sliders

**1. Create `scripts/ui/options_panel.gd`:**
```gdscript
class_name OptionsPanel
extends PanelContainer
## Music and sound-effect volume sliders.

signal volume_changed(kind: String, value: float)
signal closed

var music_slider: HSlider
var sfx_slider: HSlider
var close_button: Button
```
`_ready()`: centered like the other panels (`custom_minimum_size = Vector2(420, 0)`); a VBoxContainer with a
"Options" title (font size 32: `add_theme_font_size_override("font_size", 32)`), a "Music" label + `music_slider`, a "Sound effects" label + `sfx_slider`, and
`close_button` ("Close"). Sliders: `min_value = 0.0`, `max_value = 1.0`, `step = 0.05`,
`custom_minimum_size = Vector2(300, 24)`. Connect
`music_slider.value_changed.connect(func(v: float): volume_changed.emit("music", v))`, the same for
`sfx_slider` with `"sfx"`, and `close_button.pressed` -> emit `closed`. End with `hide()`.

`func set_values(music: float, sfx: float) -> void`: `set_value_no_signal` on both sliders.

**2. `scripts/ui/title_panel.gd`:** add `signal options_pressed` and `var options_button: Button`, a button with
text `"Options"` added to `box` after Play; pressed -> emit `options_pressed`.

**3. `scripts/game/main.gd`:** `var options_panel: OptionsPanel` on `ui_layer` (in `_build_ui()`). Connect
`title_panel.options_pressed` -> `open_options`, `options_panel.volume_changed` -> `_on_volume_changed`,
`options_panel.closed` -> `options_panel.hide`.
```gdscript
func open_options() -> void:
	options_panel.set_values(float(progress.settings.get("music_volume", 0.8)),
		float(progress.settings.get("sfx_volume", 0.8)))
	options_panel.show()


func _on_volume_changed(kind: String, value: float) -> void:
	progress.settings[kind + "_volume"] = value
	apply_settings()
	save_progress()
```

## Acceptance criteria
- Sliders 0..1; `set_values` doesn't emit; moving a slider emits `volume_changed("music", 0.3)` etc.
- Options on the title opens the panel with the saved volumes; moving the music slider applies and saves it; Close hides it.
