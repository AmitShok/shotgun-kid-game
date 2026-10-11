extends SceneTree
var failures=0
func _initialize(): call_deferred("run")
func check(ok,label):
 print(("PASS " if ok else "FAIL ")+label)
 if not ok: failures+=1
func frames(n):
 for i in range(n): await physics_frame
func run():
 if root.get_node("SaveData").path=="user://settings.cfg": quit(1);return
 var scene=load("res://scenes/levels/training_yard.tscn").instantiate();root.add_child(scene);current_scene=scene
 var p=scene.get_node("Player");var scarf=p.get_node("Scarf")
 await frames(30)
 Input.action_press("right");await frames(22);Input.action_release("right")
 check(scarf.points.back().x<scarf.anchor().x,"Scarf trails behind movement")
 var previous=scarf.anchor();var bounded=true
 for point in scarf.points:
  bounded=bounded and point.distance_to(previous)<=scarf.segment_length+0.01
  previous=point
 check(bounded,"Scarf segment lengths stay bounded")
 p.shotgun.aim=Vector2.DOWN;p.shotgun.shoot();await frames(3)
 check(get_nodes_in_group("traversal_particles").size()>0,"Shot creates native particle emitters")
 paused=true
 var frozen=scarf.points.duplicate()
 for i in range(5): await process_frame
 check(frozen==scarf.points,"Scarf freezes while paused")
 paused=false
 p.spawn_point=Vector2(1200,300);p.respawn()
 check(scarf.anchor().distance_to(scarf.points.back())<24,"Respawn resets scarf without a screen-wide streak")
 p.set_physics_process(false)
 for i in range(100):
  preload("res://scripts/traversal_particles.gd").burst(p,p.position,Vector2.UP,"land")
 check(get_nodes_in_group("traversal_particles").size()<=40,"Particle emitter budget enforced")
 await frames(100)
 check(get_nodes_in_group("traversal_particles").is_empty(),"One-shot emitters clean themselves up")
 print("SCARF/PARTICLE FAILURES: ",failures)
 await root.get_node("Sfx").shutdown(1 if failures else 0)
