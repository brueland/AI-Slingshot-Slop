extends Node2D
## The game: owns Progress and the current RunSession and switches between states. See docs/DESIGN.md.

signal state_changed(new_state: int)

enum State { TITLE, AIM, FLIGHT, RESULTS, SHOP, VICTORY }

@export var save_path: String = SaveSystem.DEFAULT_PATH

var state: int = State.TITLE
var progress: Progress
var session: RunSession
var last_result: Dictionary = {}
var is_paused: bool = false


func _ready() -> void:
	progress = Progress.new()


func change_state(new_state: int) -> void:
	if new_state == state:
		return
	state = new_state
	emit_signal("state_changed", new_state)


func state_name() -> String:
	return State.keys()[state]


func start_game() -> void:
	if state != State.TITLE:
		return
	_begin_aim()


func _begin_aim() -> void:
	session = RunSession.new(progress.stats(), progress.total_runs + 1)
	change_state(State.AIM)
