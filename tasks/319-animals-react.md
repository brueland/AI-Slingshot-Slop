---
id: 319-animals-react
status: ready
tests: [tests/acceptance/test_319_animals_react.gd]
files: [scripts/game/critters.gd, scripts/game/cows.gd, scripts/game/world_builder.gd]
---

# The animals react

When the alien bounces off a sheep (task 318) the sheep hops and "Boing!" pops up; a cow that kicks it says
"Moo! Kick!". Critters and Cows get `watch(session)` and join Feedback's watchers in WorldBuilder.

**1. `scripts/game/critters.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds `watch()` and `_on_sheep_hit()` before `_draw()`; nothing else changes.

Edit 1 - SEARCH:
```gdscript
func _draw() -> void:
	# only the sheep on screen are drawn```
REPLACE:
```gdscript
## A new shot: a sheep the alien bounces off hops and says "Boing!" (FarmAnimals.sheep_hit).
func watch(session: RunSession) -> void:
	session.animals.sheep_hit.connect(_on_sheep_hit)


func _on_sheep_hit(x: float) -> void:
	react(x)
	var boing := FloatingText.new()
	boing.setup("Boing!", Color(1.0, 1.0, 0.85))
	boing.position = WorldView.ground_point(x) + Vector2(-24.0, -60.0)
	add_child(boing)


func _draw() -> void:
	# only the sheep on screen are drawn```

**2. `scripts/game/cows.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds `watch()` and `_on_cow_hit()` before `_draw()`; nothing else changes.

Edit 1 - SEARCH:
```gdscript
func _draw() -> void:
	# the herd repeats```
REPLACE:
```gdscript
## A new shot: a cow that kicks the alien says "Moo! Kick!" (FarmAnimals.cow_hit).
func watch(session: RunSession) -> void:
	session.animals.cow_hit.connect(_on_cow_hit)


func _on_cow_hit(x: float) -> void:
	var moo := FloatingText.new()
	moo.setup("Moo! Kick!", Color(1.0, 0.85, 0.75))
	moo.position = WorldView.ground_point(x) + Vector2(-40.0, -70.0)
	add_child(moo)


func _draw() -> void:
	# the herd repeats```

**3. `scripts/game/world_builder.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	main.feedback.watchers.append(wrong_way)
```
REPLACE:
```gdscript
	main.feedback.watchers.append(wrong_way)
	main.feedback.watchers.append(main.critters)
	main.feedback.watchers.append(main.cows)
```

## Acceptance criteria
- Sheep hits make the sheep hop with a "Boing!" popup; cow hits pop up "Moo! Kick!"; both follow every shot.
