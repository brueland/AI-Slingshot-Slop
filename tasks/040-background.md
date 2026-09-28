---
id: 040-background
status: ready
tests: [tests/acceptance/test_040_background.gd]
files: [scripts/game/background.gd, scripts/game/main.gd]
---

# Parallax sky background

**1. Create `scripts/game/background.gd`** with two `Parallax2D` layers (Godot 4.3+; they follow the camera by
themselves):
```gdscript
class_name SkyBackground
extends Node2D
## Parallax sky and clouds behind the world. Parallax2D layers follow the camera on their own.

const SKY_TEXTURE: String = "res://assets/backgrounds/sky.png"
const CLOUD_TEXTURE: String = "res://assets/sprites/cloud.png"

var layers: Array[Parallax2D] = []
```
`_ready()`:
- `z_index = -10` (behind everything).
- Sky layer: `Parallax2D` with `scroll_scale = Vector2(0.1, 0.05)`, `repeat_size = Vector2(1536, 0)`,
  `repeat_times = 3`, and one child `Sprite2D` with the sky texture (`centered = false`, `scale = Vector2(1.5, 1.5)`,
  `position = Vector2(-768, -1400)`). Add it, append to `layers`.
- Cloud layer: `Parallax2D` with `scroll_scale = Vector2(0.3, 0.2)`, `repeat_size = Vector2(1600, 0)`,
  `repeat_times = 3`, and 4 cloud `Sprite2D`s at `Vector2(i * 400, -420 - (i % 2) * 140)`. Add it, append to `layers`.

**2. Edit `scripts/game/main.gd`:** `var background: SkyBackground`; in `_ready()`, right after loading
progress, create it and `add_child(background)` **before** every other child, so it is `get_child(0)` and is
drawn first.

## Acceptance criteria
- Two Parallax2D layers, the sky slower than the clouds, both slower than 1; the sky sprite uses sky.png; several clouds.
- `main.background` is main's first child.
