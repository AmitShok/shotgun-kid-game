extends SceneTree
## The title screen's kid uses spore pods as well as mines: over a few minutes of the menu he
## should pull on pods several times and never fall into a pit because of one.
##   godot --headless --fixed-fps 60 --path . --script res://tests/mascot_pods_test.gd -- --save-file=user://mascot_pods.cfg
func _initialize() -> void: call_deferred("run")
func run() -> void:
 var menu=load("res://scenes/ui/main_menu.tscn").instantiate()
 root.add_child(menu);current_scene=menu
 var m=menu.get_node("Mascot")
 var pulls:=0;var last:="";var falls:=0;var pod_falls:=0
 for i in 60*240:
  await process_frame
  if m.falls>falls:
   falls=m.falls
   var col=m.columns[clampi(int(m.pos.x/16),0,m.columns.size()-1)]
   if last in ["pod","pull"] or col.podpit: pod_falls+=1
  if m.plan!=last:
   if m.plan=="pull": pulls+=1
   last=m.plan
 var failures:=0
 if pulls<5: failures+=1;print("FAIL only ",pulls," pod pulls in four minutes")
 if pod_falls>0: failures+=1;print("FAIL ",pod_falls," falls during pod moves")
 print("MASCOT PODS: ",pulls," pulls, ",falls," falls, ",failures," failures")
 quit(1 if failures else 0)
