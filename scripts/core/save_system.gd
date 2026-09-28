class_name SaveSystem
extends RefCounted
## Saves and loads Progress as JSON. See docs/DESIGN.md section 9.

const DEFAULT_PATH: String = "user://save.json"


static func save_progress(progress: Progress, path: String = DEFAULT_PATH) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	
	file.store_string(JSON.stringify(progress.to_dict(), "\t"))
	file.close()
	return true


static func load_progress(path: String = DEFAULT_PATH) -> Progress:
	if not FileAccess.file_exists(path):
		return Progress.new()
	
	var json := JSON.new()
	var result := json.parse(FileAccess.get_file_as_string(path))
	if result != OK or typeof(json.data) != TYPE_DICTIONARY:
		return Progress.new()
	
	return Progress.from_dict(json.data)


static func delete_save(path: String = DEFAULT_PATH) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
