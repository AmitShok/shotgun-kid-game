extends SceneTree
## Creates a later level of a world: copies the world's first level scene (backdrop, player,
## HUD, terrain tiles, music) to scenes/levels/<map>.tscn, writes data/levels/<map>.tres, and
## rewrites data/level_catalog.tres in world/stage order. Then author data/rooms/<map>.txt and
## run tools/build_rooms.gd -- --map=<map> to build its playfield.
##   godot --headless --path . --script res://tools/new_level.gd -- --map=lantern_ridge_2 --title="CINDER STEPS" --world=0 --stage=2 [--description="..."]
const MAP=preload("res://scripts/room_map.gd")
const DEFINITION=preload("res://scripts/level_definition.gd")
const CATALOG_SCRIPT=preload("res://scripts/level_catalog.gd")
func _initialize() -> void:
 var args := {"map":"","title":"","world":"0","stage":"2","description":""}
 for arg in OS.get_cmdline_user_args():
  for key in args:
   if arg.begins_with("--%s=" % key): args[key]=arg.trim_prefix("--%s=" % key)
 var map_name: String=args.map
 var biome := MAP.biome(map_name)
 var scene_path := MAP.scene_for(map_name)
 if not FileAccess.file_exists(scene_path):
  var level: Node=load(MAP.scene_for(biome)).instantiate()
  level.set("level_title",args.title)
  level.set("music",biome)
  var packed := PackedScene.new()
  packed.pack(level)
  ResourceSaver.save(packed,scene_path)
  level.free()
 var definition: Resource=DEFINITION.new()
 definition.title=args.title
 definition.description=args.description
 definition.scene_path=scene_path
 definition.world=int(args.world)
 definition.stage=int(args.stage)
 ResourceSaver.save(definition,"res://data/levels/%s.tres" % map_name)
 # Rebuild the catalog from every definition on disk, ordered by world then stage.
 var all: Array[Resource] = []
 for file in DirAccess.get_files_at("res://data/levels"):
  if file.ends_with(".tres"): all.append(load("res://data/levels/"+file))
 all.sort_custom(func(a,b): return a.world*10+a.stage<b.world*10+b.stage)
 var catalog: Resource=CATALOG_SCRIPT.new()
 catalog.levels=all
 ResourceSaver.save(catalog,"res://data/level_catalog.tres")
 print("new level %s -> %s (world %d stage %d), catalog has %d levels" % [map_name,scene_path,definition.world+1,definition.stage,all.size()])
 quit()
