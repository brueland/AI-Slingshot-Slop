---
id: 169-poke-mascot
status: ready
tests: [tests/acceptance/test_169_poke_mascot.gd]
files: [scripts/ui/title_mascot.gd]
---

# Poke the mascot

Clicking the alien on the title screen makes it jump (16 px for 0.4 s) and say "Hi!".

**`scripts/ui/title_mascot.gd`**: exactly these 4 SEARCH/REPLACE edit(s). Edits 1-3 keep their SEARCH lines and add new ones (Edit 3 adds three functions above `_process()`); Edit 4 replaces the `return` line of `center()`. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var time: float = 0.0
```
REPLACE:
```gdscript
var time: float = 0.0
var poke_left: float = 0.0
```

Edit 2 - SEARCH:
```gdscript
	time += delta
```
REPLACE:
```gdscript
	time += delta
	poke_left = maxf(0.0, poke_left - delta)
```

Edit 3 - SEARCH:
```gdscript
func _process(delta: float) -> void:
```
REPLACE:
```gdscript
## Clicking the mascot makes it jump (16 px, 0.4 s) and say "Hi!".
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		poke()


func poke() -> void:
	poke_left = 0.4
	var hi := FloatingText.new()
	hi.setup("Hi!", Color(0.7, 1.0, 0.7))
	hi.position = center() + Vector2(24.0, -40.0)
	add_child(hi)


## How high the poke jump lifts the alien right now (negative is up, 0 when not poked).
func poke_offset() -> float:
	if poke_left <= 0.0:
		return 0.0
	return -sin((0.4 - poke_left) / 0.4 * PI) * 16.0


func _process(delta: float) -> void:
```

Edit 4 - SEARCH:
```gdscript
	return Vector2(size.x / 2.0, 66.0 + bob_offset() + hop_offset())
```
REPLACE:
```gdscript
	return Vector2(size.x / 2.0, 66.0 + bob_offset() + hop_offset() + poke_offset())
```

## Acceptance criteria
- `poke()` sets `poke_left` to 0.4 and adds a `FloatingText` "Hi!"; `poke_offset()` is -16 halfway through, 0 when not poked.
- `_gui_input` pokes on a mouse press; the jump runs down in `_process`.
