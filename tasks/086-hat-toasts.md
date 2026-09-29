---
id: 086-hat-toasts
status: ready
tests: [tests/acceptance/test_086_hat_toasts.gd]
files: [scripts/game/main.gd, scripts/ui/results_panel.gd]
read: [scripts/core/hats.gd, scripts/ui/toast.gd]
---

# Announce new hats

When a run unlocks a hat, the player is told. A classic run lists new hats on the results screen (the toast is
kept for achievements); a roguelike run toasts them.

**1. `scripts/game/main.gd`** (only these edits in `_finish_run()`):
- Make this the **first line** of `_finish_run()` (before `if mode == "rogue":`):
  ```gdscript
  	var hats_before := Hats.unlocked(progress)
  ```
- In the roguelike branch, right before its `change_state(State.RESULTS)`:
  ```gdscript
  		for id in Hats.newly_unlocked(hats_before, progress):
  			toast.enqueue("New hat: %s" % Hats.get_def(id)["name"], "Try it on in the Wardrobe")
  ```
- In the classic part, right after the `for a in last_result["achievements"]:` loop (before `save_progress()`):
  ```gdscript
  	last_result["new_hats"] = Hats.newly_unlocked(hats_before, progress)
  ```

**2. `scripts/ui/results_panel.gd`** (keep everything else):
- **Declare** `var hats_label: Label` after `var milestones_label: Label`.
- In `_ready()`, right after `vbox.add_child(milestones_label)`:
  ```gdscript
  	hats_label = Label.new()
  	hats_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.4))
  	hats_label.visible = false
  	vbox.add_child(hats_label)
  ```
- In `show_result()`, right before the final `show()`:
  ```gdscript
  	var new_hats: Array = result.get("new_hats", [])
  	var names := PackedStringArray()
  	for id in new_hats:
  		names.append(str(Hats.get_def(str(id)).get("name", id)))
  	hats_label.text = "New hat: %s! Try it on in the Wardrobe" % ", ".join(names)
  	hats_label.visible = not new_hats.is_empty()
  ```

## Acceptance criteria
- After the first classic run `last_result["new_hats"]` is `["party"]` and the results screen shows
  "New hat: Party Hat! Try it on in the Wardrobe"; the next run shows no hat line.
- A roguelike run that sets a best of 5+ rounds toasts "New hat: Wizard Hat".
