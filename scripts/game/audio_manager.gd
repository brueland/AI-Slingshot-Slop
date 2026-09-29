class_name AudioManager
extends Node
## Music and sound effects.

const MUSIC: Dictionary = {
	"menu": "res://assets/audio/music/menu.ogg",
	"flight": "res://assets/audio/music/flight.ogg",
	"victory": "res://assets/audio/music/victory.ogg",
}

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

var music_player: AudioStreamPlayer
var current_music: String = ""
var sfx_players: Array[AudioStreamPlayer] = []
var last_sfx: String = ""
var sfx_played: int = 0
var _next_voice: int = 0

var music_volume: float = 0.8
var sfx_volume: float = 0.8


func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.name = "Music"
	add_child(music_player)
	
	# Create SFX players
	for i in range(SFX_VOICES):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.name = "Sfx" + str(i)
		add_child(player)
		sfx_players.append(player)


func play_music(id: String) -> void:
	if id == current_music or not MUSIC.has(id):
		return
	var stream: AudioStream = load(MUSIC[id])
	if stream is AudioStreamOggVorbis:
		stream.loop = id != "victory"
	music_player.stream = stream
	music_player.play()
	current_music = id


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


func stop_music() -> void:
	music_player.stop()
	current_music = ""


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
