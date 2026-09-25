extends Resource
## Add another resource to MainMenu.levels to expose a new level in the selector.
@export var title := ""
@export_multiline var description := ""
@export_file("*.tscn") var scene_path := ""
