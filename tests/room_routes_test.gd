extends SceneTree
## Proves each room is beatable: replays every "@route" in data/rooms/<map>.txt from the room's
## respawn point and checks the player reaches the target room (or the exit) without dying.
##   godot --headless --path . --script res://tests/room_routes_test.gd -- --map=lantern_ridge
## Add --trace to print the player's position every 6 frames while tuning a route.
const MAP=preload("res://scripts/room_map.gd")
const PHASE=preload("res://scripts/phase_block.gd")
const ACTIONS := ["left","right","jump","fire","aim_left","aim_right","aim_up","aim_down"]
var failures := 0
var level: Node2D
var player: CharacterBody2D
var died := false
func _initialize() -> void: call_deferred("run")
func act(action: String, on: bool) -> void:
 var event := InputEventAction.new()
 event.action=action
 event.pressed=on
 Input.parse_input_event(event)
 Input.flush_buffered_events()
# Disable the listed item kinds inside a room so a search can prove they are required.
func strip_items(room: Node2D, without: Array) -> void:
 var groups := {"shells":"shell_pickups","mines":"boost_mines","pods":"spore_pods","switches":"phase_switches","crumbles":"crumble_blocks","wind":"wind_zones"}
 for kind in without:
  for item in level.get_tree().get_nodes_in_group(groups.get(kind,"")):
   if not room.rect().has_point(item.global_position): continue
   item.set_physics_process(false)
   item.hide()
   if "available" in item: item.available=false
   if "armed" in item: item.armed=false
# Brute force: run toward the target, jump either at the ledge edge (-1) or after a fixed number
# of frames, then fire two shots over a grid of timings and aims (backward, backward-down, down).
# Returns the first input set that lands safely in the target, or [].
const AIMS := [["back","aim_down"],["back"],["aim_down"]]
const TIMED_JUMPS := [0,8,16,24,32,40]
func search_skip(check: Dictionary) -> Array:
 var room: Node2D=level.get_node("Rooms/"+check.from)
 # -1 jumps at the ledge edge, -2 walks off without jumping (for rooms where a jump is deadly).
 for jump_at in [-1,-2]+(TIMED_JUMPS if check.timed else []):
  # Edge jumps get a 2-frame shot grid; the extra timed jumps use 4 frames to stay fast.
  var step := 2 if jump_at<0 else 4
  for t1 in range(0,37,step):
   for gap in range(6,41,step):
    for a1 in AIMS:
     for a2 in AIMS:
      if await attempt(room,check,jump_at,t1,t1+gap,a1,a2): return [jump_at,t1,t1+gap,a1,a2]
 return []
func attempt(room: Node2D, check: Dictionary, jump_at: int, t1: int, t2: int, a1: Array, a2: Array) -> bool:
 var forward: String=check.dir
 var back := "aim_left" if forward=="right" else "aim_right"
 a1=a1.map(func(a): return back if a=="back" else a)
 a2=a2.map(func(a): return back if a=="back" else a)
 for action in ACTIONS: act(action,false)
 # A previous route may have finished the level; every attempt must start un-finished.
 level.complete=false
 level.get_tree().paused=false
 level.get_tree().call_group("boost_mines","reset")
 level.get_tree().call_group("shell_pickups","reset")
 level.get_tree().call_group("spore_pods","reset")
 PHASE.set_phase(level.get_tree(),0)
 level.get_tree().call_group("crumble_blocks","reset")
 level.get_tree().call_group("wind_zones","reset")
 strip_items(room,check.without)
 if check.to=="gold":
  # Start every attempt with the shell unbanked and back in its pocket.
  root.get_node("SaveData").golden_shells.clear()
  for shell in level.get_tree().get_nodes_in_group("golden_shells"):
   shell.state=shell.State.WAITING
   shell.global_position=shell.home
   shell.get_node("Visual").scale=Vector2.ONE
   shell.show()
 player.spawn_point=room.spawn_point()
 player.respawn()
 player.invincible=0.0
 for i in 4: await physics_frame
 died=false
 act(forward,true)
 var jumped := -1
 var grounded_frames := 0
 for frame in 360:
  if jumped<0 and ((jump_at<0 and not player.is_on_floor()) or (jump_at>=0 and frame==jump_at)):
   jumped=frame
   if jump_at!=-2: act("jump",true)
  if jumped>=0:
   var since: int=frame-jumped
   if since==14: act("jump",false)
   for shot in [[t1,a1],[t2,a2]]:
    if since==shot[0]:
     for aim in shot[1]: act(aim,true)
     act("fire",true)
    elif since==shot[0]+1:
     act("fire",false)
     for aim in shot[1]: act(aim,false)
  await physics_frame
  if died or player.dying>0: return false
  # A skip only counts once the player has landed safely inside the target room.
  if reached(check.to) and player.is_on_floor(): return true
  # End early once this attempt is spent: never jumped, or both shots fired and back on the ground.
  if jumped<0 and frame>=90: return false
  # Golden shells bank after standing still briefly, so give those attempts ~30 grounded frames.
  grounded_frames=grounded_frames+1 if jumped>=0 and frame-jumped>t2+2 and player.is_on_floor() else 0
  if grounded_frames>(30 if check.to=="gold" else 0): return false
 return false
func reached(target: String) -> bool:
 if target=="exit": return level.complete
 if target=="gold": return root.get_node("SaveData").has_golden_shell(level.scene_file_path)
 return level.current_room!=null and String(level.current_room.name)==target
func run() -> void:
 var map_name := "lantern_ridge"
 var trace := "--trace" in OS.get_cmdline_user_args()
 var trace_step := 6
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--trace-step="): trace_step=int(arg.trim_prefix("--trace-step="))
 var only := ""
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--map="): map_name=arg.trim_prefix("--map=")
  if arg.begins_with("--only="): only=arg.trim_prefix("--only=")
 var data := MAP.load_map(map_name)
 level=load(MAP.scene_for(map_name)).instantiate()
 root.add_child(level)
 current_scene=level
 player=level.get_node("Player")
 player.died.connect(func(): died=true)
 for i in 10: await physics_frame
 var checked := 0
 for route in data.routes:
  if not only.is_empty() and route.from!=only: continue
  checked+=1
  for action in ACTIONS: act(action,false)
  get_root().get_tree().paused=false
  level.complete=false
  var room: Node2D=level.get_node("Rooms/"+route.from)
  level.get_tree().call_group("boost_mines","reset")
  level.get_tree().call_group("shell_pickups","reset")
  level.get_tree().call_group("spore_pods","reset")
  PHASE.set_phase(level.get_tree(),0)
  level.get_tree().call_group("crumble_blocks","reset")
  level.get_tree().call_group("wind_zones","reset")
  player.spawn_point=room.spawn_point()
  # A hit queued just before the teleport can land after it; respawn until the start is clean.
  for attempt_start in 3:
   player.respawn()
   player.invincible=0.0
   for i in 12: await physics_frame
   if player.dying<=0: break
  died=false
  var ok := false
  var frame := 0
  var held: Array = []
  var steps: Array=route.steps.duplicate()
  steps.append({"frames":120,"actions":[]})
  for step in steps:
   for action in ACTIONS:
    var want: bool=action in step.actions
    if want!=(action in held):
     act(action,want)
     if want: held.append(action)
     else: held.erase(action)
   for i in step.frames:
    await physics_frame
    frame+=1
    if trace and frame%trace_step==0: print("  f%d pos=(%.0f,%.0f) vel=(%.0f,%.0f) ammo=%d room=%s phase=%d" % [frame,player.global_position.x,player.global_position.y,player.velocity.x,player.velocity.y,player.shotgun.ammo,level.current_room.name if level.current_room else "-",PHASE.phase])
    if died or player.dying>0: break
    # Arriving mid-flight is not enough: the player must land safely in the target room.
    if reached(route.to) and (route.to in ["exit","gold"] or player.is_on_floor()):
     ok=true
     break
   if ok or died: break
  for action in ACTIONS: act(action,false)
  if ok: print("PASS %s -> %s (%d frames)" % [route.from,route.to,frame])
  else:
   failures+=1
   push_error("FAIL %s -> %s: %s at (%.0f,%.0f) after %d frames" % [route.from,route.to,"died" if died else "did not arrive",player.global_position.x,player.global_position.y,frame])
  get_root().get_tree().paused=false
 for check in data.skipchecks:
  if not only.is_empty() and check.from!=only: continue
  checked+=1
  var skip: Array=await search_skip(check)
  if skip.is_empty(): print("PASS skipcheck %s -> %s: no 2-shot route without %s" % [check.from,check.to,",".join(check.without)])
  else:
   failures+=1
   push_error("FAIL skipcheck %s -> %s is clearable without %s: %s" % [check.from,check.to,",".join(check.without),str(skip)])
 print("ROOM ROUTES %s: %d routes, %d failures" % [map_name,checked,failures])
 await root.get_node("Sfx").shutdown(1 if failures else 0)
