---
id: 041-audio-music
status: ready
tests: [tests/acceptance/test_041_audio_music.gd]
files: [scripts/game/audio_manager.gd]
---

# AudioManager: music

Create `scripts/game/audio_manager.gd`. The music files already exist (ElvGames tracks, see CREDITS.md).

```gdscript
class_name AudioManager
extends Node
## Music and sound effects.

const MUSIC: Dictionary = {
	"menu": "res://assets/audio/music/menu.ogg",
	"flight": "res://assets/audio/music/flight.ogg",
	"victory": "res://assets/audio/music/victory.ogg",
}

var music_player: AudioStreamPlayer
var current_music: String = ""


func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.name = "Music"
	add_child(music_player)


func play_music(id: String) -> void:
	if id == current_music or not MUSIC.has(id):
		return
	var stream: AudioStream = load(MUSIC[id])
	if stream is AudioStreamOggVorbis:
		stream.loop = id != "victory"
	music_player.stream = stream
	music_player.play()
	current_music = id


func stop_music() -> void:
	music_player.stop()
	current_music = ""
```

## Acceptance criteria
- `music_player` is a child AudioStreamPlayer; menu and flight loop, victory plays once.
- Unknown ids are ignored; `stop_music()` clears `current_music`.
