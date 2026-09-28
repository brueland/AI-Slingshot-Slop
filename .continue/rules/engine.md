---
name: godot conventions
alwaysApply: true
---

<!-- Generated from templates/godot/AGENTS.md by selfhosted_llm/scripts/70-new-project.ps1 -->

# Project conventions for AI assistants (Godot)

Engine: **Godot 4.7.2**, GDScript 2.0. Never write Godot 3.x syntax.

## Before writing code
- If you are not certain an engine class, method, property or signal exists in Godot 4, call the
  `search_docs` tool first. Do not guess API names.
- Read the existing scene (`.tscn`) and script before changing them; match their structure and naming.

## GDScript 4 rules (common mistakes to avoid)
| Use (Godot 4) | Never (Godot 3) |
|---|---|
| `@export var speed: float = 200.0` | `export var speed = 200` |
| `@onready var sprite: Sprite2D = $Sprite2D` | `onready var sprite = $Sprite2D` |
| `CharacterBody2D` / `CharacterBody3D` | `KinematicBody2D` / `KinematicBody` |
| `velocity` built-in property + `move_and_slide()` with no arguments | `move_and_slide(velocity, Vector2.UP)` |
| `signal_name.connect(_on_thing)` / `signal_name.emit(args)` | `connect("signal", self, "_method")` / `emit_signal(...)` |
| `await get_tree().create_timer(1.0).timeout` | `yield(get_tree().create_timer(1.0), "timeout")` |
| `super()` / `super.method()` | `.method()` |
| `Node3D`, `Sprite2D`, `TileMapLayer` | `Spatial`, `Sprite`, `TileMap` (deprecated) |
| `instantiate()` | `instance()` |
| `FileAccess.open(path, FileAccess.READ)` | `File.new()` |
| `deg_to_rad()`, `rad_to_deg()` | `deg2rad()`, `rad2deg()` |

- Use static typing everywhere (`var hp: int`, `func damage(amount: int) -> void:`).
- Use `class_name` for reusable scripts. Prefer signals over direct references between siblings.
- Put tunable values in `@export` variables or `Resource` files, not literals.

## Project layout
- `scenes/` scenes, `scripts/` scripts that are not attached 1:1 to a scene, `resources/` `.tres` data,
  `addons/` third-party code (do not edit).
- Scene and resource files are text. Edit them only when asked, and keep `[ext_resource]` ids consistent.

## Verifying changes
- Parse-check after editing: `godot --headless --check-only --script res://path/to/file.gd`
- Full project import check: `godot --headless --path . --quit`
- Run tests (if GUT/gdUnit is installed) before saying a change is done.
