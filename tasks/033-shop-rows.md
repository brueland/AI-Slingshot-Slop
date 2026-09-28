---
id: 033-shop-rows
status: ready
tests: [tests/acceptance/test_033_shop_rows.gd]
files: [scripts/ui/shop_panel.gd]
read: [scripts/core/upgrade_catalog.gd, scripts/core/progress.gd]
---

# Shop panel: one button per upgrade

Create `scripts/ui/shop_panel.gd`.

```gdscript
class_name ShopPanel
extends PanelContainer
## Upgrade shop: one button per upgrade.

signal purchase_requested(id: String)
signal launch_requested

var buttons: Dictionary = {}      # upgrade id -> Button
var list: VBoxContainer
```

`_ready()`: center it like the results panel (`PRESET_CENTER`, grow both ways, `custom_minimum_size =
Vector2(520, 0)`), add `list`, and for each id in `UpgradeCatalog.ids()` add a Button named after the id
(`alignment = HORIZONTAL_ALIGNMENT_LEFT`), store it in `buttons[id]`, and connect its `pressed` so it emits
`purchase_requested(id)`: `button.pressed.connect(func(): purchase_requested.emit(id))`. End with `hide()`.
(`launch_requested` is used in task 034.)

`func refresh(progress: Progress) -> void`: for every id, with `d := UpgradeCatalog.get_def(id)`,
`level := progress.level_of(id)` and `cost := progress.next_cost(id)`:
- text: `"%s  Lv %d/%d  %d coins" % [d["name"], level, int(d["max_level"]), cost]`, or when `cost < 0`:
  `"%s  Lv %d/%d  MAX" % [d["name"], level, int(d["max_level"])]` (two spaces between the parts)
- `disabled = not progress.can_buy(id)`
- `tooltip_text = str(d["description"])`

## Acceptance criteria
- 9 buttons, hidden until shown. With 100 coins and power 1: "Band Power  Lv 1/10  136 coins" (disabled),
  "Tall Frame  Lv 0/5  60 coins" (enabled); maxed boosts: "Rocket Boosts  Lv 3/3  MAX" (disabled).
- Pressing a button emits `purchase_requested` with its id.
