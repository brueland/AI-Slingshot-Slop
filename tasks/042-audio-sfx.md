---
id: 042-audio-sfx
status: ready
tests: [tests/acceptance/test_042_audio_sfx.gd]
files: [scripts/game/audio_manager.gd]
---

# AudioManager: sound effects

Add sound effects to `scripts/game/audio_manager.gd` (keep the music code). Effects play on a pool of 6
players used round robin, so several can overlap.

```gdscript
const SFX: Dictionary = {
	"launch": "res://assets/audio/sfx/launch.mp3",
	"bounce": "res://assets/audio/sfx/bounce.mp3",
	"star": "res://assets/audio/sfx/star.mp3",
	"spring": "res://assets/audio/sfx/spring.mp3",
	"boost": "res://assets/audio/sfx/boost.mp3",
	"buy": "res://assets/audio/sfx/buy.mp3",
	"milestone": "res://assets/audio/sfx/milestone.mp3",
	"click": "res://assets/audio/sfx/click.wav",
}
const SFX_VOICES: int = 6

var sfx_players: Array[AudioStreamPlayer] = []
var last_sfx: String = ""
var sfx_played: int = 0
var _next_voice: int = 0
```

- In `_ready()`, after the music player, create `SFX_VOICES` AudioStreamPlayers named `"Sfx0"`..`"Sfx5"`,
  add them as children and append them to `sfx_players`.
- ```gdscript
  func play_sfx(id: String) -> bool:
  	if not SFX.has(id):
  		return false
  	var player := sfx_players[_next_voice]
  	_next_voice = (_next_voice + 1) % SFX_VOICES
  	player.stream = load(SFX[id])
  	player.play()
  	last_sfx = id
  	sfx_played += 1
  	return true
  ```

## Acceptance criteria
- 6 child players; every id above plays; unknown ids return false and count nothing.
- The 7th effect reuses player 0, the 8th player 1.
