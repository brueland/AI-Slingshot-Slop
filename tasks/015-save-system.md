---
id: 015-save-system
status: ready
tests: [tests/acceptance/test_015_save_system.gd]
files: [scripts/core/save_system.gd]
read: [scripts/core/progress.gd]
---

# SaveSystem: save and load progress as JSON

Create `scripts/core/save_system.gd`.

```gdscript
class_name SaveSystem
extends RefCounted
## Saves and loads Progress as JSON. See docs/DESIGN.md section 9.

const DEFAULT_PATH: String = "user://save.json"
```

Static functions:
- `static func save_progress(progress: Progress, path: String = DEFAULT_PATH) -> bool`:
  `FileAccess.open(path, FileAccess.WRITE)`; return false if it is null; otherwise
  `store_string(JSON.stringify(progress.to_dict(), "\t"))`, close, return true.
- `static func load_progress(path: String = DEFAULT_PATH) -> Progress`:
  - file missing (`FileAccess.file_exists`) -> `Progress.new()`
  - parse with `var json := JSON.new()` and `json.parse(FileAccess.get_file_as_string(path))`; if the result
    is not `OK`, or `json.data` is not a Dictionary -> `Progress.new()`
  - otherwise `Progress.from_dict(json.data)`
  Never print or `push_error` here: a corrupt save must quietly start fresh (the tests fail on any error).
- `static func delete_save(path: String = DEFAULT_PATH) -> void`: if the file exists,
  `DirAccess.remove_absolute(ProjectSettings.globalize_path(path))`.

## Acceptance criteria
- Save then load returns the same coins, levels, best distance and runs.
- Missing or corrupt files (including valid JSON that is not an object) give a new Progress without errors.
