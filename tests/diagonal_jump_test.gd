extends SceneTree
var player: CharacterBody2D
var failures := 0
var checks := 0
func _initialize() -> void: call_deferred("run")
func frames(count: int) -> void:
 for i in count: await physics_frame
func key(code: int, pressed: bool) -> void:
 var event := InputEventKey.new()
 event.device=0
 event.physical_keycode=code
 event.keycode=code
 event.pressed=pressed
 Input.parse_input_event(event)
 Input.flush_buffered_events()
func run() -> void:
 var level=load("res://scenes/levels/training_yard.tscn").instantiate()
 root.add_child(level)
 current_scene=level
 player=level.get_node("Player")
 player.invincible=999
 for enemy in get_nodes_in_group("enemies"): enemy.queue_free()
 var jump_keys=[KEY_SPACE]
 if "--alternates" in OS.get_cmdline_user_args(): jump_keys.append_array([KEY_W,KEY_CTRL])
 for jump_key in jump_keys:
  for movement in [0,KEY_A,KEY_D]:
   for horizontal in [KEY_LEFT,KEY_RIGHT]:
    for vertical in [KEY_UP,KEY_DOWN]:
     for simultaneous in [false,true]:
      for code in [KEY_SPACE,KEY_W,KEY_CTRL,KEY_A,KEY_D,KEY_LEFT,KEY_RIGHT,KEY_UP,KEY_DOWN]: key(code,false)
      player.position=Vector2(180,510)
      player.velocity=Vector2.ZERO
      player.jump_buffer=0
      player.recoil_lock=0
      player.shotgun.refill()
      await frames(25)
      if movement!=0: key(movement,true)
      key(horizontal,true)
      key(vertical,true)
      if not simultaneous: await frames(3)
      key(jump_key,true)
      await frames(3)
      var expected := Vector2(-1 if horizontal==KEY_LEFT else 1,-1 if vertical==KEY_UP else 1).normalized()
      var ok: bool = not player.is_on_floor() and player.velocity.y< -200 and player.shotgun.ammo==2 and player.shotgun.aim.is_equal_approx(expected)
      checks+=1
      if not ok:
       failures+=1
       push_error("Jump failed: key=%s move=%s aim=%s simultaneous=%s" % [jump_key,movement,expected,simultaneous])
 for code in [KEY_SPACE,KEY_W,KEY_CTRL,KEY_A,KEY_D,KEY_LEFT,KEY_RIGHT,KEY_UP,KEY_DOWN]: key(code,false)
 print("DIAGONAL JUMP RESULT: %d combinations, %d failures" % [checks,failures])
 await root.get_node("Sfx").shutdown(1 if failures else 0)
