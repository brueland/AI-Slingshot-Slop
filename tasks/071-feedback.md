---
id: 071-feedback
status: ready
tests: [tests/acceptance/test_071_feedback.gd]
files: [scripts/game/feedback.gd, scripts/game/main.gd]
read: [scripts/game/effects.gd, scripts/game/floating_text.gd]
---

# Move flight-event feedback out of main.gd

main.gd is getting long and the roguelike mode (tasks 074-080) needs room. This is a pure refactor: the sounds,
particles, popups and camera shake for stars, springs, bounces and boosts move into a new node. **Behavior must
not change** - the existing tests for these effects must keep passing.

**1. Create `scripts/game/feedback.gd` with exactly this code:**
```gdscript
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
var star_value: int = Balance.BASE_STAR_VALUE


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
	session.tracker.star_collected.connect(course_view.mark_collected)
	session.tracker.star_collected.connect(_on_star_collected)
	session.tracker.spring_hit.connect(_on_spring_hit)
	session.sim.bounced.connect(_on_bounced)
	session.sim.boosted.connect(_on_boosted)


func _on_star_collected(index: int) -> void:
	audio.play_sfx("star")
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


func _on_boosted() -> void:
	audio.play_sfx("boost")
	effects.spawn_flame(projectile_view.position)
	camera.shake(3.0, 0.15)
	hud.hide_hint()
```

**2. `scripts/game/main.gd`** (only these edits, keep everything else):
- Add `var feedback: Feedback` next to `var effects: Effects`.
- In `_ready()`, right after `add_child(effects)`:
  ```gdscript
  	feedback = Feedback.new()
  	add_child(feedback)
  ```
- In `_ready()`, right after the `_build_ui()` call:
  ```gdscript
  	feedback.setup(audio, effects, camera, course_view, projectile_view, popups, hud)
  ```
- In `_begin_aim()`, replace the five `session.tracker...connect(...)` / `session.sim...connect(...)` lines with
  the single line `feedback.watch(session)`.
- **Delete** the four functions `_on_star_collected`, `_on_spring_hit`, `_on_bounced` and `_on_boosted` from
  main.gd (they now live in feedback.gd). After this, main.gd must not contain `effects.spawn_` or
  `FloatingText.new()` anywhere.

## Acceptance criteria
- `main.feedback` is a Feedback child of main with the references above.
- Stars, springs, bounces and boosts still play their sounds, particles, popups and camera shake.
- main.gd no longer has the four handlers.
