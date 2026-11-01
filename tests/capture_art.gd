extends SceneTree
## Screenshots for reviewing art: the main menu, and a view into the first room of every world's
## first and third level. Run windowed (not headless):
##   godot --path . --script res://tests/capture_art.gd -- --out=<folder>
func _initialize() -> void: call_deferred("run")
func frames(count: int) -> void:
 for i in count: await process_frame
func shot(out: String, name: String) -> void:
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(out.path_join(name+".png"))
func run() -> void:
 var out := "res://docs/art_capture"
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--out="): out=arg.trim_prefix("--out=")
 DirAccess.make_dir_recursive_absolute(out)
 change_scene_to_file("res://scenes/ui/main_menu.tscn")
 await frames(90)
 await shot(out,"menu")
 for map in ["lantern_ridge","mossy_comet","copper_cloud","velvet_glacier","echo_orchard","lantern_ridge_3","velvet_glacier_3","echo_orchard_4"]:
  change_scene_to_file("res://scenes/levels/%s.tscn" % map)
  await frames(80)
  await shot(out,map)
 quit()
