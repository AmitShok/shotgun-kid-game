extends SceneTree
## Spore pods light up when the player can grab them and flare when the current aim would grab them.
##   godot --headless --path . --script res://tests/pod_glow_test.gd
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
 print(("PASS " if ok else "FAIL ")+label)
 if not ok: failures+=1
func run() -> void:
 var level: Node2D=load("res://scenes/levels/mossy_comet.tscn").instantiate()
 root.add_child(level)
 current_scene=level
 var player: CharacterBody2D=level.get_node("Player")
 var pods := level.get_tree().get_nodes_in_group("spore_pods")
 # The M01 wall pod has open air to its left.
 var pod: Node2D=pods[0]
 for p in pods:
  if p.global_position.x<pod.global_position.x: pod=p
 for i in 4: await physics_frame
 player.set_physics_process(false)
 player.global_position=pod.global_position+Vector2(-400,0)
 for i in 3: await physics_frame
 check(pod.reach_state==0,"out of range stays dim (state %d)" % pod.reach_state)
 player.global_position=pod.global_position+Vector2(-150,0)
 player.shotgun.aim=Vector2.DOWN
 for i in 3: await physics_frame
 check(pod.reach_state==1,"in range lights up (state %d)" % pod.reach_state)
 player.shotgun.aim=(pod.global_position-player.shotgun.global_position).normalized()
 for i in 20: await physics_frame
 check(pod.reach_state==2,"aimed at flares (state %d)" % pod.reach_state)
 check(pod.get_node("Glow").modulate.a>0.8,"glow is bright when aimed (%.2f)" % pod.get_node("Glow").modulate.a)
 pod.hit()
 for i in 2: await physics_frame
 check(pod.reach_state==0,"spent pod goes dark")
 # From the bottom of the M03 shaft, the pods high above are off-screen and get edge arrows.
 var shaft: Node2D=level.get_node("Rooms/M03")
 player.global_position=shaft.spawn_point()
 for i in 40: await physics_frame
 var marked := 0
 for p in pods:
  if shaft.rect().has_point(p.global_position) and p.marker_alpha>0.5: marked+=1
 check(level.current_room==shaft and marked>=1,"off-screen shaft pods show edge arrows (%d)" % marked)
 # Across a doorway, the next room's pod is marked when there is a clear line to it.
 for doorway in [["M03",Vector2(14*16+8,5*16),"M04"],["M04",Vector2(5*16,20*16),"M05"]]:
  var from: Node2D=level.get_node("Rooms/"+doorway[0])
  var next: Node2D=level.get_node("Rooms/"+doorway[2])
  player.global_position=from.global_position+doorway[1]
  for i in 40: await physics_frame
  marked=0
  for p in pods:
   if next.rect().has_point(p.global_position) and p.marker_alpha>0.5: marked+=1
  check(level.current_room==from and marked>=1,"%s shows the arrow to %s's pod (%d)" % [doorway[0],doorway[2],marked])
 print("POD GLOW RESULT: %d failures" % failures)
 await root.get_node("Sfx").shutdown(1 if failures else 0)
