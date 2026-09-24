extends SceneTree
var failures := 0
var checks := 0
var level: Node
var player: CharacterBody2D
func check(value: bool, label: String) -> void:
 checks+=1
 if value: print("PASS: ",label)
 else:
  failures+=1
  push_error("FAIL: "+label)
func frames(count: int) -> void:
 for i in count: await physics_frame
func _initialize() -> void:
 call_deferred("run")
func run() -> void:
 level=load("res://scenes/levels/training_yard.tscn").instantiate()
 root.add_child(level)
 current_scene=level
 player=level.get_node("Player")
 await frames(45)
 check(player.is_on_floor(),"Spawn rests on real terrain")
 check(absf(player.position.y-533.5)<2,"Floor collision supports player")
 var physical_key := InputEventKey.new()
 physical_key.physical_keycode=KEY_D
 physical_key.pressed=true
 Input.parse_input_event(physical_key)
 Input.flush_buffered_events()
 await frames(2)
 check(Input.is_action_pressed("right"),"Physical keyboard D reaches serialized Input Map")
 var released_key := InputEventKey.new()
 released_key.physical_keycode=KEY_D
 released_key.pressed=false
 Input.parse_input_event(released_key)
 Input.flush_buffered_events()
 await frames(2)
 if "--capture" in OS.get_cmdline_user_args():
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("res://docs/playtest.png")
  level.get_node("HUD")._toggle_pause()
  await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("res://docs/pause_menu.png")
  level.get_node("HUD")._toggle_pause()
 jump_key(true)
 await frames(3)
 jump_key(false)
 await frames(2)
 check(not player.is_on_floor(),"Space jump leaves floor")
 Input.action_press("aim_down")
 await frames(2)
 check(player.shotgun.shoot(),"First aerial shot fires")
 check(player.velocity.y< -380,"Downward shot propels player upward")
 await frames(14)
 check(player.shotgun.ammo==1,"Airborne shell does not refill")
 check(player.shotgun.shoot(),"Second aerial shot fires")
 await frames(14)
 check(player.shotgun.ammo==0,"Two shots empty the gun")
 check(not player.shotgun.shoot(),"Third shot is rejected")
 Input.action_release("aim_down")
 await frames(105)
 check(player.is_on_floor() and player.shotgun.ammo==2,"Landing refills exactly two shells")
 var dirs=[Vector2(-1,-1),Vector2(0,-1),Vector2(1,-1),Vector2(-1,0),Vector2(1,0),Vector2(-1,1),Vector2(0,1),Vector2(1,1)]
 for dir in dirs:
  for action in ["aim_left","aim_right","aim_up","aim_down"]: Input.action_release(action)
  if dir.x<0: Input.action_press("aim_left")
  if dir.x>0: Input.action_press("aim_right")
  if dir.y<0: Input.action_press("aim_up")
  if dir.y>0: Input.action_press("aim_down")
  await frames(2)
  check(player.shotgun.aim.is_equal_approx(dir.normalized()),"Manual eight-way aim "+str(dir))
 for action in ["aim_left","aim_right","aim_up","aim_down"]: Input.action_release(action)
 check(get_nodes_in_group("enemies").is_empty(),"Traversal level contains no enemies")
 check(get_nodes_in_group("projectiles").is_empty(),"Traversal level contains no hostile projectiles")
 player.global_position=Vector2(952,420)
 player.velocity=Vector2.ZERO
 await frames(25)
 check(player.spawn_point.x==952,"Touching checkpoint stores respawn position")
 player.invincible=0
 player.hurt()
 check(player.global_position.distance_to(player.spawn_point)<1,"Death returns to checkpoint")
 check(player.shotgun.ammo==2,"Respawn restores ammo")
 level.finish()
 check(paused and level.complete,"Exit completion pauses gameplay")
 paused=false
 print("RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)

func jump_key(pressed: bool) -> void:
 var event := InputEventKey.new()
 event.physical_keycode=KEY_SPACE
 event.pressed=pressed
 Input.parse_input_event(event)
 Input.flush_buffered_events()
