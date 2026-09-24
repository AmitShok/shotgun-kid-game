extends SceneTree
var player: CharacterBody2D
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func frames(count: int) -> void:
 for i in count: await physics_frame
func key(code: int, pressed: bool) -> void:
 var event := InputEventKey.new()
 event.physical_keycode=code
 event.keycode=code
 event.device=0
 event.pressed=pressed
 event.shift_pressed=pressed and code==KEY_SHIFT
 Input.parse_input_event(event)
 Input.flush_buffered_events()
func check(ok: bool, label: String) -> void:
 checks+=1
 if ok: print("PASS: ",label)
 else:
  failures+=1
  push_error("FAIL: "+label)
func ground_reset() -> void:
 for code in [KEY_SPACE,KEY_SHIFT,KEY_DOWN,KEY_LEFT]: key(code,false)
 player.position=Vector2(180,510)
 player.velocity=Vector2.ZERO
 player.recoil_lock=0
 player.fire_buffer=0
 player.jump_buffer=0
 player.shotgun.remaining=0
 player.shotgun.refill()
 await frames(40)
func run() -> void:
 var level=load("res://scenes/levels/training_yard.tscn").instantiate()
 root.add_child(level)
 current_scene=level
 player=level.get_node("Player")
 player.invincible=999
 for enemy in get_nodes_in_group("enemies"): enemy.queue_free()
 await ground_reset()
 key(KEY_SPACE,true)
 await frames(3)
 check(not player.is_on_floor() and player.shotgun.ammo==2,"Normal jump leaves both shells available")
 key(KEY_DOWN,true)
 key(KEY_LEFT,true)
 key(KEY_SHIFT,true)
 await frames(2)
 check(player.shotgun.ammo==1 and player.velocity.x>0 and player.velocity.y<0,"Shift fires diagonally while Space remains held")
 await ground_reset()
 key(KEY_SPACE,true)
 key(KEY_SHIFT,true)
 await frames(2)
 check(player.shotgun.ammo==1 and player.velocity.y< -300,"Jump and fire together defaults to upward recoil")
 await ground_reset()
 player.position=Vector2(180,510)
 player.velocity=Vector2(0,180)
 await frames(2)
 player.shotgun.ammo=0
 for i in range(30):
  await frames(1)
  if player.is_on_floor(): break
 check(player.is_on_floor() and player.shotgun.ammo==2,"First landing tick restores both shells")
 key(KEY_SPACE,true)
 await frames(2)
 check(not player.is_on_floor(),"Immediate next jump is allowed")
 key(KEY_DOWN,true)
 key(KEY_SHIFT,true)
 await frames(2)
 check(player.shotgun.ammo==1 and player.velocity.y< -300,"Shot works immediately after a quick landing and normal jump")
 for code in [KEY_SPACE,KEY_SHIFT,KEY_DOWN]: key(code,false)
 await frames(14)
 key(KEY_SHIFT,true)
 await frames(2)
 check(player.shotgun.ammo==0,"Second aerial shot still consumes final shell")
 key(KEY_SHIFT,false)
 await frames(14)
 key(KEY_SHIFT,true)
 await frames(2)
 check(player.shotgun.ammo==0,"Normal jump does not grant unlimited air ammo")
 key(KEY_SHIFT,false)
 print("JUMP/FIRE RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
