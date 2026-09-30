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
var combo: int = 0
var combo_left: float = 0.0

## Lively moments (stars, springs, balloons, hard bounces) this close together make a combo.
const COMBO_WINDOW: float = 1.2


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
	combo = 0
	combo_left = 0.0
	if projectile_view != null:
		projectile_view.set_mood("")
	if session.tracker != null:
		session.tracker.star_collected.connect(course_view.mark_collected)
		session.tracker.star_collected.connect(_on_star_collected)
		session.tracker.spring_hit.connect(_on_spring_hit)
		session.tracker.mud_hit.connect(_on_mud_hit)
	if session.sim != null:
		session.sim.bounced.connect(_on_bounced)
		session.sim.boosted.connect(_on_boosted)
	if session.balloons != null:
		session.balloons.popped.connect(_on_balloon_popped)


func _process(delta: float) -> void:
	tick_combo(delta)


func tick_combo(delta: float) -> void:
	if combo_left > 0.0:
		combo_left = maxf(combo_left - delta, 0.0)
		if combo_left <= 0.0:
			combo = 0


## Counts a lively moment. From the third one within COMBO_WINDOW of the last, pops up "Combo xN!".
## Returns the combo count.
func add_combo() -> int:
	combo = combo + 1 if combo_left > 0.0 else 1
	combo_left = COMBO_WINDOW
	if combo >= 3 and projectile_view != null and popups != null:
		var popup := FloatingText.new()
		popup.setup("Combo x%d!" % combo, Color(0.5, 1.0, 1.0))
		popup.position = projectile_view.position + Vector2(-40.0, -100.0)
		popups.add_child(popup)
	return combo


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
	if effects != null and projectile_view != null:
		effects.spawn_confetti(projectile_view.position + Vector2(0, -20))
	var popup := FloatingText.new()
	popup.setup(text, Color(1.0, 0.55, 0.9))
	popup.position = projectile_view.position + Vector2(-50.0, -80.0)
	if popups != null:
		popups.add_child(popup)
	return text


func _on_star_collected(index: int) -> void:
	if audio != null:
		audio.play_sfx("star")
	add_combo()
	if projectile_view != null:
		projectile_view.set_mood("wow", 0.8)
	if index >= 0 and course_view != null and index < course_view.sprites.size():
		if effects != null:
			effects.spawn_sparkle(course_view.sprites[index].position)
	var popup := FloatingText.new()
	popup.setup("+%d" % star_value, Color(1.0, 0.85, 0.2))
	popup.position = projectile_view.position + Vector2(-12.0, -40.0)
	if popups != null:
		popups.add_child(popup)


func _on_spring_hit(index: int) -> void:
	if audio != null:
		audio.play_sfx("spring")
	if camera != null:
		camera.shake(10.0, 0.35)
	add_combo()
	if index >= 0 and course_view != null and index < course_view.sprites.size():
		if effects != null:
			effects.spawn_burst(course_view.sprites[index].position)
	_say("Boing!", Color(0.6, 1.0, 0.6))


func _on_bounced(impact_speed: float) -> void:
	if audio != null:
		audio.play_sfx("bounce")
	if impact_speed >= 8.0 and camera != null:
		camera.shake(4.0, 0.2)
	if impact_speed >= 8.0:
		add_combo()
	if effects != null and projectile_view != null:
		effects.spawn_dust(projectile_view.position + Vector2(0, 12), impact_speed)
	if projectile_view != null:
		projectile_view.wobble(clampf(impact_speed / 25.0, 0.08, 0.35))
	bounces_seen += 1
	if bounces_seen >= 3 and projectile_view != null:
		projectile_view.set_mood("dizzy", 2.0)
	if critters != null and sim != null:
		var sheep := critters.react(sim.position.x)
		if sheep >= 0:
			var baa := FloatingText.new()
			baa.setup("Meh." if Critters.is_black(sheep) else "Baa!", Color.WHITE)
			baa.position = critters.sheep_position(sheep) + Vector2(-16.0, -48.0)
			if popups != null:
				popups.add_child(baa)


func _on_boosted() -> void:
	if audio != null:
		audio.play_sfx("boost")
	if effects != null and projectile_view != null:
		effects.spawn_flame(projectile_view.position)
	if camera != null:
		camera.shake(3.0, 0.15)
	if hud != null:
		hud.hide_hint()


## A short popup above the alien.
func _say(text: String, color: Color) -> void:
	if popups == null or projectile_view == null:
		return
	var popup := FloatingText.new()
	popup.setup(text, color)
	popup.position = projectile_view.position + Vector2(-24.0, -56.0)
	popups.add_child(popup)


func _on_mud_hit(_index: int) -> void:
	_say("Splat!", Color(0.6, 0.45, 0.3))
	if effects != null and projectile_view != null:
		effects.spawn_dust(projectile_view.position + Vector2(0, 12), 20.0)


func _on_balloon_popped(index: int) -> void:
	if audio != null:
		audio.play_sfx("spring")
	if projectile_view != null:
		projectile_view.set_mood("wow", 0.8)
	add_combo()
	if balloon_view != null and effects != null:
		effects.spawn_confetti(balloon_view.screen_position(index))
		balloon_view.pop(index)
	var pop := FloatingText.new()
	pop.setup("Pop!", Color(1.0, 0.6, 0.85))
	pop.position = projectile_view.position + Vector2(-16.0, -44.0)
	if popups != null:
		popups.add_child(pop)
