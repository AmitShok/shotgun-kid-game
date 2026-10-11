extends SceneTree
## Physical route playthrough: no teleports, no altered movement stats.
var failures=0
var shot_threshold=-50.0
func _initialize(): call_deferred("run")
func frame(): await physics_frame
func move_to(p,x):
 Input.action_release("left");Input.action_release("right")
 var dx=x-p.position.x
 var brake=p.velocity.x*absf(p.velocity.x)/(2.0*(2200 if p.is_on_floor() else 1522.5))
 if absf(dx)<4 and absf(p.velocity.x)<35: return
 if dx-brake>0: Input.action_press("right")
 else: Input.action_press("left")
func key(pressed):
 var e=InputEventKey.new();e.physical_keycode=KEY_SPACE;e.pressed=pressed
 Input.parse_input_event(e);Input.flush_buffered_events()
func run():
 var data=root.get_node("SaveData")
 if data.path=="user://settings.cfg": quit(1);return
 data.clear_progress()
 for biome in ["mossy_comet","copper_cloud","velvet_glacier","echo_orchard"]:
  var args=OS.get_cmdline_user_args()
  for arg in args:
   if arg.begins_with("--shot-threshold="): shot_threshold=float(arg.split("=")[1])
  var filtered=false
  for arg in args:
   if arg.begins_with("--biome=") and arg!="--biome="+biome: filtered=true
  if filtered: continue
  var scene=load("res://scenes/levels/"+biome+".tscn").instantiate();root.add_child(scene);current_scene=scene
  var p=scene.get_node("Player")
  if "--without-mines" in args:
   for mine in scene.get_node("Mines").get_children(): mine.remove_from_group("shot_targets")
  if "--without-shells" in args:
   for shell in scene.get_node("Pickups").get_children(): shell.set_physics_process(false)
  if "--without-relay-shell" in args and biome=="echo_orchard": scene.get_node("Pickups/Shell15").set_physics_process(false)
  for i in range(30): await frame()
  for index in range(scene.get_meta("traversal_route").size()):
   var step=scene.get_meta("traversal_route")[index]
   var launch: Vector2=step.launch
   var target: Vector2=step.target
   var dir=signf(target.x-launch.x)
   for i in range(120):
    move_to(p,launch.x)
    await frame()
    if abs(p.position.x-launch.x)<5 and abs(p.velocity.x)<50: break
   Input.action_release("left");Input.action_release("right")
   for i in range(20): await frame()
   var start_deaths=scene.deaths
   key(true)
   var success=false;var got=false;var shots=0;var crossed=false;var trace=[];var mine_hit=false
   for tick in range(300):
    if step.kind in ["shell","relay"]: got=got or not scene.get_node("Pickups/Shell%d"%(index+1)).available
    if step.kind in ["mine","lift","relay"]: mine_hit=mine_hit or not scene.get_node("Mines/Mine%d"%(index+1)).armed
    crossed=crossed or p.position.y<target.y-22
    move_to(p,launch.x if step.kind=="lift" and not crossed else target.x)
    var fire=tick>8 and not p.is_on_floor() and p.velocity.y>shot_threshold and p.shotgun.ammo>0
    if step.kind=="drop": fire=fire and shots==0 and absf(target.x-p.position.x)>float(step.width)
    if step.kind=="dash": fire=not p.is_on_floor() and p.shotgun.ammo>0 and ((shots==0 and tick>=4) or (shots==1 and p.velocity.y>shot_threshold))
    if fire:
     p.shotgun.aim=Vector2.DOWN if step.kind=="lift" or (step.kind in ["shell","relay"] and shots>=2) else Vector2(-dir,0) if (step.kind=="dash" and shots>0) or step.kind=="drop" else Vector2(-dir,1).normalized()
     if p.shotgun.shoot(): shots+=1
    await frame()
    if tick%15==0: trace.append([tick,p.position.round(),p.velocity.round(),p.shotgun.ammo])
    if DisplayServer.get_name()!="headless" and tick==35 and index in [0,2,5,7]:
     await RenderingServer.frame_post_draw
     root.get_texture().get_image().save_png("res://docs/route_"+biome+"_%d.png"%index)
    if scene.complete: success=true;break
    if scene.deaths>start_deaths: break
    if tick>10 and p.is_on_floor() and abs(p.position.y-(target.y-10.5))<5 and abs(p.position.x-target.x)<float(step.width)/2:
     success=true;break
   key(false);Input.action_release("left");Input.action_release("right")
   print("PASS " if success else "FAIL ",biome," ",index," ",step.kind," target=",target," pos=",p.position," shots=",shots," pickup=",got," mine=",mine_hit)
   if success and not scene.complete:
    await frame()
    if data.checkpoint!="Checkpoint%d"%(index+1):
     failures+=1;print("FAIL landing did not save checkpoint ",index+1," actual=",data.checkpoint)
   var expected_failure=("--without-mines" in args and step.kind in ["mine","lift","relay"]) or ("--without-shells" in args and step.kind=="shell") or ("--without-relay-shell" in args and step.kind=="relay" and index==14)
   if expected_failure:
    if success: failures+=1;print("FAIL removed mechanic was bypassed")
    else: print("PASS required mechanic removal stops the route")
    break
   if not success:
    print(trace);failures+=1;break
  if not ("--without-mines" in args or "--without-shells" in args or "--without-relay-shell" in args) and failures==0:
   for f in range(120):
    if scene.complete: break
    move_to(p,scene.get_node("Exit").position.x)
    await frame()
   if not scene.complete: failures+=1;print("FAIL exit did not complete level")
   else: print("PASS exit completes ",biome)
   Input.action_release("left");Input.action_release("right")
  paused=false;scene.queue_free();await process_frame
 print("CAMPAIGN ROUTE FAILURES: ",failures)
 await root.get_node("Sfx").shutdown(1 if failures else 0)
