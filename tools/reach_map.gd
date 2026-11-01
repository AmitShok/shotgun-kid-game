extends SceneTree
## Room design tool: maps how high the player can be (while descending) at each tile column of a
## room, so ledges can be placed where one strategy reaches and another provably doesn't.
##   godot --headless --fixed-fps 60 --path . --script res://tools/reach_map.gd -- \
##     --map=mossy_comet --room=M02 [--dir=left] [--without=pods,shells,mines]
##     [--prefix="24 right|4 right|1 right aim_down fire"] [--clear-from=COL] [--report=70,72]
## Without --prefix the search runs toward --dir and jumps at the ledge edge, then fires two
## shots over a timing/aim grid. With --prefix those route steps play first (e.g. up to a pod
## fling), then the two-shot search continues from there. --clear-from erases solid tiles from
## that room column onward so landing ledges don't cut arcs short. Prints "col:y" pairs (player
## centre y, lower is higher; 9999 = never reached) and the best inputs for the far columns.
const MAP=preload("res://scripts/room_map.gd")
const PHASE=preload("res://scripts/phase_block.gd")
const ACTIONS := ["left","right","jump","fire","aim_left","aim_right","aim_up","aim_down"]
const AIMS := [["back","aim_down"],["back"],["aim_down"]]
var level: Node2D
var player: CharacterBody2D
var died := false
var env := {}
var best := {}
func _initialize() -> void: call_deferred("run")
func act(a: String, on: bool) -> void:
 var e := InputEventAction.new();e.action=a;e.pressed=on;Input.parse_input_event(e);Input.flush_buffered_events()
func run() -> void:
 var args := {"map":"lantern_ridge","room":"R01","dir":"right","without":"","prefix":"","clear-from":"-1","report":""}
 for arg in OS.get_cmdline_user_args():
  for key in args:
   if arg.begins_with("--%s=" % key): args[key]=arg.trim_prefix("--%s=" % key)
 level=load(MAP.scene_for(args.map)).instantiate()
 root.add_child(level);current_scene=level
 player=level.get_node("Player");player.died.connect(func(): died=true)
 var room: Node2D=level.get_node("Rooms/"+args.room)
 var origin_x: float=room.rect().position.x
 if int(args["clear-from"])>=0:
  var ground: TileMapLayer=level.get_node("Terrain/Ground")
  for cell in ground.get_used_cells():
   var p: Vector2=ground.map_to_local(cell)
   if room.rect().has_point(p) and p.x>=origin_x+int(args["clear-from"])*16: ground.erase_cell(cell)
 var prefix: Array = []
 for step in String(args.prefix).split("|",false):
  var parts := step.strip_edges().split(" ",false)
  prefix.append({"frames":int(parts[0]),"actions":parts.slice(1)})
 for i in 10: await physics_frame
 var forward: String=args.dir
 var back := "aim_left" if forward=="right" else "aim_right"
 for t1 in range(0,61,3):
  for gap in range(6,61,3):
   for a1 in AIMS:
    for a2 in AIMS:
     var s1: Array=a1.map(func(a): return back if a=="back" else a)
     var s2: Array=a2.map(func(a): return back if a=="back" else a)
     var before: Dictionary=env.duplicate()
     await attempt(room,args,prefix,forward,t1,t1+gap,s1,s2)
     for col in env:
      if env[col]<before.get(col,9999.0): best[col]=[t1,t1+gap,s1,s2]
 var line := "REACH %s/%s:" % [args.map,args.room]
 var cols: Array=env.keys();cols.sort()
 for col in cols: line+=" %d:%d" % [col,int(env[col])]
 print(line)
 if not cols.is_empty():
  var report: Array=Array(String(args.report).split(",",false)).map(func(c): return int(c))
  if report.is_empty(): report=cols.slice(maxi(0,cols.size()-4))
  for col in report: print("  best inputs for col %d (y=%d): %s" % [col,int(env.get(col,9999)),str(best.get(col))])
 quit()
func attempt(room: Node2D,args: Dictionary,prefix: Array,forward: String,t1: int,t2: int,a1: Array,a2: Array) -> void:
 for a in ACTIONS: act(a,false)
 for group in ["boost_mines","shell_pickups","spore_pods"]: level.get_tree().call_group(group,"reset")
 PHASE.set_phase(level.get_tree(),0)
 level.get_tree().call_group("crumble_blocks","reset")
 level.get_tree().call_group("wind_zones","reset")
 var kinds := {"shells":"shell_pickups","mines":"boost_mines","pods":"spore_pods","switches":"phase_switches","crumbles":"crumble_blocks","wind":"wind_zones"}
 for kind in String(args.without).split(",",false):
  for item in level.get_tree().get_nodes_in_group(kinds.get(kind,"")):
   if room.rect().has_point(item.global_position):
    item.set_physics_process(false);item.hide()
    if "available" in item: item.available=false
    if "armed" in item: item.armed=false
 player.spawn_point=room.spawn_point();player.respawn();player.invincible=0.0
 for i in 3: await physics_frame
 died=false
 var held: Array = []
 for step in prefix:
  for a in ACTIONS:
   var want: bool=a in step.actions
   if want!=(a in held):
    act(a,want)
    if want: held.append(a)
    else: held.erase(a)
  for i in step.frames:
   await physics_frame
   if died or player.dying>0: return
 for a in ACTIONS: act(a,false)
 act(forward,true)
 var jumped := -1 if prefix.is_empty() else 0
 for frame in 360:
  if jumped<0 and not player.is_on_floor(): jumped=frame;act("jump",true)
  if jumped>=0:
   var since: int=frame-jumped
   if since==14 and prefix.is_empty(): act("jump",false)
   for shot in [[t1,a1],[t2,a2]]:
    if since==shot[0]:
     for a in shot[1]: act(a,true)
     act("fire",true)
    elif since==shot[0]+1:
     act("fire",false)
     for a in shot[1]: act(a,false)
  await physics_frame
  if died or player.dying>0 or player.global_position.y>room.rect().end.y: return
  if jumped>=0 and player.is_on_floor() and frame-jumped>t2+2: return
  if player.velocity.y>0:
   var col: int=int((player.global_position.x-room.rect().position.x)/16.0)
   env[col]=minf(env.get(col,9999.0),player.global_position.y)
