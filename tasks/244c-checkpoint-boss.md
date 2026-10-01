---
id: 244c-checkpoint-boss
status: ready
tests: [tests/acceptance/test_244c_checkpoint_boss.gd]
files: [docs/PROGRESS.md]
---

# Checkpoint 31: boss fights

Milestone 31 (tasks 238-243) is built and its tests pass; this checkpoint's test plays a boss fight end to end.

What to do: **append this one line to the end of `docs/PROGRESS.md`** (keep every line already there, including
the other "Milestone N: complete" lines):
```
Milestone 31: complete (boss fights: every 10th roguelike round the Grumblor stands on the field with targets on and around its body, 4 shots to knock out its HP, results for every hit, +1 life for beating it)
```
That is the whole task. The scripts for milestone 31 are already finished and their tests already pass: do not
open, add to the chat, or edit any other file (not the scripts, not the tests). Only if the test output after this
change names a failing assertion should you fix the one script it names.

## Acceptance criteria
- `docs/PROGRESS.md` contains `Milestone 31: complete`, and every earlier milestone line is still there.
- All tests pass.
