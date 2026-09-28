---
id: 034-shop-header
status: ready
tests: [tests/acceptance/test_034_shop_header.gd]
files: [scripts/ui/shop_panel.gd]
read: [scripts/core/upgrade_catalog.gd]
---

# Shop panel: coins, category headers and Launch!

Edit `scripts/ui/shop_panel.gd` (keep `buttons`, `refresh` and the signals). Add:

```gdscript
var header_labels: Dictionary = {}   # category -> Label
var coins_label: Label
var launch_button: Button
```

Rebuild the list in `_ready()` in this order, all children of `list`:
1. `coins_label` (font size 26).
2. For each `category` in `UpgradeCatalog.CATEGORIES`: a header Label with text
   `UpgradeCatalog.CATEGORY_NAMES[category]` (Slingshot / Projectile / Score, font size 22) stored in
   `header_labels[category]`, directly followed by the buttons of `UpgradeCatalog.ids_in_category(category)`
   (created and connected exactly as before).
3. `launch_button`: a Button with text `"Launch!"` whose `pressed` emits `launch_requested`.

In `refresh(progress)`, also set `coins_label.text = "Coins: %d" % progress.coins`.

## Acceptance criteria
- `coins_label` shows "Coins: 345" after refreshing with 345 coins.
- Three headers; each category's first button comes right after its header; Launch! is last and emits
  `launch_requested`.
