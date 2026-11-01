extends Resource
## One campaign level. Add it to data/level_catalog.tres (in world order) to expose it in the
## level select. world indexes scripts/world_catalog.gd; stage is its 1-5 slot in that world.
@export var title := ""
@export_multiline var description := ""
@export_file("*.tscn") var scene_path := ""
@export_range(0,4) var world := 0
@export_range(1,5) var stage := 1
