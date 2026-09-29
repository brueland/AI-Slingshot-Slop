class_name Feedback
extends Node
## Sounds, particles, popups and camera shake for flight events. main.gd gives it the nodes it needs once
## (setup) and hands it every new RunSession (watch).

var audio: AudioManager
var effects: Effects
var camera: CameraRig
var course_view: CourseView
var projectile_view: ProjectileView
var popups: Node2D
var hud: Hud
var critters: Critters
var sim: FlightSim
var balloon_view: BalloonView
var star_value: int = Balance.BASE_STAR_VALUE
var bounces_seen: int = 0


func setup(p_audio: AudioManager, p_effects: Effects, p_camera: CameraRig, p_course_view: CourseView,
		p_projectile_view: ProjectileView, p_popups: Node2D, p_hud: Hud) -> void:
	audio = p_audio
	effects = p_effects
	camera = p_camera
	course_view = p_course_view
	projectile_view = p_projectile_view
	popups = p_popups
	hud = p_hud


func watch(session: RunSession) -> void:
	star_value = session.stats.star_value
	sim = session.sim
	bounces_seen = 0
	projectile_view.set_mood("")
	session.tracker.star_collected.connect(course_view.mark_collected)
	session.tracker.star_collected.connect(_on_star_collected)
	session.tracker.spring_hit.connect(_on_spring_hit)
	session.sim.bounced.connect(_on_bounced)
	session.sim.boosted.connect(_on_boosted)
	session.balloons.popped.connect(_on_balloon_popped)


## Confetti and a big popup for great moments: a new best, a milestone, or a roguelike goal met.
## Returns the popup text ("" when there is nothing to celebrate).
func celebrate(result: Dictionary) -> String:
	var milestones: Array = result.get("milestones", [])
	var text := ""
	if bool(result.get("new_best", false)):
		text = "NEW BEST!"
	elif not milestones.is_empty():
		text = "Milestone!"
	elif bool(result.get("goal_met", false)):
		text = "Goal!"
	if text == "":
		return ""
	effects.spawn_confetti(projectile_view.position + Vector2(0, -20))
	var popup := FloatingText.new()
	popup.setup(text, Color(1.0, 0.55, 0.9))
	popup.position = projectile_view.position + Vector2(-50.0, -80.0)
	popups.add_child(popup)
	return text


func _on_star_collected(index: int) -> void:
	audio.play_sfx("star")
	projectile_view.set_mood("wow", 0.8)
	if index >= 0 and index < course_view.sprites.size():
		effects.spawn_sparkle(course_view.sprites[index].position)
	var popup := FloatingText.new()
	popup.setup("+%d" % star_value, Color(1.0, 0.85, 0.2))
	popup.position = projectile_view.position + Vector2(-12.0, -40.0)
	popups.add_child(popup)


func _on_spring_hit(index: int) -> void:
	audio.play_sfx("spring")
	camera.shake(10.0, 0.35)
	if index >= 0 and index < course_view.sprites.size():
		effects.spawn_burst(course_view.sprites[index].position)


func _on_bounced(impact_speed: float) -> void:
	audio.play_sfx("bounce")
	if impact_speed >= 8.0:
		camera.shake(4.0, 0.2)
	effects.spawn_dust(projectile_view.position + Vector2(0, 12), impact_speed)
	projectile_view.wobble(clampf(impact_speed / 25.0, 0.08, 0.35))
	bounces_seen += 1
	if bounces_seen >= 3:
		projectile_view.set_mood("dizzy", 2.0)
	if critters != null and sim != null:
		var sheep := critters.react(sim.position.x)
		if sheep >= 0:
			var baa := FloatingText.new()
			baa.setup("Baa!", Color.WHITE)
			baa.position = critters.sheep_position(sheep) + Vector2(-16.0, -48.0)
			popups.add_child(baa)


func _on_boosted() -> void:
	audio.play_sfx("boost")
	effects.spawn_flame(projectile_view.position)
	camera.shake(3.0, 0.15)
	hud.hide_hint()


func _on_balloon_popped(index: int) -> void:
	audio.play_sfx("spring")
	projectile_view.set_mood("wow", 0.8)
	if balloon_view != null:
		effects.spawn_confetti(balloon_view.screen_position(index))
		balloon_view.pop(index)
	var pop := FloatingText.new()
	pop.setup("Pop!", Color(1.0, 0.6, 0.85))
	pop.position = projectile_view.position + Vector2(-16.0, -44.0)
	popups.add_child(pop)
