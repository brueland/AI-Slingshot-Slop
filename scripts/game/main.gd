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


func _physics_process(delta: float) -> void:
	advance(delta)


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


func launch_with_pull(pull: Vector2) -> bool:
	if state != State.AIM or pull.length() < Balance.MIN_PULL_PX:
		return false
	session.launch_from_pull(pull)
	change_state(State.FLIGHT)
	return true


func advance(dt: float) -> void:
	if is_paused or state != State.FLIGHT:
		return
	session.step(dt)
	if session.is_finished():
		_finish_run()


func request_boost() -> bool:
	return state == State.FLIGHT and not is_paused and session.boost()


func continue_to_shop() -> void:
	if state == State.RESULTS:
		change_state(State.SHOP)


func buy_upgrade(id: String) -> bool:
	return state == State.SHOP and progress.buy(id)


func leave_shop() -> void:
	if state == State.SHOP:
		_begin_aim()


func _finish_run() -> void:
	last_result = session.result()
	last_result["milestones"] = progress.record_run(last_result["distance"], last_result["coins"])
	change_state(State.RESULTS)
