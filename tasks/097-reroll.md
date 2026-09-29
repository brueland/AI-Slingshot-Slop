---
id: 097-reroll
status: ready
tests: [tests/acceptance/test_097_reroll.gd]
files: [scripts/core/rogue_run.gd, scripts/ui/rogue_panel.gd, scripts/game/main.gd]
read: [scripts/core/rogue_perks.gd]
---

# Reroll the perk offer

In the roguelike the player may swap the three offered perks for three others: one reroll per run, plus one for
every 5 rounds cleared.

**1. `scripts/core/rogue_run.gd`** (keep everything else):
- **Declare** `var rerolls: int = 1` after `var offer: Array[String] = []`.
- In `start()`, right after `shots = 0`: `rerolls = 1`
- In `finish_shot()`, inside `if met:`, right after `round_number += 1`:
  ```gdscript
  		if rounds_cleared % 5 == 0:
  			rerolls += 1
  ```
- Add this function right before `choose_perk()`:
  ```gdscript
  ## Swaps the offer for a different one. One reroll per run, plus one for every 5 rounds cleared.
  func reroll() -> bool:
  	if is_over() or rerolls <= 0 or offer.is_empty():
  		return false
  	rerolls -= 1
  	var old := offer.duplicate()
  	for k in 10:
  		offer = RoguePerks.offer(run_seed * 100 + shots + 7777 * (k + 1), perks)
  		if offer != old:
  			break
  	return true
  ```

**2. `scripts/ui/rogue_panel.gd`** (keep everything else):
- Add `signal reroll_pressed` after `signal perk_chosen(id: String)`, and **declare** `var reroll_button: Button`
  after `var perk_ids: Array[String] = []`.
- In `_ready()`, right after the loop that creates the three perk buttons (before `hide()`):
  ```gdscript
  	reroll_button = Button.new()
  	reroll_button.pressed.connect(func(): reroll_pressed.emit())
  	box.add_child(reroll_button)
  ```
- In `show_outcome()`, right before the final `show()`:
  ```gdscript
  	reroll_button.text = "Reroll perks (%d left)" % run.rerolls
  	reroll_button.disabled = run.rerolls <= 0
  ```

**3. `scripts/game/main.gd`** (only these edits):
- In `_build_ui()`, right after `ui_layer.rogue_panel.perk_chosen.connect(choose_rogue_perk)`:
  `ui_layer.rogue_panel.reroll_pressed.connect(reroll_perks)`
- Add this function right before `_begin_aim()`:
  ```gdscript
  func reroll_perks() -> bool:
  	if mode != "rogue" or state != State.RESULTS or not rogue.reroll():
  		return false
  	_update_ui()
  	return true
  ```

## Acceptance criteria
- A run starts with 1 reroll and earns 1 more each time the rounds cleared reach a multiple of 5.
- `reroll()` replaces the offer with a different set of 3 perks; it needs an offer, a reroll left and a live run.
- The perk panel's "Reroll perks (N left)" button rerolls and the perk buttons show the new offer; it is
  disabled at 0.
