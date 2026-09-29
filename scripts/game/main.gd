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

# UI nodes
var ui_layer: CanvasLayer
var hud: Hud
var results_panel: ResultsPanel
var shop_panel: ShopPanel

# World nodes
var world_view: WorldView
var course_view: CourseView
var slingshot: Slingshot
var trajectory: TrajectoryPreview
var projectile_view: ProjectileView
var camera: CameraRig


func _ready() -> void:
	progress = Progress.new()
	
	# Create world nodes
	world_view = WorldView.new()
	add_child(world_view)
	
	course_view = CourseView.new()
	add_child(course_view)
	
	slingshot = Slingshot.new()
	add_child(slingshot)
	
	trajectory = TrajectoryPreview.new()
	add_child(trajectory)
	
	projectile_view = ProjectileView.new()
	add_child(projectile_view)
	
	camera = CameraRig.new()
	add_child(camera)
	
	# Build UI
	_build_ui()
	
	# Connect signals
	slingshot.launched.connect(launch_with_pull)
	camera.make_current()


func _build_ui() -> void:
	ui_layer = CanvasLayer.new()
	add_child(ui_layer)
	
	hud = Hud.new()
	ui_layer.add_child(hud)
	
	results_panel = ResultsPanel.new()
	ui_layer.add_child(results_panel)
	
	shop_panel = ShopPanel.new()
	ui_layer.add_child(shop_panel)
	
	results_panel.continue_pressed.connect(continue_to_shop)
	shop_panel.purchase_requested.connect(buy_upgrade)
	shop_panel.launch_requested.connect(leave_shop)
	
	state_changed.connect(_on_state_changed)
	_update_ui()


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
	
	# Set up views for the new session
	course_view.build(session.course)
	session.tracker.star_collected.connect(course_view.mark_collected)
	var stats := session.stats
	slingshot.position = WorldView.world_to_screen(Vector2(0.0, stats.launch_height))
	slingshot.frame_height_px = stats.launch_height * Balance.PIXELS_PER_METER
	slingshot.enabled = true
	projectile_view.show_at(session.sim.position)
	projectile_view.rotation = 0.0
	camera.snap_to(projectile_view.position)
	trajectory.clear()
	
	change_state(State.AIM)


func launch_with_pull(pull: Vector2) -> bool:
	if state != State.AIM or pull.length() < Balance.MIN_PULL_PX:
		return false
	session.launch_from_pull(pull)
	change_state(State.FLIGHT)
	slingshot.enabled = false
	slingshot.cancel_drag()
	trajectory.clear()
	return true


func advance(dt: float) -> void:
	if is_paused:
		return
	
	if state == State.AIM:
		_update_aim()
	elif state == State.FLIGHT:
		session.step(dt)
		projectile_view.sync_from(session.sim)
		camera.follow(projectile_view.position, dt)
		hud.update_flight(session.sim.distance(), session.sim.position.y, session.tracker.stars_collected, session.sim.boost_charges)
		if session.is_finished():
			_finish_run()


func request_boost() -> bool:
	return state == State.FLIGHT and not is_paused and session.boost()


func continue_to_shop() -> void:
	if state == State.RESULTS:
		change_state(State.SHOP)


func buy_upgrade(id: String) -> bool:
	var success := state == State.SHOP and progress.buy(id)
	if success:
		shop_panel.refresh(progress)
	return success


func leave_shop() -> void:
	if state == State.SHOP:
		_begin_aim()


func _finish_run() -> void:
	var previous_best := progress.best_distance
	last_result = session.result()
	last_result["milestones"] = progress.record_run(last_result["distance"], last_result["coins"])
	last_result["new_best"] = last_result["distance"] > previous_best
	change_state(State.RESULTS)


func _update_aim() -> void:
	if not slingshot.dragging:
		trajectory.clear()
		return
	
	var stats := session.stats
	var v := LaunchMath.velocity_from_pull(slingshot.pull, Balance.MAX_PULL_PX, stats.max_speed)
	trajectory.update_preview(Vector2(0.0, stats.launch_height), v, stats.drag, stats.guide_points)
	
	# Move projectile into the pouch
	projectile_view.position = slingshot.pouch_position() + Vector2(0, -12)
