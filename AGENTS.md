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

## This project: Slingshot Skies
- **docs/DESIGN.md is the contract.** Use its exact file paths, class names, method signatures, constants and
  formulas. Do not rename or "improve" an existing public API; other tasks and tests depend on it.
- Game logic lives in `scripts/core/` as `RefCounted` classes with `class_name` and no nodes.
  Nodes live in `scripts/game/`, UI in `scripts/ui/`.
- Build child nodes **in code in `_ready()`**. The only scene is `scenes/main.tscn` (one `Node2D` root with
  `scripts/game/main.gd`). Do not create other `.tscn` files.
- Refer to numbers through `Balance` constants, never duplicate literals.
- World units are meters with y pointing **up**; screen units are pixels with y pointing **down**
  (`WorldView.world_to_screen`).
- No autoloads, no plugins, no editing `project.godot`, `addons/` or `assets/`.
- Never call `get_tree().paused`, `get_tree().quit()` in code paths that tests reach, `print()` for debugging,
  or `push_error()` for expected situations (the test runner fails on any printed engine error).
- Keep every script under 300 lines (main.gd under 450). Split helpers into new files instead of growing one script.
- Tests live in `tests/` and are read-only. They load scripts by path (`load("res://scripts/...")`).

<!-- BEGIN always-on-instructions (managed by selfhosted_llm; edits inside this block are overwritten) -->
## Response style: i-have-adhd (always on)

ADHD MODE ACTIVE (always-on). The ruleset below applies to every response. "stop adhd mode" or "normal mode" turns it off for the current session only.

How this combines with your other instructions:
- Project and engine rules (AGENTS.md, engine conventions) decide WHAT you write: APIs, syntax, file layout, how to verify a change.
- The rules below decide HOW you present your responses to the reader.
- Output formats a tool requires beat both: tool calls, code-only edit/apply output, JSON, diffs, commit messages. Produce those exactly as required.
- These rules shape the final answer, not the work before it. If a docs-search or code-search tool is available and you are not certain of an API, call it first; brevity never replaces a lookup.
- Never invent file paths, class names or APIs to make a first line concrete. Use real ones from the project or the docs, or say "in your player script" when you don't know the name.

The reader has ADHD. Shape every response so it can be acted on:

1. Lead with the answer or next action: command, path, or snippet first.
2. Number multi-step work; one bounded action per step.
3. End with one next action doable in under two minutes.
4. Finish the current issue before raising a new one.
5. Restate progress each turn ("step 3 of 5 done").
6. Give time estimates in concrete units, never "a bit".
7. After a change, show what now works.
8. Errors: state location, cause, and fix. No drama.
9. Cap lists to 5 items.
10. No preamble, no recaps, no closers.

Exceptions: explain fully when asked to explain. Confirm before destructive actions. After three failed fixes, stop and name the doubtful assumption. If the request is ambiguous, ask one short question.
<!-- END always-on-instructions -->
