---
id: 161-best-buy
status: ready
tests: [tests/acceptance/test_161_best_buy.gd]
files: [scripts/ui/shop_panel.gd]
---

# Best buy in the shop

The shop highlights (green) the cheapest upgrade the player can afford.

**`scripts/ui/shop_panel.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes. (Edit 2 adds lines after the loop in `refresh()`, at the loop's outer indentation.)

Edit 1 - SEARCH:
```gdscript
var list: VBoxContainer
```
REPLACE:
```gdscript
var list: VBoxContainer
var best_buy: String = ""
```

Edit 2 - SEARCH:
```gdscript
		buttons[id].tooltip_text = str(d["description"])
```
REPLACE:
```gdscript
		buttons[id].tooltip_text = str(d["description"])
	best_buy = ""
	for id in UpgradeCatalog.ids():
		if progress.can_buy(id) and (best_buy == "" or progress.next_cost(id) < progress.next_cost(best_buy)):
			best_buy = id
	for id in UpgradeCatalog.ids():
		buttons[id].modulate = Color(0.75, 1.0, 0.75) if id == best_buy else Color.WHITE
```

## Acceptance criteria
- `best_buy` is the cheapest affordable upgrade ("" when none); only its button is green.
