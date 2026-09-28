---
id: 021-main-state-machine
status: ready
tests: [tests/acceptance/test_021_main_state_machine.gd]
files: [scenes/main.tscn, scripts/game/main.gd]
read: [scripts/core/progress.gd, scripts/core/run_session.gd, scripts/core/save_system.gd]
---

# Main scene and state machine skeleton

Create the game's only scene and its script.

**1. `scenes/main.tscn`**, exactly this text (one Node2D named Main with the script; no children):
```
[gd_scene format=3]

[ext_resource type="Script" path="res://scripts/game/main.gd" id="1_main"]

[node name="Main" type="Node2D"]
script = ExtResource("1_main")
```

**2. `scripts/game/main.gd`** (no class_name):
```gdscript
extends Node2D
## The game: owns Progress and the current RunSession and switches between states. See docs/DESIGN.md.

signal state_changed(new_state: int)

enum State { TITLE, AIM, FLIGHT, RESULTS, SHOP, VICTORY }

@export var save_path: String = SaveSystem.DEFAULT_PATH

var state: int = State.TITLE
var progress: Progress
var session: RunSession
var last_result: Dictionary = {}
var is_paused: bool = false
```
Functions:
- `_ready()`: `progress = Progress.new()` (task 037 will load it from `save_path` instead).
- `func change_state(new_state: int) -> void`: if it equals `state`, do nothing; otherwise set `state` and
  emit `state_changed(new_state)`.
- `func state_name() -> String`: `return State.keys()[state]` (e.g. "TITLE").
- `func start_game() -> void`: only when `state == State.TITLE`: call `_begin_aim()`.
- `func _begin_aim() -> void`: `session = RunSession.new(progress.stats(), progress.total_runs + 1)`, then
  `change_state(State.AIM)`.

`save_path` and `is_paused` are not used yet; later tasks use them, and tests already set `save_path`.

## Acceptance criteria
- The scene has one Node2D named Main with `scripts/game/main.gd` and no children in the file.
- It starts in TITLE with a fresh Progress; `start_game()` creates a session with seed 1 and switches to AIM once.
- `change_state` emits `state_changed` only when the state really changes.
