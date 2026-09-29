---
id: 043-music-per-state
status: ready
tests: [tests/acceptance/test_043_music_per_state.gd]
files: [scripts/game/main.gd]
read: [scripts/game/audio_manager.gd]
---

# Main: music for each screen

Edit `scripts/game/main.gd` (keep everything that works).

1. `var audio: AudioManager`. In `_ready()`, create it and `add_child(audio)` **before** `_build_ui()` and the
   first `_update_ui()` call.
2. At the end of `_update_ui()`, call a new function:
   ```gdscript
   func _update_music() -> void:
   	match state:
   		State.AIM, State.FLIGHT:
   			audio.play_music("flight")
   		State.VICTORY:
   			audio.play_music("victory")
   		_:
   			audio.play_music("menu")
   ```
   (`play_music` ignores the call when that track is already playing, so calling it often is fine.)

## Acceptance criteria
- `main.audio` is an AudioManager child of main.
- Menu music on the title, results and shop screens; flight music while aiming and flying; the victory tune on VICTORY.
