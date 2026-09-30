---
id: 127-world-builder
status: ready
tests: [tests/acceptance/test_127_world_builder.gd]
files: [scripts/game/world_builder.gd, scripts/game/main.gd]
---

# Move the world set-up out of main.gd

A pure refactor to give main.gd room: the lines of `_ready()` that create the world nodes move into a new static
function `WorldBuilder.build(main)`. Same nodes, same order, still children of main. **Behavior must not change**;
all existing tests must keep passing.

**1. Create the file `scripts/game/world_builder.gd` with exactly this code** (use that exact path as the edit's file name):
```gdscript
class_name WorldBuilder
extends RefCounted
## Creates the world nodes of main.gd (sky, audio, ground, scenery, critters, course, slingshot, alien, camera,
## effects...) as children of main, in drawing order. New world decorations are added here, not in main.gd.


static func build(main: Node) -> void:
	main.background = SkyBackground.new()  # must be the first child
	main.add_child(main.background)
	main.audio = AudioManager.new()
	main.add_child(main.audio)
	main.apply_settings()
	main.fader = Fader.new()
	main.add_child(main.fader)
	main.world_view = WorldView.new()
	main.add_child(main.world_view)
	main.scenery = Scenery.new()
	main.add_child(main.scenery)
	main.scenery.build(Scenery.SEED, Balance.COURSE_LENGTH)
	main.critters = Critters.new()
	main.add_child(main.critters)
	main.critters.build(Critters.SEED, Balance.COURSE_LENGTH)
	main.birds = Birds.new()
	main.add_child(main.birds)
	main.ufo = Ufo.new()
	main.add_child(main.ufo)
	main.course_view = CourseView.new()
	main.add_child(main.course_view)
	main.balloon_view = BalloonView.new()
	main.add_child(main.balloon_view)
	main.slingshot = Slingshot.new()
	main.add_child(main.slingshot)
	main.trajectory = TrajectoryPreview.new()
	main.add_child(main.trajectory)
	main.ghost = GhostPath.new()
	main.add_child(main.ghost)
	main.trail = Trail.new()
	main.add_child(main.trail)
	main.shadow = GroundShadow.new()
	main.add_child(main.shadow)
	main.projectile_view = ProjectileView.new()
	main.add_child(main.projectile_view)
	main.camera = CameraRig.new()
	main.add_child(main.camera)
	main.popups = Node2D.new()
	main.add_child(main.popups)
	main.effects = Effects.new()
	main.add_child(main.effects)
	main.feedback = Feedback.new()
	main.add_child(main.feedback)
```

**2. `scripts/game/main.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE is the single line `WorldBuilder.build(self)`: the world nodes are now created by WorldBuilder. Nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
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
	birds = Birds.new()
	add_child(birds)
	ufo = Ufo.new()
	add_child(ufo)
	course_view = CourseView.new()
	add_child(course_view)
	balloon_view = BalloonView.new()
	add_child(balloon_view)
	slingshot = Slingshot.new()
	add_child(slingshot)
	trajectory = TrajectoryPreview.new()
	add_child(trajectory)
	ghost = GhostPath.new()
	add_child(ghost)
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
```
REPLACE:
```gdscript
	WorldBuilder.build(self)
```

## Acceptance criteria
- `WorldBuilder.build(main)` creates the same world nodes, in the same order, as children of main.
- main.gd's `_ready()` calls `WorldBuilder.build(self)` and no longer creates those nodes itself.
- All existing tests still pass.
