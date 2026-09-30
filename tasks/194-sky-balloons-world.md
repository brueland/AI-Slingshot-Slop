---
id: 194-sky-balloons-world
status: ready
tests: [tests/acceptance/test_194_sky_balloons_world.gd]
files: [scripts/game/world_builder.gd]
---

# Hot-air balloons in the sky

WorldBuilder adds the hot-air balloons to the world, behind the course and the alien.

**`scripts/game/world_builder.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	var sock := WindSock.new()
	main.add_child(sock)
```
REPLACE:
```gdscript
	var sock := WindSock.new()
	main.add_child(sock)
	main.add_child(SkyBalloons.new())
```

## Acceptance criteria
- One SkyBalloons node, added right after the windsock (before the course and the alien).
