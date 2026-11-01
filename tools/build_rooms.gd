extends SceneTree
## Builds a level scene's playfield from a text room map in data/rooms/<map>.txt.
##   godot --headless --path . --script res://tools/build_rooms.gd -- --map=lantern_ridge
## Replaces terrain, rooms, hazards, mines, pickups, exit and scenery in the level scene.
## Backdrop, Player, HUD and the level's exported settings are kept.
##
## Map format (see scripts/room_map.gd): "@room NAME COL ROW" starts a room at tile (COL, ROW); the rows
## that follow are its tiles, one character per 16px cell. "@route" blocks are read by
## tests/room_routes_test.gd and ignored here. Lines starting with ";" are comments.
##   #  solid ground        .  empty             P  respawn point for this room
##   ^  floor spikes        v  ceiling spikes    <  spikes on a wall, pointing left
##   >  spikes on a wall, pointing right         m  boost mine
##   s  shell refill        G  golden shell      E  exit gate
##   u r l d  spore pod rooted below / left / right / above it    o  free-floating spore pod
##   a  copper phase plate (solid in phase 0)    b  teal phase plate (solid in phase 1)
##   w  phase switch (shoot it to swap which plates are solid)
##   i  slippery ice (solid, almost no grip)    c  crumbling ice (shatters after being stood on)
##   k  crumbling ice too; alternate c and k so neighbouring segments crumble separately
##   { } ~  wind gust blowing left / right / up (Echo Orchard; all gusts share one rhythm)
const ACTORS := {
 "m":"res://scenes/actors/boost_mine.tscn",
 "s":"res://scenes/actors/shell_pickup.tscn",
 "G":"res://scenes/actors/golden_shell.tscn",
 "E":"res://scenes/actors/exit.tscn"}
const MAP=preload("res://scripts/room_map.gd")
const SPIKES := "res://scenes/actors/spikes.tscn"
const BREAKABLE=preload("res://scripts/breakable_decor.gd")
const TILE := 16
var level: Node2D
var solid := {}

func _initialize() -> void: call_deferred("run")

func run() -> void:
 var map_name := "lantern_ridge"
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--map="): map_name=arg.trim_prefix("--map=")
 var scene_path: String=MAP.scene_for(map_name)
 level=load(scene_path).instantiate()
 var tiles: TileSet
 for layer in level.get_node("Terrain").get_children():
  if layer is TileMapLayer: tiles=layer.tile_set
 _clear()
 var rooms: Array=MAP.load_map(map_name).rooms
 for room in rooms:
  for y in room.size.y:
   var row: String=room.rows[y]
   for x in row.length():
    if row[x]=="#": solid[room.origin+Vector2i(x,y)]=true
 _build_terrain(tiles)
 var bounds := Rect2()
 var room_root := _add(level,Node2D.new(),"Rooms")
 var actors := _add(level,Node2D.new(),"Actors")
 var scenery: Node2D=_add(level,Node2D.new(),"Scenery")
 scenery.z_index=-1
 var counts := {}
 for room in rooms:
  var node: Node2D=_add(room_root,Node2D.new(),room.name)
  node.set_script(load("res://scripts/room.gd"))
  node.position=Vector2(room.origin*TILE)
  node.size=room.size*TILE
  var area := Rect2(node.position,Vector2(node.size))
  bounds=area if bounds.size==Vector2.ZERO else bounds.merge(area)
  var spawn: Marker2D=_add(node,Marker2D.new(),"Spawn")
  spawn.position=Vector2(32,room.size.y*TILE-40)
  for y in room.size.y:
   var row: String=room.rows[y]
   for x in row.length():
    var ch := row[x]
    var cell: Vector2i=room.origin+Vector2i(x,y)
    var floor_at := Vector2(cell*TILE)+Vector2(8,16)
    if ch=="P": spawn.position=Vector2(x*TILE+8,y*TILE+16-11)
    elif ch in "^v<>": _spike(actors,ch,cell,counts)
    elif ch in "urldo": _pod(actors,ch,cell,counts)
    elif ch=="w":
     var switch := _instance(actors,"res://scenes/actors/phase_switch.tscn","PhaseSwitch",counts)
     switch.position=Vector2(cell*TILE)+Vector2(8,8)
    elif ch in "abick{}~":
     # One block node per rectangle of the same kind (a run, extended down while the rows
     # below repeat it exactly), so a whole gate stays open while the player is in any of it.
     if plated.has(cell): continue
     var run := 1
     while x+run<row.length() and row[x+run]==ch: run+=1
     var depth := 1
     while y+depth<room.size.y and _same_run(room.rows[y+depth],x,run,ch): depth+=1
     for dy in depth:
      for dx in run: plated[cell+Vector2i(dx,dy)]=true
     if ch in "{}~":
      var wind: Node2D=_add(actors,Node2D.new(),"Wind%d_%d" % [cell.x,cell.y])
      wind.set_script(load("res://scripts/wind_zone.gd"))
      wind.direction={"{":Vector2.LEFT,"}":Vector2.RIGHT,"~":Vector2.UP}[ch]
      # Updrafts must beat gravity (900) to lift you; side gusts just add carry.
      if ch=="~": wind.strength=1700.0
      wind.tiles=run
      wind.rows=depth
      wind.position=Vector2(cell*TILE)
      continue
     var kind: Array={"a":["Plate","phase_block.gd"],"b":["Plate","phase_block.gd"],"i":["Ice","ice_block.gd"],"c":["Crumble","crumble_block.gd"],"k":["Crumble","crumble_block.gd"]}[ch]
     var block: StaticBody2D=_add(actors,StaticBody2D.new(),"%s%d_%d" % [kind[0],cell.x,cell.y])
     block.set_script(load("res://scripts/"+kind[1]))
     if ch in "ab": block.block_phase=0 if ch=="a" else 1
     block.tiles=run
     block.rows=depth
     block.position=Vector2(cell*TILE)
    elif ACTORS.has(ch):
     var actor: Node2D=_instance(level if ch=="E" else actors,ACTORS[ch],{"m":"Mine","s":"Shell","G":"GoldenShell","E":"Exit"}[ch],counts)
     # The exit lives at the level root as "Exit", where the HUD and tests look for it.
     if ch=="E": actor.name="Exit"
     actor.position=floor_at if ch=="E" else Vector2(cell*TILE)+Vector2(8,8)
    elif ch!="#" and ch!="." and ch!=" ": push_warning("Unknown map character '%s' in %s" % [ch,room.name])
 _decorate(scenery,map_name)
 level.set("camera_bounds",bounds)
 level.set("fall_limit_y",bounds.end.y+64)
 if level.has_meta("traversal_route"): level.remove_meta("traversal_route")
 var player: Node2D=level.get_node("Player")
 player.position=room_root.get_child(0).spawn_point() if room_root.get_child_count()>0 else player.position
 # Keep the HUD and other kept nodes drawn above the rebuilt playfield.
 for keep in ["Player","HUD"]:
  if level.has_node(keep): level.move_child(level.get_node(keep),-1)
 var packed := PackedScene.new()
 var error := packed.pack(level)
 if error==OK: error=ResourceSaver.save(packed,scene_path)
 if error==OK:
  # Instanced actors already carry their own signal connections; packing repeats them.
  var lines := FileAccess.get_file_as_string(scene_path).split("\n")
  var clean := PackedStringArray()
  for line in lines:
   if not line.begins_with("[connection "): clean.append(line)
  var file := FileAccess.open(scene_path,FileAccess.WRITE)
  file.store_string("\n".join(clean))
  file.close()
 print("%s: %d rooms, %d solid tiles, saved %s (%s)" % [map_name,rooms.size(),solid.size(),scene_path,error_string(error)])
 level.free()
 quit(0 if error==OK else 1)

func _clear() -> void:
 for name in ["Rooms","Actors","Mines","Pickups","Hazards","Scenery","Signs","Exit"]:
  if level.has_node(name): _drop(level.get_node(name))
 for layer in level.get_node("Terrain").get_children(): _drop(layer)
 for child in level.get_children():
  var script: Script=child.get_script()
  if script and script.resource_path.get_file() in ["checkpoint.gd","hazard.gd","exit.gd","boost_mine.gd","shell_pickup.gd","golden_shell.gd","spore_pod.gd","phase_switch.gd","phase_block.gd","ice_block.gd","crumble_block.gd","wind_zone.gd"]: _drop(child)
func _drop(node: Node) -> void:
 node.get_parent().remove_child(node)
 node.free()
func _add(parent: Node,node: Node,name: String) -> Node:
 node.name=name
 parent.add_child(node)
 node.owner=level
 return node
func _instance(parent: Node,path: String,prefix: String,counts: Dictionary) -> Node2D:
 counts[prefix]=int(counts.get(prefix,0))+1
 var node: Node2D=load(path).instantiate()
 node.name="%s%d" % [prefix,counts[prefix]]
 parent.add_child(node)
 node.owner=level
 return node
func _spike(parent: Node,ch: String,cell: Vector2i,counts: Dictionary) -> void:
 var spike := _instance(parent,SPIKES,"Spikes",counts)
 var origin := Vector2(cell*TILE)
 # The spike scene points up from its origin; rotate it to sit on the matching surface.
 match ch:
  "^": spike.position=origin+Vector2(8,16)
  "v": spike.position=origin+Vector2(8,0);spike.rotation=PI
  ">": spike.position=origin+Vector2(0,8);spike.rotation=PI/2
  "<": spike.position=origin+Vector2(16,8);spike.rotation=-PI/2
var plated := {}
func _same_run(row: String,x: int,run: int,ch: String) -> bool:
 if x+run>row.length() or (x>0 and row[x-1]==ch) or (x+run<row.length() and row[x+run]==ch): return false
 for i in run:
  if row[x+i]!=ch: return false
 return true
func _is_solid(cell: Vector2i) -> bool:
 return solid.has(cell)
func _build_terrain(tiles: TileSet) -> void:
 var ground: TileMapLayer=_add(level.get_node("Terrain"),TileMapLayer.new(),"Ground")
 ground.tile_set=tiles
 for cell in solid:
  var tile := _terrain_tile(cell)
  ground.set_cell(cell,0,tile)
  # Hanging rocks/icicles (non-solid row 3) under some exposed undersides.
  if tile.y==2 and not _is_solid(cell+Vector2i(0,2)) and (cell.x*7+cell.y*3)%3==0:
   ground.set_cell(cell+Vector2i.DOWN,0,Vector2i(posmod(cell.x*5,8),3))
## Picks the atlas cell for a solid cell from its open sides and how deep it sits in the rock
## (see tools/art_terrain.lua for the atlas layout). A position hash picks among variants, so
## rebuilds are stable.
func _terrain_tile(cell: Vector2i) -> Vector2i:
 var u := not _is_solid(cell+Vector2i.UP)
 var d := not _is_solid(cell+Vector2i.DOWN)
 var l := not _is_solid(cell+Vector2i.LEFT)
 var r := not _is_solid(cell+Vector2i.RIGHT)
 var pick: int=absi(cell.x*31+cell.y*17)
 var middles := [1,2,3,6,7]
 if u and d:
  if l and r: return Vector2i(4,5)
  if l: return Vector2i(0,5)
  if r: return Vector2i(3,5)
  return Vector2i(1+pick%2,5)
 if u or d:
  var row := 0 if u else 2
  if l and r: return Vector2i(5,row)
  if l: return Vector2i(0,row)
  if r: return Vector2i(4,row)
  return Vector2i(middles[pick%5],row)
 if l and r: return Vector2i(5,1)
 if l: return Vector2i(0,1)
 if r: return Vector2i(4,1)
 # Enclosed on all four sides: an open diagonal makes an inner corner, otherwise depth decides.
 if not _is_solid(cell+Vector2i(-1,-1)): return Vector2i(0,6)
 if not _is_solid(cell+Vector2i(1,-1)): return Vector2i(1,6)
 if not _is_solid(cell+Vector2i(-1,1)): return Vector2i(2,6)
 if not _is_solid(cell+Vector2i(1,1)): return Vector2i(3,6)
 var depth := 3
 for dy in range(-2,3):
  for dx in range(-2,3):
   if not _is_solid(cell+Vector2i(dx,dy)): depth=2
 if depth==2: return Vector2i(pick%4,4)
 return Vector2i(4+pick%4,4)
func _decorate(scenery: Node2D,map_name: String) -> void:
 # Small props on open ground tops, placed by a position hash so rebuilds are stable.
 var biome: String=MAP.biome(map_name)
 var biome_sheet: Texture2D=null if biome=="lantern_ridge" else load("res://assets/textures/%s_decor.png" % biome)
 var heather: Texture2D=load("res://assets/textures/heather.png")
 var lantern: Texture2D=load("res://assets/textures/lantern.png")
 var index := 0
 for cell in solid:
  if _is_solid(cell+Vector2i.UP) or _is_solid(cell+Vector2i(0,-2)) or _is_solid(cell+Vector2i(0,-3)): continue
  if not (_is_solid(cell+Vector2i.LEFT) and _is_solid(cell+Vector2i.RIGHT)): continue
  var roll: int=absi(cell.x*73+cell.y*151)%17
  if roll>2: continue
  var sprite: Sprite2D=_add(scenery,Sprite2D.new(),"Prop%d" % index)
  # Shotgun blasts and mines break scenery props (scripts/breakable_decor.gd).
  sprite.set_script(BREAKABLE)
  index+=1
  var top := Vector2(cell*TILE)+Vector2(8,0)
  if biome_sheet:
   sprite.texture=biome_sheet
   sprite.hframes=4
   sprite.vframes=2
   sprite.frame=absi(cell.x*31+cell.y*17)%8
   sprite.position=top+Vector2(0,-16)
  elif roll==0:
   sprite.texture=lantern
   sprite.position=top+Vector2(0,-32)
  else:
   sprite.texture=heather
   sprite.position=top+Vector2(0,-16)
func _pod(parent: Node,ch: String,cell: Vector2i,counts: Dictionary) -> void:
 var pod := _instance(parent,"res://scenes/actors/spore_pod.tscn","SporePod",counts)
 var angle: float={"u":0.0,"r":PI/2,"l":-PI/2,"d":PI,"o":0.0}[ch]
 pod.rotation=angle
 # Nudge toward the surface it grows from so its root cup touches the tile.
 pod.position=Vector2(cell*TILE)+Vector2(8,8)-(Vector2.ZERO if ch=="o" else Vector2.UP.rotated(angle)*4)
