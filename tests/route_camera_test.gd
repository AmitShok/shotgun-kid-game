extends SceneTree
var failures=0
func _initialize(): call_deferred("run")
func check(ok,label):
 print(("PASS " if ok else "FAIL ")+label)
 if not ok: failures+=1
func run():
 var data=root.get_node("SaveData")
 if data.path=="user://settings.cfg": quit(1);return
 data.clear_progress();data.set_preference("crt_mode",0)
 for biome in ["mossy_comet","copper_cloud","velvet_glacier","echo_orchard"]:
  var scene=load("res://scenes/levels/"+biome+".tscn").instantiate();root.add_child(scene);current_scene=scene
  check(not scene.get_node("HUD").has_node("Bottom") and scene.get_node("Signs").get_child_count()==0,biome+" clean gameplay presentation")
  var p=scene.get_node("Player");var camera=p.get_node("Camera2D")
  var route=scene.get_meta("traversal_route")
  for index in range(route.size()):
   var step=route[index]
   if "--visual-sample" in OS.get_cmdline_user_args() and index not in ([4] if biome=="velvet_glacier" else [2,14] if biome=="echo_orchard" else [2]): continue
   if step.kind not in ["mine","shell","relay"]: continue
   p.global_position=step.launch+Vector2(0,-14);p.velocity=Vector2.ZERO
   p.spawn_point=p.global_position;camera.reset_feedback()
   for f in range(150): await physics_frame
   check(p.spawn_point.distance_to(step.start+Vector2(0,-14))<1,"landing checkpoint active")
   check(camera.route_framing,biome+" encounter view "+str(index))
   var transform=root.get_canvas_transform()
   var viewport=root.get_visible_rect().grow(-12)
   check(viewport.has_point(transform*p.global_position),"player in view")
   check(viewport.has_point(transform*(step.target+Vector2(0,-12))),"landing in view")
   if DisplayServer.get_name()!="headless" and (index==2 or (biome=="velvet_glacier" and index==4) or step.kind=="relay"):
    await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png("res://docs/route_overview_"+biome+"_%d.png"%index)
  scene.queue_free();await process_frame
 print("ROUTE CAMERA FAILURES: ",failures)
 await root.get_node("Sfx").shutdown(1 if failures else 0)
