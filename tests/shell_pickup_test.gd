extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func frames(n: int) -> void:
 for i in n: await physics_frame
func check(ok: bool,label: String) -> void:
 print(("PASS " if ok else "FAIL ")+label)
 if not ok: failures+=1
func run() -> void:
 var data=root.get_node("SaveData")
 if data.path=="user://settings.cfg":
  quit(1)
  return
 data.clear_progress()
 var level=load("res://scenes/levels/training_yard.tscn").instantiate()
 root.add_child(level)
 current_scene=level
 var player=level.get_node("Player")
 var pickup=level.get_node("Pickups/ShellPickup0")
 await frames(40)
 player.shotgun.ammo=0
 check(not pickup.try_collect(player) and pickup.available,"Grounded players cannot consume the pickup")
 player.position=Vector2(245,450)
 player.velocity=Vector2.ZERO
 player.shotgun.ammo=2
 await frames(2)
 player.set_physics_process(false)
 await frames(3)
 check(not player.is_on_floor() and pickup.available and player.shotgun.ammo==2,"Full airborne ammo leaves pickup available")
 player.shotgun.ammo=0
 await frames(3)
 check(player.shotgun.ammo==1 and not pickup.available,"Actual airborne overlap restores exactly one shot")
 check(not pickup.try_collect(player) and player.shotgun.ammo==1,"Spent pickup cannot grant a second shot")
 await frames(20)
 check(pickup.get_node("Visual").modulate.a<0.2,"Collected pickup fades to a faint silhouette")
 var before: float=pickup.recharge_left
 paused=true
 await create_timer(0.15,true).timeout
 check(is_equal_approx(before,pickup.recharge_left),"Recharge pauses with gameplay")
 paused=false
 player.position=Vector2(160,420)
 await frames(185)
 check(pickup.available,"Pickup becomes reusable after three seconds")
 player.position=Vector2(245,465)
 await frames(4)
 check(player.shotgun.ammo==2 and not pickup.available,"Recharged pickup restores one shell without exceeding two")
 player.shotgun.aim=Vector2.DOWN
 player.shotgun.remaining=0
 check(player.shotgun.shoot() and player.shotgun.ammo==1,"Restored shell can immediately be fired in the air")
 level._on_player_died()
 check(pickup.available and pickup.recharge_left==0,"Respawning resets the pickup")
 player.position=Vector2(160,420)
 player.shotgun.ammo=2
 await frames(5)
 check(not player.shotgun.add_ammo(1) and player.shotgun.ammo==2,"Ammo restoration never exceeds magazine capacity")
 pickup.reset()
 player.position=Vector2(160,480)
 player.shotgun.ammo=0
 player.get_node("Camera2D").reset_feedback()
 if DisplayServer.get_name()!="headless":
  await frames(8)
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("res://docs/shell_pickup.png")
 print("SHELL PICKUP FAILURES: ",failures)
 await root.get_node("Sfx").shutdown(1 if failures else 0)
