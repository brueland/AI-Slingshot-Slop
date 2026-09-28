---
id: 032-results-panel
status: ready
tests: [tests/acceptance/test_032_results_panel.gd]
files: [scripts/ui/results_panel.gd]
---

# Results panel

Create `scripts/ui/results_panel.gd`, the score breakdown shown after a run.

```gdscript
class_name ResultsPanel
extends PanelContainer
## The score breakdown after a run.

signal continue_pressed

var title_label: Label
var distance_label: Label
var stars_label: Label
var bounces_label: Label
var multiplier_label: Label
var total_label: Label
var coins_label: Label
var milestones_label: Label
var continue_button: Button
```

`_ready()`: center it (`set_anchors_preset(Control.PRESET_CENTER)`, `grow_horizontal` and `grow_vertical` =
`Control.GROW_DIRECTION_BOTH`, `custom_minimum_size = Vector2(420, 0)`), add a `VBoxContainer` with the eight
labels in the order above and then a Button with text `"Continue"`. Connect
`continue_button.pressed` to emit `continue_pressed`. Finish with `hide()`.

`func show_result(result: Dictionary, is_new_best: bool) -> void` sets these texts (the result has the keys
of RunSession.result() plus `milestones`, an Array of `{"distance", "reward", "name"}`), then `show()`:
- title: `"New best!"` if `is_new_best` else `"Run complete"`
- `"Distance: %d m" % distance_points`
- `"Stars: %d (+%d)" % [stars, star_points]`
- `"Bounces: %d (+%d)" % [bounces, bounce_points]`
- `"Multiplier: x%.2f" % multiplier`
- `"Total: %d" % total`
- `"Coins earned: +%d" % coins`
- milestones: one line per milestone, `"Milestone reached: %s (+%d)" % [name, reward]`, joined with `"\n"`;
  `""` and hidden (`visible = false`) when there are none, visible otherwise.

## Acceptance criteria
- Hidden until `show_result`; texts exactly as above; the Continue button emits `continue_pressed`.
