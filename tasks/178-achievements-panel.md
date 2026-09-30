---
id: 178-achievements-panel
status: ready
tests: [tests/acceptance/test_178_achievements_panel.gd]
files: [scripts/ui/achievements_panel.gd]
---

# Achievements panel

Milestone 22 adds menus that explain the game. First, an Achievements panel that lists every achievement, earned or not.

**Create the file `scripts/ui/achievements_panel.gd` with exactly this code** (use that exact path as the edit's file name):
```gdscript
class_name AchievementsPanel
extends PanelContainer
## Every achievement, earned or not, with how to earn it.

signal closed

var count_label: Label
var list_label: Label
var close_button: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	custom_minimum_size = Vector2(520, 0)
	var box := VBoxContainer.new()
	add_child(box)
	var title_label := Label.new()
	title_label.text = "Achievements"
	title_label.add_theme_font_size_override("font_size", 32)
	box.add_child(title_label)
	count_label = Label.new()
	box.add_child(count_label)
	list_label = Label.new()
	box.add_child(list_label)
	close_button = Button.new()
	close_button.text = "Close"
	close_button.pressed.connect(func(): closed.emit())
	box.add_child(close_button)
	hide()


## One line per achievement: "[x] Name - description" when earned, "[ ] Name - description" when not.
static func lines(progress: Progress) -> PackedStringArray:
	var out := PackedStringArray()
	for entry in Achievements.LIST:
		var mark := "[x]" if progress.achievements.has(entry["id"]) else "[ ]"
		out.append("%s %s - %s" % [mark, entry["name"], entry["description"]])
	return out


func show_list(progress: Progress) -> void:
	count_label.text = "%d of %d earned" % [progress.achievements.size(), Achievements.LIST.size()]
	list_label.text = "\n".join(lines(progress))
	show()
```

## Acceptance criteria
- `AchievementsPanel.lines(progress)` gives `[x] Name - description` for earned achievements and `[ ] Name - description` for the rest.
- `show_list(progress)` fills `count_label` (`1 of 6 earned`) and `list_label`, then shows the panel; Close emits `closed`.
