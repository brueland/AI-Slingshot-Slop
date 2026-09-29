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
var title_panel: TitlePanel
var pause_label: Label
var victory_panel: VictoryPanel

# World nodes
var world_view: WorldView
var course_view: CourseView
var slingshot: Slingshot
var trajectory: TrajectoryPreview
var projectile_view: ProjectileView
var camera: CameraRig


func _ready() -> void:
	progress = SaveSystem.load_progress(save_path)
	
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
	
	victory_panel = VictoryPanel.new()
	ui_layer.add_child(victory_panel)
	
	shop_panel = ShopPanel.new()
	ui_layer.add_child(shop_panel)
	
	title_panel = TitlePanel.new()
	ui_layer.add_child(title_panel)
	
	# Create pause label
	pause_label = Label.new()
	pause_label.text = "Paused - press Esc to resume"
	pause_label.add_theme_font_size_override("font_size", 32)
	pause_label.set_anchors_preset(Control.PRESET_CENTER)
	pause_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	pause_label.grow_vertical = Control.GROW_DIRECTION_BOTH
	pause_label.hide()
	ui_layer.add_child(pause_label)
	
	results_panel.continue_pressed.connect(continue_to_shop)
	victory_panel.continue_pressed.connect(continue_to_shop)
	shop_panel.purchase_requested.connect(buy_upgrade)
	shop_panel.launch_requested.connect(leave_shop)
	title_panel.play_pressed.connect(start_game)
	title_panel.reset_pressed.connect(reset_progress)
	
	state_changed.connect(_on_state_changed)
	_update_ui()


func _physics_process(delta: float) -> void:
	advance(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("boost"):
		if request_boost():
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		toggle_pause()
		get_viewport().set_input_as_handled()


func change_state(new_state: int) -> void:
	if new_state == state:
		return
	state = new_state
	emit_signal("state_changed", new_state)


func save_progress() -> void:
	SaveSystem.save_progress(progress, save_path)


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
	if state == State.RESULTS or state == State.VICTORY:
		change_state(State.SHOP)


func buy_upgrade(id: String) -> bool:
	var success := state == State.SHOP and progress.buy(id)
	if success:
		shop_panel.refresh(progress)
		save_progress()
	return success


func leave_shop() -> void:
	if state == State.SHOP:
		_begin_aim()


func _finish_run() -> void:
	var previous_best := progress.best_distance
	var had_goal := progress.goal_reached
	last_result = session.result()
	last_result["milestones"] = progress.record_run(last_result["distance"], last_result["coins"])
	save_progress()
	last_result["new_best"] = last_result["distance"] > previous_best
	
	# Go to VICTORY state if this is the first time reaching the goal
	if progress.goal_reached and not had_goal:
		change_state(State.VICTORY)
	else:
		change_state(State.RESULTS)


func _on_state_changed(_new_state: int) -> void:
	_update_ui()


func _update_ui() -> void:
	hud.visible = state == State.AIM or state == State.FLIGHT
	if hud.visible:
		hud.update_progress(progress.best_distance, progress.coins)
	
	title_panel.visible = state == State.TITLE
	if title_panel.visible:
		title_panel.show_progress(progress.best_distance, progress.total_runs)
	
	if state == State.RESULTS:
		results_panel.show_result(last_result, bool(last_result.get("new_best", false)))
	else:
		results_panel.hide()
	
	if state == State.VICTORY:
		victory_panel.show_victory(progress.total_runs)
	else:
		victory_panel.hide()
	
	shop_panel.visible = state == State.SHOP
	if shop_panel.visible:
		shop_panel.refresh(progress)


func _update_aim() -> void:
	if not slingshot.dragging:
		trajectory.clear()
		return
	
	var stats := session.stats
	var v := LaunchMath.velocity_from_pull(slingshot.pull, Balance.MAX_PULL_PX, stats.max_speed)
	trajectory.update_preview(Vector2(0.0, stats.launch_height), v, stats.drag, stats.guide_points)
	
	# Move projectile into the pouch
	projectile_view.position = slingshot.pouch_position() + Vector2(0, -12)


func go_to_title() -> void:
	is_paused = false
	pause_label.hide()
	slingshot.cancel_drag()
	change_state(State.TITLE)
	_update_ui()


func reset_progress() -> void:
	progress = Progress.new()
	save_progress()
	_update_ui()


func toggle_pause() -> void:
	if state != State.AIM and state != State.FLIGHT:
		return
	is_paused = not is_paused
	pause_label.visible = is_paused
	slingshot.enabled = state == State.AIM and not is_paused
	if is_paused:
		slingshot.cancel_drag()
