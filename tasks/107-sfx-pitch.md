---
id: 107-sfx-pitch
status: ready
tests: [tests/acceptance/test_107_sfx_pitch.gd]
files: [scripts/game/audio_manager.gd]
---

# Varied sound pitch

Milestone 12 adds polish and features. Bounce, star and spring sounds play at a slightly random pitch (0.88 to
1.12) so repeats don't sound robotic; every other sound keeps its normal pitch.

**`scripts/game/audio_manager.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
const SFX_VOICES: int = 6
```
REPLACE:
```gdscript
const SFX_VOICES: int = 6
## These sounds get a slightly random pitch each time, so repeats don't sound robotic.
const PITCH_VARIED: Array[String] = ["bounce", "star", "spring"]
```

Edit 2 - SEARCH:
```gdscript
var sfx_played: int = 0
```
REPLACE:
```gdscript
var sfx_played: int = 0
var last_pitch: float = 1.0
var _pitch_rng := RandomNumberGenerator.new()
```

Edit 3 - SEARCH:
```gdscript
	player.stream = load(SFX[id])
```
REPLACE:
```gdscript
	player.stream = load(SFX[id])
	last_pitch = _pitch_rng.randf_range(0.88, 1.12) if PITCH_VARIED.has(id) else 1.0
	player.pitch_scale = last_pitch
```

## Acceptance criteria
- `PITCH_VARIED` is `["bounce", "star", "spring"]`; those play at a random pitch between 0.88 and 1.12
  (`last_pitch`, also set on the voice's `pitch_scale`); other sounds play at 1.0.
