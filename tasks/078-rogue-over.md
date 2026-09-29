---
id: 078-rogue-over
status: ready
tests: [tests/acceptance/test_078_rogue_over.gd]
files: [scripts/ui/rogue_over_panel.gd, scripts/core/progress.gd]
read: [scripts/core/rogue_run.gd, scripts/core/rogue_perks.gd]
---

# Roguelike run-over panel and best round

**1. Create `scripts/ui/rogue_over_panel.gd` with exactly this code:**
```gdscript
class_name RogueOverPanel
extends PanelContainer
## Roguelike: shown when the last life is lost. Rounds cleared, best, the perks taken, and Back to title.

signal back_pressed

var title_label: Label
var rounds_label: Label
var best_label: Label
var perks_label: Label
var back_button: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	custom_minimum_size = Vector2(480, 0)
	var box := VBoxContainer.new()
	add_child(box)
	title_label = Label.new()
	title_label.text = "Run over"
	title_label.add_theme_font_size_override("font_size", 32)
	box.add_child(title_label)
	rounds_label = Label.new()
	box.add_child(rounds_label)
	best_label = Label.new()
	box.add_child(best_label)
	perks_label = Label.new()
	perks_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	perks_label.custom_minimum_size = Vector2(440, 0)
	box.add_child(perks_label)
	back_button = Button.new()
	back_button.text = "Back to title"
	box.add_child(back_button)
	back_button.pressed.connect(func(): back_pressed.emit())
	hide()


func show_over(run: RogueRun, best_rounds: int) -> void:
	rounds_label.text = "Rounds cleared: %d" % run.rounds_cleared
	best_label.text = "Best: %d rounds" % best_rounds
	var names := PackedStringArray()
	for id in run.perks:
		names.append(str(RoguePerks.get_def(id).get("name", id)))
	perks_label.text = "Perks: %s" % (", ".join(names) if not names.is_empty() else "none")
	show()
```

**2. `scripts/core/progress.gd`** (keep everything else):
- **Declare the variable** at the top of the class, right after `var recent_distances ...` (without this line the
  script fails with `Identifier "best_rogue_round" not declared in the current scope`):
  ```gdscript
  var best_rogue_round: int = 0
  ```
- `to_dict()`: add the key `"best_rogue_round": best_rogue_round,` to the returned Dictionary.
- `from_dict()`: right before the final `return p`, add:
  ```gdscript
  	p.best_rogue_round = maxi(0, int(data.get("best_rogue_round", 0)))
  ```

## Acceptance criteria
- The panel says "Run over", "Rounds cleared: N", "Best: M rounds", "Perks: Stronger Bands, Steady Hand" (or
  "Perks: none"); Back to title emits `back_pressed`; the panel is on screen.
- `best_rogue_round` is saved and loaded as an int; old saves and negative values give 0.
