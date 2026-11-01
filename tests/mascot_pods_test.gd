extends SceneTree
## The title screen's kid uses spore pods as well as mines. Over a few minutes of the menu he
## should pull on pods several times, every pod shot should end with him reaching the pod (a
## pull that does), he should stay on screen while rising, and he should rarely fall into a pit.
##   godot --headless --fixed-fps 60 --path . --script res://tests/mascot_pods_test.gd -- --save-file=user://mascot_pods.cfg
func _initialize() -> void: call_deferred("run")
func run() -> void:
 var menu=load("res://scenes/ui/main_menu.tscn").instantiate()
 root.add_child(menu);current_scene=menu
 var m=menu.get_node("Mascot")
 var pulls:=0;var arrivals:=0;var last:="";var pod_falls:=0;var highest:=999.0
 var in_pull:=false
 for i in 60*240:
  await process_frame
  if m.plan!=last:
   if m.plan=="pull": pulls+=1;in_pull=true
   elif in_pull:
    if last=="pull" and m.plan=="flying": arrivals+=1
    in_pull=false
   last=m.plan
  if m.vel.y<0 and m.clock>1.0: highest=minf(highest,m.pos.y)
 var failures:=0
 if pulls<5: failures+=1;print("FAIL only ",pulls," pod pulls in four minutes")
 if arrivals<pulls-1: failures+=1;print("FAIL ",pulls-arrivals," of ",pulls," pod shots did not pull the kid to the pod")
 if highest<40: failures+=1;print("FAIL the kid rose to ",highest,"px from the top (should stay on screen)")
 if m.falls>5: failures+=1;print("FAIL ",m.falls," falls into pits")
 print("MASCOT PODS: ",pulls," pulls, ",arrivals," arrivals, ",m.falls," falls, highest ",int(highest),"px, ",failures," failures")
 quit(1 if failures else 0)
