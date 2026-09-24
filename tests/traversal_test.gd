extends SceneTree
var level: Node
var player: CharacterBody2D
var failed := false
func _initialize() -> void: call_deferred("run")
func frames(count: int) -> void:
 for i in count: await physics_frame
func run() -> void:
 level=load("res://scenes/levels/training_yard.tscn").instantiate()
 root.add_child(level)
 current_scene=level
 player=level.get_node("Player")
 # Isolate base-route reachability; the mine shortcut has its own live-physics test.
 for mine in get_nodes_in_group("boost_mines"): mine.queue_free()
 player.invincible=999
 var route=[Vector2(340,544),Vector2(472,496),Vector2(632,448),Vector2(800,392),Vector2(1030,448),Vector2(1272,432),Vector2(1464,384),Vector2(1700,464),Vector2(1968,400),Vector2(2128,336),Vector2(2370,432)]
 # Start on the launch edge; thereafter traverse continuously, without teleports.
 player.position=route[0]+Vector2(0,-12)
 await frames(30)
 for step in range(1,route.size()):
  var destination: Vector2=route[step]
  jump_key(true)
  Input.action_press("right")
  var landed := false
  for frame in range(210):
   var dx: float=destination.x-player.position.x
   Input.action_release("left")
   Input.action_release("right")
   if dx>18: Input.action_press("right")
   elif dx< -18: Input.action_press("left")
   # Apex shots extend the jump; aim diagonally until above the target ledge.
   if frame>8 and not player.is_on_floor() and player.velocity.y> -35 and player.position.y>destination.y-125 and player.shotgun.ammo>0:
    player.shotgun.aim=Vector2(-1,1).normalized() if dx>65 else Vector2.DOWN
    player.shotgun.shoot()
   await frames(1)
   if frame>8 and player.is_on_floor() and absf(player.position.x-destination.x)<65 and absf(player.position.y-(destination.y-10.5))<3:
    landed=true
    break
   if player.position.y>710: break
  jump_key(false)
  Input.action_release("right")
  Input.action_release("left")
  if not landed:
   push_error("Route failed at ledge %d: %s" % [step,player.position])
   failed=true
   break
  print("PASS: Continuous traversal to ledge ",step)
  await frames(25)
 print("TRAVERSAL RESULT: ","FAIL" if failed else "PASS (10 consecutive gaps)")
 quit(1 if failed else 0)

func jump_key(pressed: bool) -> void:
 var event := InputEventKey.new()
 event.physical_keycode=KEY_SPACE
 event.pressed=pressed
 Input.parse_input_event(event)
 Input.flush_buffered_events()
