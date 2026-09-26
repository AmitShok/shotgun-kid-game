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
 data.set_preference("camera_zoom",false)
 var level=load("res://scenes/levels/training_yard.tscn").instantiate()
 root.add_child(level)
 current_scene=level
 var player=level.get_node("Player")
 var camera=player.get_node("Camera2D")
 await frames(40)
 check(is_equal_approx(camera.landing_zoom,1.0),"Normal ground camera remains unchanged")
 player.position=Vector2(180,100)
 player.velocity=Vector2.ZERO
 await frames(2)
 player.set_physics_process(false)
 await frames(120)
 check(camera.ground_found and absf(camera.landing_ground.y-544)<1,"Camera detects actual terrain beneath high player")
 check(camera.zoom.x<0.7 and camera.zoom.x>=camera.minimum_landing_zoom,"High flight zooms out within its limit even with cosmetic zoom off")
 camera.force_update_scroll()
 var transform=root.get_canvas_transform()
 var player_screen=transform*player.position
 var ground_screen=transform*camera.landing_ground
 check(player_screen.y>=45 and ground_screen.y<=310,"Player and landing surface fit between HUD panels")
 if DisplayServer.get_name()!="headless":
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("res://docs/landing_camera.png")
 var layer=level.get_node("Terrain").get_child(0)
 layer.position.y+=48
 await frames(4)
 check(absf(camera.landing_ground.y-592)<1,"Moving a platform automatically updates camera terrain detection")
 layer.position.y-=48
 var temporary := TileMapLayer.new()
 temporary.tile_set=load("res://assets/terrain_tileset.tres")
 level.add_child(temporary)
 temporary.set_cell(Vector2i(11,18),0,Vector2i(1,0))
 await frames(4)
 check(absf(camera.landing_ground.y-288)<1,"Painting a higher platform changes the landing target")
 check(camera.tracked_ground_y>450,"A higher ledge is blended instead of instantly replacing the framed height")
 var largest_zoom_step := 0.0
 for frame in range(24):
  var previous_zoom: float=camera.landing_zoom
  await frames(1)
  largest_zoom_step=maxf(largest_zoom_step,absf(camera.landing_zoom-previous_zoom))
 check(largest_zoom_step<0.025,"Higher-platform zoom transition stays gradual")
 temporary.erase_cell(Vector2i(11,18))
 await frames(4)
 check(absf(camera.landing_ground.y-544)<1,"Erasing that platform restores the lower target")
 Input.action_press("aim_up")
 await frames(10)
 check(camera.aim_look==Vector2.ZERO,"Airborne arrow aiming still cannot pan the camera")
 Input.action_release("aim_up")
 player.position=Vector2(4000,100)
 player.velocity=Vector2(0,450)
 await frames(5)
 check(camera.has_ground_track,"Brief gaps between ledges retain the previous framing")
 await frames(100)
 check(not camera.ground_found and camera.target_landing_zoom==1.0 and camera.target_landing_offset<=60,"An empty gap uses bounded downward look, not unlimited zoom")
 player.position=Vector2(180,500)
 player.velocity=Vector2.ZERO
 player.set_physics_process(true)
 await frames(130)
 check(player.is_on_floor() and absf(camera.landing_zoom-1.0)<0.01 and absf(camera.landing_offset)<0.1,"Landing smoothly restores normal framing")
 camera.reset_feedback()
 check(camera.landing_zoom==1 and camera.landing_offset==0,"Respawn reset clears landing framing")
 print("LANDING CAMERA FAILURES: ",failures)
 await root.get_node("Sfx").shutdown(1 if failures else 0)
