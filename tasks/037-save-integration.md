---
id: 037-save-integration
status: ready
tests: [tests/acceptance/test_037_save_integration.gd]
files: [scripts/game/main.gd]
read: [scripts/core/save_system.gd]
---

# Main: load and save progress

Edit `scripts/game/main.gd` (keep everything that works).

1. In `_ready()`, replace `progress = Progress.new()` with `progress = SaveSystem.load_progress(save_path)`.
   (`save_path` is an `@export` var; tests set it before adding main to the tree, so `_ready()` sees it.)
2. Add:
   ```gdscript
   func save_progress() -> void:
   	SaveSystem.save_progress(progress, save_path)
   ```
3. Call `save_progress()` in `_finish_run()` right after `record_run(...)` (before changing state), and in
   `buy_upgrade(id)` after a successful purchase.

## Acceptance criteria
- A save file with 500 coins and power 2 is loaded on start; the first session uses the upgraded speed.
- A missing save file starts fresh.
- After a run the file has total_runs 1; after buying, the file has the new level and coins.
