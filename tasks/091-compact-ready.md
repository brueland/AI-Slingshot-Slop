---
id: 091-compact-ready
status: ready
tests: [tests/acceptance/test_091_compact_ready.gd]
files: [scripts/game/main.gd]
---

# Compact main.gd's _ready()

main.gd must stay under 450 lines and milestone 10 adds features. This is a pure refactor: rewrite `_ready()`
without the blank lines and comment lines between the node creations. Nothing else changes (same nodes, same order,
same wiring). **Replace the whole `_ready()` function in `scripts/game/main.gd` with exactly this:**
```gdscript
func _ready() -> void:
	progress = SaveSystem.load_progress(save_path)
	background = SkyBackground.new()  # must be the first child
	add_child(background)
	audio = AudioManager.new()
	add_child(audio)
	apply_settings()
	fader = Fader.new()
	add_child(fader)
	world_view = WorldView.new()
	add_child(world_view)
	scenery = Scenery.new()
	add_child(scenery)
	scenery.build(Scenery.SEED, Balance.COURSE_LENGTH)
	critters = Critters.new()
	add_child(critters)
	critters.build(Critters.SEED, Balance.COURSE_LENGTH)
	course_view = CourseView.new()
	add_child(course_view)
	slingshot = Slingshot.new()
	add_child(slingshot)
	trajectory = TrajectoryPreview.new()
	add_child(trajectory)
	trail = Trail.new()
	add_child(trail)
	shadow = GroundShadow.new()
	add_child(shadow)
	projectile_view = ProjectileView.new()
	add_child(projectile_view)
	camera = CameraRig.new()
	add_child(camera)
	popups = Node2D.new()
	add_child(popups)
	effects = Effects.new()
	add_child(effects)
	feedback = Feedback.new()
	add_child(feedback)
	_build_ui()
	feedback.setup(audio, effects, camera, course_view, projectile_view, popups, hud)
	feedback.critters = critters
	projectile_view.set_hat(progress.hat)
	slingshot.launched.connect(launch_with_pull)
	camera.make_current()
```

## Acceptance criteria
- `_ready()` has fewer than 56 lines and no blank or comment-only lines.
- Same child nodes in the same order (the sky first), same wiring; all existing tests pass.
