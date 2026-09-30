---
id: 122-twinkle-wave
status: ready
tests: [tests/acceptance/test_122_twinkle_wave.gd]
files: [scripts/game/course_view.gd]
---

# Twinkling stars and waving flags

Stars on the course gently pulse and the milestone flags sway.

**`scripts/game/course_view.gd`**: exactly these 4 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var best_label: Label
```
REPLACE:
```gdscript
var best_label: Label
var star_indices: Array[int] = []
var time: float = 0.0
```

Edit 2 - SEARCH:
```gdscript
			sprite.scale = Vector2(0.5, 0.5)
```
REPLACE:
```gdscript
			sprite.scale = Vector2(0.5, 0.5)
			star_indices.append(i)
```

Edit 3 - SEARCH:
```gdscript
	sprites.clear()
```
REPLACE:
```gdscript
	sprites.clear()
	star_indices.clear()
```

Edit 4 - SEARCH:
```gdscript
func clear() -> void:
```
REPLACE:
```gdscript
func _process(delta: float) -> void:
	advance(delta)


## Stars gently pulse and the milestone flags sway.
func advance(delta: float) -> void:
	time += delta
	for i in star_indices:
		if i < sprites.size():
			sprites[i].scale = Vector2(0.5, 0.5) * (1.0 + 0.1 * sin(time * 4.0 + i))
	for k in flags.size():
		flags[k].rotation = sin(time * 2.0 + k) * 0.06


func clear() -> void:
```

## Acceptance criteria
- `star_indices` lists the course's stars; `advance()` pulses them (0.45-0.55 scale) and sways the flags (at most 0.06 rad).
- Springs and mud keep their size; `build()` resets the star list.
