extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool,label: String) -> void:
 print(("PASS " if ok else "FAIL ")+label)
 if not ok: failures+=1
func frames(n: int) -> void:
 for i in n: await physics_frame
func capture(name: String) -> void:
 if DisplayServer.get_name()=="headless": return
 await create_timer(0.3,true).timeout
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/"+name+".png")
func run() -> void:
 var data=root.get_node("SaveData")
 if data.path=="user://settings.cfg":
  quit(1)
  return
 data.clear_progress()
 data.set_preference("crt_filter",true)
 var menu=load("res://scenes/ui/main_menu.tscn").instantiate()
 root.add_child(menu)
 current_scene=menu
 await frames(3)
 check(ProjectSettings.get_setting("application/run/main_scene")=="res://scenes/ui/main_menu.tscn","Project boots to main menu")
 check(root.gui_get_focus_owner()==menu.get_node("Center/Home/Start"),"Start receives keyboard focus")
 await capture("main_menu")
 menu.get_node("Center/Home/Options").pressed.emit()
 await process_frame
 check(menu.get_node("Center/Options").size.y<=360,"Shared options fit the viewport")
 menu.get_node("Center/Options/CRT").button_pressed=false
 check(not root.get_node("CRTOverlay/Filter").visible,"CRT toggle disables post-processing immediately")
 menu.get_node("Center/Options/CRT").button_pressed=true
 check(root.get_node("CRTOverlay/Filter").visible,"CRT toggle re-enables post-processing")
 await capture("main_options")
 menu.get_node("Center/Options/Back").pressed.emit()
 menu.get_node("Center/Home/Start").pressed.emit()
 check(menu.page=="Levels" and menu.levels.size()==5,"Start opens extensible level selector")
 await capture("level_select")
 menu.get_node("Center/Levels/List").get_child(0).pressed.emit()
 await scene_changed
 await frames(45)
 var level=current_scene
 check(level.scene_file_path.ends_with("training_yard.tscn"),"Selecting Lantern Ridge loads level")
 var player=level.get_node("Player")
 check(player.is_on_floor(),"Player stands on native tile collision")
 var terrain=level.get_node("Terrain")
 check(terrain.get_child_count()==13,"Original platform positions retained")
 var shared=load("res://assets/terrain_tileset.tres")
 var all_native=true
 for layer in terrain.get_children():
  all_native=all_native and layer is TileMapLayer and layer.tile_set==shared and layer.get_child_count()==0
 check(all_native,"Ground consists only of native TileMapLayers using shared external TileSet")
 check(shared.get_physics_layers_count()==1 and shared.get_physics_layer_collision_layer(0)==1,"TileSet physics uses World collision layer")
 var atlas=shared.get_source(0)
 check(atlas.get_tile_data(Vector2i(1,0),0).get_collision_polygons_count(0)==1,"Snow tiles contain collision polygons")
 check(atlas.get_tile_data(Vector2i(1,3),0).get_collision_polygons_count(0)==0,"Hanging decorations do not block movement")
 var layer=terrain.get_child(0)
 var cell=Vector2i(10,-10)
 layer.set_cell(cell,0,Vector2i(1,0))
 await frames(3)
 var center=layer.to_global(layer.map_to_local(cell))
 var ray=PhysicsRayQueryParameters2D.create(center-Vector2(0,20),center+Vector2(0,20),1)
 check(not level.get_world_2d().direct_space_state.intersect_ray(ray).is_empty(),"Painting a tile creates collision without a box")
 layer.erase_cell(cell)
 await frames(3)
 check(level.get_world_2d().direct_space_state.intersect_ray(ray).is_empty(),"Erasing a tile removes its collision")
 await capture("crt_on")
 data.set_preference("crt_filter",false)
 await capture("crt_off")
 var hud=level.get_node("HUD")
 hud._toggle_pause()
 hud._open_options()
 check(not hud.get_node("Overlay/Center/Options/CRT").button_pressed,"Pause options share main-menu preferences")
 hud.get_node("Overlay/Center/Options/CRT").button_pressed=true
 check(root.get_node("CRTOverlay/Filter").visible,"CRT can be changed while paused")
 await capture("options_menu")
 hud._close_options()
 await capture("pause_menu")
 hud.get_node("Overlay/Center/Menu/MainMenu").pressed.emit()
 await scene_changed
 await frames(3)
 check(current_scene.has_node("Center/Home") and not paused,"Pause menu returns to main menu unpaused")
 print("MENU/TILES/CRT FAILURES: ",failures)
 await root.get_node("Sfx").shutdown(1 if failures else 0)
