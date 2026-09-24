extends SceneTree
var failures := 0
var checks := 0
var player: CharacterBody2D
func _initialize() -> void: call_deferred("run")
func frames(count: int) -> void:
 for i in count: await physics_frame
func key(code: int, down: bool, shift: bool = false) -> void:
 var event := InputEventKey.new()
 event.device=0
 event.physical_keycode=code
 event.keycode=code
 event.pressed=down
 event.shift_pressed=shift
 Input.parse_input_event(event)
 Input.flush_buffered_events()
func check(ok: bool, label: String) -> void:
 checks+=1
 if ok: print("PASS: ",label)
 else:
  failures+=1
  push_error("FAIL: "+label)
func reset_player() -> void:
 player.global_position=Vector2(250,270)
 player.velocity=Vector2.ZERO
 player.shotgun.refill()
 player.shotgun.remaining=0
 player.invincible=999
 await frames(2)
func run() -> void:
 var level=load("res://scenes/levels/training_yard.tscn").instantiate()
 root.add_child(level)
 current_scene=level
 player=level.get_node("Player")
 await frames(2)
 for enemy in get_nodes_in_group("enemies"): enemy.queue_free()
 for fire_key in [KEY_J,KEY_SHIFT]:
  for horizontal in [KEY_LEFT,KEY_RIGHT]:
   for vertical in [KEY_UP,KEY_DOWN]:
    await reset_player()
    key(horizontal,true)
    key(vertical,true)
    key(fire_key,true,fire_key==KEY_SHIFT)
    await frames(2)
    key(fire_key,false)
    var expected := Vector2(-1 if horizontal==KEY_LEFT else 1,-1 if vertical==KEY_UP else 1).normalized()
    check(player.shotgun.ammo==1 and player.shotgun.aim.is_equal_approx(expected),"Physical diagonal %s+%s with %s" % [horizontal,vertical,fire_key])
    key(horizontal,false)
    key(vertical,false)
 for fire_key in [KEY_J,KEY_SHIFT]:
  await reset_player()
  key(KEY_LEFT,true)
  key(KEY_DOWN,true)
  key(fire_key,true,fire_key==KEY_SHIFT)
  await frames(2)
  key(fire_key,false)
  await frames(2)
  key(fire_key,true,fire_key==KEY_SHIFT)
  await frames(2)
  key(fire_key,false)
  await frames(12)
  check(player.shotgun.ammo==0,"Fast second diagonal tap survives cooldown: %s" % fire_key)
  key(KEY_LEFT,false)
  key(KEY_DOWN,false)
 await reset_player()
 key(KEY_J,true)
 key(KEY_J,false)
 await frames(3)
 check(player.shotgun.ammo==1,"Tap entirely between physics ticks is captured")
 await frames(15)
 check(player.shotgun.ammo==1,"One tap never auto-fires the second shell")
 key(KEY_LEFT,false)
 key(KEY_DOWN,false)
 await reset_player()
 key(KEY_SHIFT,true,true)
 await frames(2)
 key(KEY_LEFT,true,true)
 key(KEY_DOWN,true,true)
 await frames(18)
 check(player.shotgun.ammo==1,"Holding Shift while changing aim never repeats a shot")
 key(KEY_SHIFT,false)
 key(KEY_LEFT,false)
 key(KEY_DOWN,false)
 player.shotgun.ammo=0
 key(KEY_SHIFT,true,true)
 key(KEY_SHIFT,false)
 player.shotgun.refill()
 await frames(18)
 check(player.shotgun.ammo==2,"Empty-gun tap cannot fire after refill")
 check(not InputMap.has_action("mode") and root.get_node_or_null("Settings")==null,"Auto-aim mode and settings autoload removed")
 print("MANUAL FIRE RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
