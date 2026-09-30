---
id: 168-surprise-hat
status: ready
tests: [tests/acceptance/test_168_surprise_hat.gd]
files: [scripts/ui/wardrobe_panel.gd, scripts/game/main.gd, scripts/ui/ui_root.gd]
---

# Surprise me!

The Wardrobe gets a "Surprise me!" button (right above Done) that puts on a random unlocked hat, a different one
when there is a choice.

**1. `scripts/ui/wardrobe_panel.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
signal closed
```
REPLACE:
```gdscript
signal closed
signal surprise_pressed
```

Edit 2 - SEARCH:
```gdscript
var worn: String = "none"
```
REPLACE:
```gdscript
var worn: String = "none"
var surprise_button: Button
```

Edit 3 - SEARCH:
```gdscript
	close_button = Button.new()
```
REPLACE:
```gdscript
	surprise_button = Button.new()
	surprise_button.text = "Surprise me!"
	surprise_button.pressed.connect(func(): surprise_pressed.emit())
	box.add_child(surprise_button)
	close_button = Button.new()
```

**2. `scripts/game/main.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
func choose_hat(id: String) -> bool:
```
REPLACE:
```gdscript
## Wears a random unlocked hat (a different one when there is a choice). Returns its id.
func choose_random_hat() -> String:
	var options := Hats.unlocked(progress)
	if options.size() > 1:
		options.erase(progress.hat)
	var id: String = options[randi() % options.size()]
	choose_hat(id)
	return id


func choose_hat(id: String) -> bool:
```

**3. `scripts/ui/ui_root.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	wardrobe_panel.hat_chosen.connect(Callable(main, "choose_hat"))
```
REPLACE:
```gdscript
	wardrobe_panel.hat_chosen.connect(Callable(main, "choose_hat"))
	wardrobe_panel.surprise_pressed.connect(Callable(main, "choose_random_hat"))
```

## Acceptance criteria
- `surprise_button` emits `surprise_pressed`, which `UiRoot.wire` connects to `main.choose_random_hat`.
- `choose_random_hat()` wears and returns a random unlocked hat other than the current one (the current one if it is the only hat).
