---
id: 296-perk-screen-menu
status: ready
tests: [tests/acceptance/test_296_perk_screen_menu.gd]
files: [scripts/ui/rogue_panel.gd, scripts/ui/ui_root.gd]
---

# A Menu button on the perk screen

The HUD's Menu button is hidden on the roguelike perk screen, and main.gd only pauses while aiming or flying, so
there was no way to reach Options or Quit to title there. RoguePanel gets a Menu button (`menu_pressed`); UiRoot
shows the pause menu in place of the perk screen, and Resume there closes the menu and shows the perk screen again.

**1. `scripts/ui/rogue_panel.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
signal size_chosen(id: String)
```
REPLACE:
```gdscript
signal size_chosen(id: String)
## The Menu button: the pause menu (Resume, Options, Quit to title) in place of the perk screen.
signal menu_pressed
```

Edit 2 - SEARCH:
```gdscript
var reroll_button: Button
```
REPLACE:
```gdscript
var reroll_button: Button
var menu_button: Button
```

Edit 3 - SEARCH:
```gdscript
	reroll_button = Button.new()
	reroll_button.pressed.connect(func(): reroll_pressed.emit())
	box.add_child(reroll_button)
```
REPLACE:
```gdscript
	reroll_button = Button.new()
	reroll_button.pressed.connect(func(): reroll_pressed.emit())
	box.add_child(reroll_button)
	menu_button = Button.new()
	menu_button.text = "Menu"
	menu_button.pressed.connect(func(): menu_pressed.emit())
	box.add_child(menu_button)
```

**2. `scripts/ui/ui_root.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Edit 1 adds two connections in `wire()`; edit 2 adds `open_results_menu()` and `close_results_menu()` right before `wire()`. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
	rogue_panel.reroll_pressed.connect(Callable(main, "reroll_perks"))
```
REPLACE:
```gdscript
	rogue_panel.reroll_pressed.connect(Callable(main, "reroll_perks"))
	rogue_panel.menu_pressed.connect(open_results_menu)
	pause_menu.resume_pressed.connect(close_results_menu.bind(main))
```

Edit 2 - SEARCH:
```gdscript
## Connects every screen's buttons to main.gd (`main` is the node running scripts/game/main.gd).
func wire(main: Node) -> void:
```
REPLACE:
```gdscript
## The perk screen's Menu button: the pause menu in its place (Resume brings the perk screen back).
func open_results_menu() -> void:
	rogue_panel.hide()
	pause_menu.show()


## Resume while not playing (the perk screen's menu; main.gd only pauses while aiming or flying): close the menu
## and show the screens of the state again.
func close_results_menu(main: Node) -> void:
	if main.state_name() != "AIM" and main.state_name() != "FLIGHT":
		pause_menu.hide()
		refresh(main)


## Connects every screen's buttons to main.gd (`main` is the node running scripts/game/main.gd).
func wire(main: Node) -> void:
```

## Acceptance criteria
- `RoguePanel.menu_button` ("Menu") emits `menu_pressed`; the pause menu replaces the perk screen until Resume.
- Options and Quit to title work from there.
