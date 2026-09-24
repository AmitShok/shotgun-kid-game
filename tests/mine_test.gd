extends SceneTree
var checks := 0
var failures := 0
var player: CharacterBody2D
var level: Node2D
var mine: Area2D
func _initialize() -> void: call_deferred("run")
func frames(count: int) -> void:
 for i in count: await physics_frame
func check(ok: bool, label: String) -> void:
 checks+=1
 if ok: print("PASS: ",label)
 else:
  failures+=1
  push_error("FAIL: "+label)
func key(code: int, pressed: bool) -> void:
 var event := InputEventKey.new()
 event.physical_keycode=code
 event.pressed=pressed
 event.shift_pressed=pressed and code==KEY_SHIFT
 Input.parse_input_event(event)
 Input.flush_buffered_events()
func run() -> void:
 level=load("res://scenes/levels/training_yard.tscn").instantiate()
 root.add_child(level)
 current_scene=level
 player=level.get_node("Player")
 mine=level.get_node("Actors/BoostMine0")
 await frames(35)
 check(get_nodes_in_group("enemies").is_empty() and get_nodes_in_group("projectiles").is_empty(),"No enemies or hostile projectiles in the level")
 player.set_physics_process(false)
 player.invincible=0
 player.position=mine.position
 await frames(3)
 check(level.deaths==0 and mine.armed,"Touching a mine is safe and does not detonate it")
 player.position=mine.position+Vector2(0,-65)
 player.velocity=Vector2.ZERO
 player.shotgun.aim=Vector2.DOWN
 player.shotgun.remaining=0
 player.shotgun.shoot()
 check(not mine.armed,"Shot detonates mine in cone")
 check(player.velocity.y< -790,"Blast adds substantial speed to normal recoil")
 check(player.shotgun.ammo==1,"Mine boost does not refill aerial ammo")
 check(level.deaths==0,"Explosion is non-lethal")
 var speed: Vector2=player.velocity
 mine.hit()
 check(player.velocity.is_equal_approx(speed),"Spent mine cannot boost twice before recharging")
 await create_timer(2.6).timeout
 check(mine.armed,"Mine automatically recharges")
 player.shotgun.refill()
 player.shotgun.remaining=0
 player.shotgun.aim=Vector2.UP
 player.shotgun.shoot()
 check(mine.armed,"Mine behind the shotgun is not triggered")
 player.shotgun.refill()
 player.shotgun.remaining=0
 player.shotgun.aim=Vector2.DOWN
 player.position=mine.position+Vector2(0,-160)
 player.shotgun.shoot()
 check(mine.armed,"Out-of-range mine is not triggered")
 # Terrain should block both a shot and a blast.
 mine.position=Vector2(180,620)
 player.position=Vector2(180,505)
 player.velocity=Vector2.ZERO
 player.shotgun.refill()
 player.shotgun.remaining=0
 player.shotgun.shoot()
 check(mine.armed,"Solid floor blocks shooting a mine")
 speed=player.velocity
 mine.hit()
 check(player.velocity.is_equal_approx(speed),"Solid floor blocks blast impulse")
 player.hurt()
 check(mine.armed,"Death resets all mines immediately")
 mine.position=Vector2(332,510)
 # Actual jump and physical Shift event into the high-road mine, then steer to land.
 player.set_physics_process(true)
 player.position=Vector2(1100,432)
 player.velocity=Vector2.ZERO
 player.invincible=999
 player.shotgun.remaining=0
 await frames(20)
 key(KEY_SPACE,true)
 await frames(12)
 key(KEY_DOWN,true)
 key(KEY_SHIFT,true)
 await frames(2)
 check(player.velocity.y< -700,"Normal jump plus shot receives mine boost in live physics")
 key(KEY_SHIFT,false)
 key(KEY_SPACE,false)
 key(KEY_DOWN,false)
 key(KEY_D,true)
 var landed := false
 for i in range(180):
  if player.position.x>1280: key(KEY_D,false)
  await frames(1)
  if player.is_on_floor() and player.position.y<230 and player.position.x>1195:
   landed=true
   break
 key(KEY_D,false)
 check(landed,"Mine-assisted jump reaches and lands on the high road")
 check(player.shotgun.ammo==2,"High-road landing restores two shells")
 print("MINE RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
