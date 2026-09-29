---
id: 045-volume-settings
status: ready
tests: [tests/acceptance/test_045_volume_settings.gd]
files: [scripts/core/progress.gd, scripts/game/audio_manager.gd, scripts/game/main.gd]
---

# Saved volume settings

**1. `scripts/core/progress.gd`** (keep everything):
- `var settings: Dictionary = {"music_volume": 0.8, "sfx_volume": 0.8}`
- `to_dict()` also returns `"settings": settings.duplicate()`.
- `from_dict()`: if `data.get("settings")` is a Dictionary, for each key in `["music_volume", "sfx_volume"]`
  that it has, set `p.settings[key] = clampf(float(value), 0.0, 1.0)`. Missing keys keep the 0.8 defaults, so
  old saves still load.

**2. `scripts/game/audio_manager.gd`** (keep everything):
```gdscript
var music_volume: float = 0.8
var sfx_volume: float = 0.8


static func volume_to_db(volume: float) -> float:
	if volume <= 0.001:
		return -80.0
	return linear_to_db(volume)


func set_music_volume(volume: float) -> void:
	music_volume = clampf(volume, 0.0, 1.0)
	music_player.volume_db = volume_to_db(music_volume)


func set_sfx_volume(volume: float) -> void:
	sfx_volume = clampf(volume, 0.0, 1.0)
	for player in sfx_players:
		player.volume_db = volume_to_db(sfx_volume)
```

**3. `scripts/game/main.gd`** (keep everything):
```gdscript
func apply_settings() -> void:
	audio.set_music_volume(float(progress.settings.get("music_volume", 0.8)))
	audio.set_sfx_volume(float(progress.settings.get("sfx_volume", 0.8)))
```
Call it in `_ready()` right after creating `audio`, and in `reset_progress()` after saving.

## Acceptance criteria
- Settings survive `to_dict`/`from_dict` (and JSON); bad values are clamped; each Progress has its own dictionary.
- `volume_to_db(0.5)` is about -6.02 dB and 0 is -80 dB; the setters clamp and apply to the players.
- A save with music 0.25 and effects 0.5 is applied when main starts.
