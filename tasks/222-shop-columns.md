---
id: 222-shop-columns
status: ready
tests: [tests/acceptance/test_222_shop_columns.gd, tests/acceptance/test_034_shop_header.gd]
files: [scripts/ui/shop_panel.gd]
---

# Shop in three columns

The shop gets one column per upgrade category (its header on top), with the coins above and a big orange Launch!
below, instead of one long list. One older test is updated.

**`scripts/ui/shop_panel.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Edit 1 adds one line after Launch! is added in `_ready()`; Edit 2 adds a function above `refresh()`. Each REPLACE keeps its SEARCH lines; nothing else changes.

Edit 1 - SEARCH:
```gdscript
	list.add_child(launch_button)
```
REPLACE:
```gdscript
	list.add_child(launch_button)
	_build_columns()
```

Edit 2 - SEARCH:
```gdscript
func refresh(progress: Progress) -> void:
```
REPLACE:
```gdscript
## One column per upgrade category (its header on top), with the coins above and a big Launch! below.
func _build_columns() -> void:
	custom_minimum_size = Vector2(1000, 0)
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 16)
	list.add_child(columns)
	list.move_child(columns, launch_button.get_index())
	for category in UpgradeCatalog.CATEGORIES:
		var column := VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		columns.add_child(column)
		header_labels[category].reparent(column)
		for id in UpgradeCatalog.ids_in_category(category):
			buttons[id].reparent(column)
			buttons[id].add_theme_font_size_override("font_size", 18)
	launch_button.theme_type_variation = "PrimaryButton"
	launch_button.add_theme_font_size_override("font_size", 30)
	launch_button.custom_minimum_size = Vector2(300, 0)
	launch_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER


func refresh(progress: Progress) -> void:
```

## Acceptance criteria
- `_build_columns()` moves each category's header and buttons into its own column; Launch! uses the PrimaryButton style.
- The shop is on screen and clear of the pop-ups at the top; every button still works.
