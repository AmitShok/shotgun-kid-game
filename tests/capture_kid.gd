extends SceneTree
# Rendered-only: saves gameplay shots of the redrawn kid idle, running, airborne and landing.
# Usage: godot --path . --script res://tests/capture_kid.gd -- --out=<folder>
func _initialize() -> void: call_deferred("run")
func frames(count: int) -> void:
 for i in count: await physics_frame
var player: CharacterBody2D
func shot(out: String, name: String) -> void:
 await RenderingServer.frame_post_draw
 var image := root.get_texture().get_image()
 image.save_png(out.path_join(name+".png"))
 # Close-up around the kid, scaled up with nearest filtering for pixel review.
 var scale := image.get_size().x/640.0
 var at: Vector2=player.get_global_transform_with_canvas().origin*scale
 var box := Rect2i(Vector2i(at)-Vector2i(int(40*scale),int(30*scale)),Vector2i(int(80*scale),int(50*scale)))
 var crop := image.get_region(box.intersection(Rect2i(Vector2i.ZERO,image.get_size())))
 crop.resize(crop.get_width()*4/int(scale),crop.get_height()*4/int(scale),Image.INTERPOLATE_NEAREST)
 crop.save_png(out.path_join(name+"_closeup.png"))
func press(action: String, on: bool) -> void:
 if on: Input.action_press(action)
 else: Input.action_release(action)
func run() -> void:
 var out := "res://docs"
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--out="): out=arg.trim_prefix("--out=")
 var level=load("res://scenes/levels/training_yard.tscn").instantiate()
 root.add_child(level)
 current_scene=level
 player=level.get_node("Player")
 player.invincible=999
 root.get_node("SaveData").set_preference("crt_mode",0)
 await frames(60)
 await shot(out,"kid_idle")
 press("right",true)
 await frames(16)
 await shot(out,"kid_run")
 press("jump",true)
 await frames(6)
 await shot(out,"kid_rise")
 press("jump",false)
 await frames(22)
 await shot(out,"kid_fall")
 press("right",false)
 await root.get_node("Sfx").shutdown()
