extends SceneTree
## Scenery props break when shot or caught in a mine blast, scatter debris that settles on the
## ground, clean up after themselves, and stay broken.
##   godot --headless --path . --script res://tests/breakable_decor_test.gd -- --save-file=user://breakable.cfg
## Run windowed with -- --shot=<png> to also save a screenshot mid-break.
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool,label: String) -> void:
 print(("PASS " if ok else "FAIL ")+label)
 if not ok: failures+=1
func frames(n: int) -> void:
 for i in n: await physics_frame
func run() -> void:
 var shot_path := ""
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--shot="): shot_path=arg.trim_prefix("--shot=")
 change_scene_to_file("res://scenes/levels/echo_orchard_4.tscn")
 await frames(10)
 var level=current_scene
 var props: Array=get_nodes_in_group("breakable_decor")
 check(props.size()>10,"Scenery props are breakable (%d)" % props.size())
 var player=level.get_node("Player")
 # Stand the kid beside a prop and fire straight at it.
 var prop: Sprite2D=props[0]
 player.global_position=prop.global_position+Vector2(-40,6)
 player.velocity=Vector2.ZERO
 player.get_node("Camera2D").reset_smoothing()
 await frames(4)
 var gun=player.get_node("Shotgun")
 gun.ammo=2
 gun.remaining=0.0
 gun.aim=(prop.global_position-gun.global_position).normalized()
 gun.shoot()
 await frames(2)
 check(prop.broken,"A shotgun blast breaks the prop")
 check(prop.pieces.size()>=3,"It breaks into pieces of its own sprite (%d)" % prop.pieces.size())
 check(prop.self_modulate.a==0.0,"The whole prop is no longer drawn")
 check(not prop.is_in_group("shot_targets"),"A broken prop is no longer a target")
 var mean_x := 0.0
 for p in prop.pieces: mean_x+=p.node.global_position.x
 await frames(12)
 var later := 0.0
 for p in prop.pieces: later+=p.node.global_position.x
 check(later>mean_x,"Debris flies away from the kid")
 if not shot_path.is_empty():
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(shot_path)
 await frames(150)
 var resting := 0
 for p in prop.pieces: if p.resting: resting+=1
 check(resting>=prop.pieces.size()/2,"Debris settles on the ground (%d of %d)" % [resting,prop.pieces.size()])
 await frames(150)
 check(prop.pieces.is_empty(),"Debris fades away and is freed")
 check(prop.broken,"The prop stays broken")
 # A mine going off breaks props within its blast.
 var other: Sprite2D=null
 for p in props: if not p.broken: other=p;break
 var mine=load("res://scenes/actors/boost_mine.tscn").instantiate()
 level.add_child(mine)
 mine.global_position=other.global_position+Vector2(30,-10)
 await frames(2)
 mine.hit()
 await frames(2)
 check(other.broken,"A mine blast breaks nearby props")
 print("BREAKABLE DECOR FAILURES: ",failures)
 quit(1 if failures else 0)
