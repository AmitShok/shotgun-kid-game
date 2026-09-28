extends SceneTree
var failures := 0
func _initialize(): call_deferred("run")
func check(ok: bool, message: String):
 print(("PASS " if ok else "FAIL ")+message)
 if not ok: failures+=1
func run():
 var data=root.get_node("SaveData")
 if data.path=="user://settings.cfg":
  quit(1)
  return
 data.set_preference("crt_mode",0)
 for biome in ["mossy_comet","copper_cloud","velvet_glacier","echo_orchard"]:
  var scene=load("res://scenes/levels/"+biome+".tscn").instantiate()
  root.add_child(scene)
  current_scene=scene
  await create_timer(0.6).timeout
  check(scene.get_node("Player").is_on_floor(),biome+" player stands on terrain")
  var grid=scene.get_node("Terrain/Ground")
  var tiles=grid.tile_set
  check(tiles.get_physics_layer_collision_layer(0)==1,biome+" World collision retained")
  check(tiles.get_source(0).get_tile_data(Vector2i(1,0),0).get_collision_polygons_count(0)==1,biome+" surface tiles are solid")
  check(tiles.get_source(0).get_tile_data(Vector2i(1,3),0).get_collision_polygons_count(0)==0,biome+" hanging accents are non-solid")
  check(tiles.get_source(1).get_tile_data(Vector2i(1,0),0).get_collision_polygons_count(0)==0,biome+" props do not block movement")
  var bg=scene.get_node("Backdrop")
  check(bg.has_node("Far") and bg.has_node("Middle") and bg.has_node("Near"),biome+" three parallax depths")
  if DisplayServer.get_name()!="headless":
   await RenderingServer.frame_post_draw
   root.get_texture().get_image().save_png("res://docs/"+biome+"_theme.png")
  for prop in scene.get_node("Scenery/ThemeDetails").get_children():
   var foot=prop.global_position+Vector2(0,15)
   var query=PhysicsRayQueryParameters2D.create(foot-Vector2(0,2),foot+Vector2(0,2),1)
   check(not scene.get_world_2d().direct_space_state.intersect_ray(query).is_empty(),biome+" "+prop.name+" rests on solid ground")
  scene.queue_free()
  await process_frame
 print("BIOME FAILURES: ",failures)
 await root.get_node("Sfx").shutdown(1 if failures else 0)
