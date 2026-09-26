extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool,label: String) -> void:
 print(("PASS " if ok else "FAIL ")+label)
 if not ok: failures+=1
func frames(n: int) -> void:
 for i in n: await physics_frame
func run() -> void:
 var data=root.get_node("SaveData")
 if data.path=="user://settings.cfg":
  quit(1)
  return
 data.clear_progress()
 for key in ["camera_shake","camera_zoom","shot_shake","mine_shake"]: data.set_preference(key,true)
 var level=load("res://scenes/levels/training_yard.tscn").instantiate()
 root.add_child(level)
 current_scene=level
 var player=level.get_node("Player")
 var camera=player.get_node("Camera2D")
 await frames(45)
 Input.action_press("aim_up")
 await frames(50)
 check(camera.aim_look.y < -55,"Grounded upward aim reveals more environment")
 Input.action_release("aim_up")
 Input.action_press("aim_right")
 await frames(50)
 check(camera.aim_look.x>45,"Grounded horizontal aim pans sideways")
 Input.action_release("aim_right")
 player.position=Vector2(180,100)
 await frames(1)
 player.set_physics_process(false)
 camera.reset_feedback()
 Input.action_press("aim_down")
 await frames(15)
 check(camera.aim_look==Vector2.ZERO,"Airborne aiming cannot pan camera")
 Input.action_release("aim_down")
 camera.reset_feedback()
 data.shot_shake=false
 camera.impact(1.4,0.025,"shot")
 check(camera.shot_impact==0 and camera.zoom_kick>0,"Shot shake can be off while zoom stays on")
 camera.impact(2,0,"mine")
 check(camera.mine_impact>0,"Mine shake remains independently enabled")
 camera.reset_feedback()
 data.mine_shake=false
 data.shot_shake=true
 data.camera_zoom=false
 camera.impact(2,-0.025,"mine")
 camera.impact(1.4,0.025,"shot")
 check(camera.mine_impact==0 and camera.shot_impact>0 and camera.zoom_kick==0,"Shot shake works with mine shake and zoom disabled")
 data.camera_shake=false
 await frames(2)
 check(camera.offset==Vector2.ZERO and camera.zoom.is_equal_approx(Vector2.ONE*camera.landing_zoom),"Master shake switch suppresses all shake")
 for decoration in level.get_node("Scenery").get_children():
  if decoration.name.begins_with("Banner"): continue
  var foot=decoration.position+Vector2(decoration.texture.get_width()/2.0,decoration.texture.get_height())
  var ray=PhysicsRayQueryParameters2D.create(foot-Vector2(0,3),foot+Vector2(0,3),1)
  var supported=not level.get_world_2d().direct_space_state.intersect_ray(ray).is_empty()
  check(supported,String(decoration.name)+" rests on a platform")
 var hud=level.get_node("HUD")
 hud._toggle_pause()
 hud._open_options()
 await process_frame
 var options=hud.get_node("Overlay/Center/Options")
 check(options.size.y<=360,"All options fit the game viewport")
 if DisplayServer.get_name()!="headless":
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("res://docs/options_menu.png")
 hud._close_options()
 hud._toggle_pause()
 player.set_physics_process(true)
 for key in ["camera_shake","camera_zoom","shot_shake","mine_shake"]: data.set_preference(key,true)
 for point in [Vector2(88,528),Vector2(1000,430),Vector2(1680,440),Vector2(2430,410)]:
  player.position=point
  player.velocity=Vector2.ZERO
  camera.reset_feedback()
  await frames(45)
  if DisplayServer.get_name()!="headless":
   await RenderingServer.frame_post_draw
   root.get_texture().get_image().save_png("res://docs/scenery_%d.png" % point.x)
 print("CAMERA/SCENERY FAILURES: ",failures)
 await root.get_node("Sfx").shutdown(1 if failures else 0)
