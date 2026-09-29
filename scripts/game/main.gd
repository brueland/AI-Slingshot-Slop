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
var mode: String = "classic"        # "classic" or "rogue"
var rogue: RogueRun
var rogue_outcome: Dictionary = {}

# Audio
var audio: AudioManager

# UI nodes
var fader: Fader
var ui_layer: UiRoot
var hud: Hud
var results_panel: ResultsPanel
var shop_panel: ShopPanel
var title_panel: TitlePanel
var pause_label: Label
var victory_panel: VictoryPanel
var options_panel: OptionsPanel
var credits_panel: CreditsPanel
var stats_panel: StatsPanel
var toast: Toast
var wardrobe_panel: WardrobePanel
var ui_theme: Theme

# World nodes
var background: SkyBackground
var world_view: WorldView
var scenery: Scenery
var course_view: CourseView
var slingshot: Slingshot
var trajectory: TrajectoryPreview
var projectile_view: ProjectileView
var camera: CameraRig
var popups: Node2D
var trail: Trail
var shadow: GroundShadow
var effects: Effects
var feedback: Feedback


func _ready() -> void:
	progress = SaveSystem.load_progress(save_path)
	
	# Create background first (it must be the first child)
	background = SkyBackground.new()
	add_child(background)
	
	# Create audio after background
	audio = AudioManager.new()
	add_child(audio)
	
	# Apply saved settings
	apply_settings()
	
	# Create fader before UI
	fader = Fader.new()
	add_child(fader)
	
	# Build UI first so we can access panels
	_build_ui()
	
	# Create world nodes
	world_view = WorldView.new()
	add_child(world_view)
	
	scenery = Scenery.new()
	add_child(scenery)
	scenery.build(Scenery.SEED, Balance.COURSE_LENGTH)
	
	course_view = CourseView.new()
	add_child(course_view)
	
	slingshot = Slingshot.new()
	add_child(slingshot)
	
	trajectory = TrajectoryPreview.new()
	add_child(trajectory)
	
	trail = Trail.new()
	add_child(trail)
	
	# Create and add shadow node
	shadow = GroundShadow.new()
	add_child(shadow)
	
	projectile_view = ProjectileView.new()
	add_child(projectile_view)
	
	camera = CameraRig.new()
	add_child(camera)
	
	# Create popups node for floating text
	popups = Node2D.new()
	add_child(popups)
	
	# Create effects node
	effects = Effects.new()
	add_child(effects)
	
	feedback = Feedback.new()
	add_child(feedback)
	
	feedback.setup(audio, effects, camera, course_view, projectile_view, popups, hud)
	
	# Set the initial hat
	projectile_view.set_hat(progress.hat)
	
	# Connect signals - now that wardrobe_panel is properly initialized
	slingshot.launched.connect(launch_with_pull)
	camera.make_current()


func _build_ui() -> void:
	ui_layer = UiRoot.new()
	add_child(ui_layer)
	
	ui_theme = ui_layer.ui_theme
	hud = ui_layer.hud
	results_panel = ui_layer.results_panel
	victory_panel = ui_layer.victory_panel
	shop_panel = ui_layer.shop_panel
	title_panel = ui_layer.title_panel
	pause_label = ui_layer.pause_label
	options_panel = ui_layer.options_panel
	credits_panel = ui_layer.credits_panel
	stats_panel = ui_layer.stats_panel
	toast = ui_layer.toast
	wardrobe_panel = ui_layer.wardrobe_panel
	
	# Connect signals after all UI components are initialized
	results_panel.continue_pressed.connect(continue_to_shop)
	victory_panel.continue_pressed.connect(continue_to_shop)
	shop_panel.purchase_requested.connect(buy_upgrade)
	shop_panel.launch_requested.connect(leave_shop)
	title_panel.play_pressed.connect(start_game)
	title_panel.rogue_pressed.connect(start_rogue)
	ui_layer.rogue_panel.perk_chosen.connect(choose_rogue_perk)
	ui_layer.rogue_over_panel.back_pressed.connect(go_to_title)
	title_panel.wardrobe_pressed.connect(func(): wardrobe_panel.show_hats(progress))
	wardrobe_panel.hat_chosen.connect(choose_hat)
	wardrobe_panel.closed.connect(wardrobe_panel.hide)
	title_panel.reset_pressed.connect(reset_progress)
	title_panel.options_pressed.connect(open_options)
	title_panel.credits_pressed.connect(credits_panel.show)
	title_panel.stats_pressed.connect(func(): stats_panel.show_stats(progress))
	stats_panel.closed.connect(stats_panel.hide)
	credits_panel.closed.connect(credits_panel.hide)
	options_panel.volume_changed.connect(_on_volume_changed)
	options_panel.closed.connect(options_panel.hide)
	
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


func start_rogue(run_seed: int = 0) -> void:
	if state != State.TITLE:
		return
	mode = "rogue"
	rogue = RogueRun.new()
	rogue.start(run_seed if run_seed > 0 else randi_range(1, 99999))
	_begin_aim()


func choose_rogue_perk(id: String) -> bool:
	if mode != "rogue" or state != State.RESULTS or not rogue.choose_perk(id):
		return false
	_begin_aim()
	return true


func _begin_aim() -> void:
	if mode == "rogue":
		session = RunSession.new(rogue.stats(), rogue.shot_seed())
	else:
		session = RunSession.new(progress.stats(), progress.total_runs + 1)
	
	# Set up views for the new session
	course_view.build(session.course)
	course_view.set_best_marker(progress.best_distance)
	feedback.watch(session)
	var stats := session.stats
	slingshot.position = WorldView.world_to_screen(Vector2(0.0, stats.launch_height))
	slingshot.apply_stats(stats, progress.level_of("power"))
	projectile_view.set_tier(floori(progress.level_of("aero") / 2.0))
	slingshot.enabled = true
	slingshot.show_last_aim = rogue.has_perk("steady") if mode == "rogue" else progress.level_of("guide") >= 1
	projectile_view.show_at(session.sim.position)
	projectile_view.rotation = 0.0
	camera.snap_to(projectile_view.position)
	trajectory.clear()
	trail.clear_trail()
	shadow.update_from(session.sim.position)
	background.set_altitude(0.0)
	
	# Show hint for first run or when boosts are available
	if progress.total_runs == 0:
		hud.show_hint(Hud.HINT_AIM)
	else:
		hud.hide_hint()
	
	change_state(State.AIM)


func launch_with_pull(pull: Vector2) -> bool:
	if state != State.AIM or pull.length() < Balance.MIN_PULL_PX:
		return false
	session.launch_from_pull(pull)
	audio.play_sfx("launch")
	change_state(State.FLIGHT)
	slingshot.enabled = false
	slingshot.cancel_drag()
	trajectory.clear()
	
	# Show boost hint if boosts are available
	if session.sim.boost_charges > 0:
		hud.show_hint(Hud.HINT_BOOST)
	else:
		hud.hide_hint()
	
	return true


func advance(dt: float) -> void:
	if is_paused:
		return
	
	if state == State.AIM:
		_update_aim()
	elif state == State.FLIGHT:
		session.step(dt)
		projectile_view.sync_from(session.sim)
		trail.add_trail_point(projectile_view.position)
		shadow.update_from(session.sim.position)
		camera.follow(projectile_view.position, dt)
		hud.update_flight(session.sim.distance(), session.sim.position.y, session.tracker.stars_collected, session.sim.boost_charges)
		background.set_altitude(session.sim.position.y)
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
		audio.play_sfx("buy")
		shop_panel.refresh(progress)
		save_progress()
	return success


func leave_shop() -> void:
	if state == State.SHOP:
		_begin_aim()


func _finish_run() -> void:
	var hats_before := Hats.unlocked(progress)
	if mode == "rogue":
		last_result = session.result()
		rogue_outcome = rogue.finish_shot(last_result)
		if rogue.is_over():
			progress.best_rogue_round = maxi(progress.best_rogue_round, rogue.rounds_cleared)
			save_progress()
		for id in Hats.newly_unlocked(hats_before, progress):
			toast.enqueue("New hat: %s" % Hats.get_def(id)["name"], "Try it on in the Wardrobe")
		change_state(State.RESULTS)
		return
	
	var previous_best := progress.best_distance
	var had_goal := progress.goal_reached
	last_result = session.result()
	last_result["milestones"] = progress.record_run(last_result["distance"], last_result["coins"])
	progress.record_lifetime(last_result)
	if not last_result["milestones"].is_empty():
		audio.play_sfx("milestone")
	last_result["achievements"] = Achievements.unlock(last_result, progress)
	for a in last_result["achievements"]:
		toast.enqueue("Achievement unlocked: %s" % a["name"], a["description"])
	last_result["new_hats"] = Hats.newly_unlocked(hats_before, progress)
	save_progress()
	last_result["new_best"] = last_result["distance"] > previous_best
	
	# Go to VICTORY state if this is the first time reaching the goal
	if progress.goal_reached and not had_goal:
		change_state(State.VICTORY)
	else:
		change_state(State.RESULTS)


func _on_state_changed(new_state: int) -> void:
	if new_state != State.FLIGHT:
		fader.flash()
	_update_ui()




func _update_ui() -> void:
	ui_layer.refresh(self)
	audio.play_music(AudioManager.music_for_state(state_name()))


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
	mode = "classic"
	is_paused = false
	pause_label.hide()
	slingshot.cancel_drag()
	change_state(State.TITLE)
	_update_ui()


func reset_progress() -> void:
	progress = Progress.new()
	projectile_view.set_hat(progress.hat)
	save_progress()
	apply_settings()
	_update_ui()


func open_options() -> void:
	options_panel.set_values(float(progress.settings.get("music_volume", 0.8)),
		float(progress.settings.get("sfx_volume", 0.8)))
	options_panel.show()


func choose_hat(id: String) -> bool:
	if not Hats.is_unlocked(id, progress):
		return false
	progress.hat = id
	projectile_view.set_hat(id)
	save_progress()
	wardrobe_panel.show_hats(progress)
	return true


func _on_volume_changed(kind: String, value: float) -> void:
	progress.settings[kind + "_volume"] = value
	apply_settings()
	save_progress()


func apply_settings() -> void:
	audio.set_music_volume(float(progress.settings.get("music_volume", 0.8)))
	audio.set_sfx_volume(float(progress.settings.get("sfx_volume", 0.8)))


func toggle_pause() -> void:
	if state != State.AIM and state != State.FLIGHT:
		return
	is_paused = not is_paused
	pause_label.visible = is_paused
	slingshot.enabled = state == State.AIM and not is_paused
	if is_paused:
		slingshot.cancel_drag()
