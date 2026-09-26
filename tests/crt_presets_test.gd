extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
 var data=root.get_node("SaveData")
 if data.path=="user://settings.cfg":
  quit(1)
  return
 var reading := "--read" in OS.get_cmdline_user_args()
 var failures := 0
 if reading and data.crt_mode!=1: failures+=1
 var menu=load("res://scenes/ui/main_menu.tscn").instantiate()
 root.add_child(menu)
 current_scene=menu
 menu._show_page("Options")
 var selector=menu.get_node("Center/Options/CRT/Preset")
 if selector.item_count!=3 or selector.selected!=data.crt_mode: failures+=1
 if not reading:
  selector.select(1)
  selector.item_selected.emit(1)
 var filter=root.get_node("CRTOverlay/Filter")
 if not filter.visible or not filter.material.shader.resource_path.ends_with("crt_light.gdshader"): failures+=1
 if not reading and DisplayServer.get_name()!="headless":
  await create_timer(0.3,true).timeout
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("res://docs/crt_light_options.png")
 print("CRT PRESETS ","RELOAD" if reading else "SELECT LIGHT",": ",failures," failures")
 await root.get_node("Sfx").shutdown(1 if failures else 0)
