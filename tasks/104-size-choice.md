---
id: 104-size-choice
status: ready
tests: [tests/acceptance/test_104_size_choice.gd]
files: [scripts/ui/rogue_panel.gd]
read: [scripts/core/rogue_sizes.gd, scripts/core/rogue_run.gd]
---

# Choose the next shot's size

The roguelike perk panel gets a "Next shot size" row: Small, Normal and Big buttons (the chosen one stays pressed)
and a line describing the chosen size. Pressing a button sets the run's size, which the next shot uses (main.gd
does not change). Use small SEARCH/REPLACE edits in `scripts/ui/rogue_panel.gd`:

- Add `signal size_chosen(id: String)` after `signal reroll_pressed`.
- **Declare** after `var reroll_button: Button`:
  ```gdscript
  var size_label: Label
  var size_buttons: Dictionary = {}
  var current_run: RogueRun
  ```
- In `_ready()`, right before the line `var pick := Label.new()` (so the row is above "Choose a perk:"):
  ```gdscript
  	size_label = Label.new()
  	box.add_child(size_label)
  	var sizes := HBoxContainer.new()
  	box.add_child(sizes)
  	for entry in RogueSizes.LIST:
  		var id: String = entry["id"]
  		var size_button := Button.new()
  		size_button.text = entry["name"]
  		size_button.toggle_mode = true
  		size_button.pressed.connect(func(): _on_size(id))
  		sizes.add_child(size_button)
  		size_buttons[id] = size_button
  ```
- In `show_outcome()`, right before the final `show()`:
  ```gdscript
  	current_run = run
  	_show_size()
  ```
- Add these functions at the end of the file:
  ```gdscript
  ## The size row: "Next shot size: Big - ..." and the chosen size's button pressed.
  func _show_size() -> void:
  	var d := RogueSizes.get_def(current_run.size_id)
  	size_label.text = "Next shot size: %s - %s" % [d["name"], d["description"]]
  	for id in size_buttons:
  		var size_button: Button = size_buttons[id]
  		size_button.set_pressed_no_signal(id == current_run.size_id)


  func _on_size(id: String) -> void:
  	if current_run == null:
  		return
  	if current_run.set_size(id):
  		size_chosen.emit(id)
  	_show_size()
  ```

## Acceptance criteria
- After a roguelike shot the panel shows "Next shot size: Normal - balanced" with Normal pressed.
- Pressing Big sets the run's size, emits `size_chosen("big")`, updates the line and the pressed button.
- The next shot uses the chosen size; the size stays for later shots; the panel still fits on screen.
