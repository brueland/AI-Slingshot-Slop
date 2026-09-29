---
id: 063-hints
status: ready
tests: [tests/acceptance/test_063_hints.gd]
files: [scripts/ui/hud.gd, scripts/game/main.gd]
---

# First-time hints

**1. `scripts/ui/hud.gd`** (keep everything): a hint label at the bottom center of the screen.
```gdscript
const HINT_AIM: String = "Drag the alien back, aim, and let go!"
const HINT_BOOST: String = "Press Space in the air to boost!"

var hint_label: Label
```
In `_ready()` (before the initial `update_flight`/`update_progress` calls):
```gdscript
	hint_label = Label.new()
	hint_label.add_theme_font_size_override("font_size", 26)
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.anchor_left = 0.5
	hint_label.anchor_right = 0.5
	hint_label.anchor_top = 1.0
	hint_label.anchor_bottom = 1.0
	hint_label.offset_left = -320
	hint_label.offset_right = 320
	hint_label.offset_top = -90
	hint_label.offset_bottom = -50
	hint_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint_label.hide()
	add_child(hint_label)
```
Add `func show_hint(text: String) -> void` (set the text, `show()`) and `func hide_hint() -> void` (`hide()`).

**2. `scripts/game/main.gd`** (keep changes small):
- End of `_begin_aim()`: `hud.show_hint(Hud.HINT_AIM)` if `progress.total_runs == 0`, else `hud.hide_hint()`.
- In `launch_with_pull`, after `session.launch_from_pull(pull)`: `hud.show_hint(Hud.HINT_BOOST)` if
  `session.sim.boost_charges > 0`, else `hud.hide_hint()`.
- In `_on_boosted()`: `hud.hide_hint()`.

## Acceptance criteria
- The hint label is hidden by default, never blocks the mouse, and shows centered in the bottom half.
- The very first shot shows the aim hint until launch; with boosts, the boost hint shows until the first boost.
