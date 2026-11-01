extends SceneTree
# Golden shell lifecycle (grab, follow, lost on death, banked at checkpoint) and best-run records.
var failures := 0
var checks := 0
func _initialize() -> void: call_deferred("run")
func frames(count: int) -> void:
 for i in count: await physics_frame
func check(ok: bool, label: String) -> void:
 checks+=1
 print(("PASS: " if ok else "")+label)
 if not ok:
  failures+=1
  push_error("FAIL: "+label)
func run() -> void:
 var save=root.get_node("SaveData")
 save.reset_progress()
 var level=load("res://scenes/levels/training_yard.tscn").instantiate()
 root.add_child(level)
 current_scene=level
 var player: CharacterBody2D=level.get_node("Player")
 # A private test floor well away from the level's rooms, independent of its layout.
 var floor_body := StaticBody2D.new()
 var floor_shape := CollisionShape2D.new()
 var box := RectangleShape2D.new()
 box.size=Vector2(800,32)
 floor_shape.shape=box
 floor_body.position=Vector2(-3000,16)
 floor_body.add_child(floor_shape)
 level.add_child(floor_body)
 var shell=load("res://scenes/actors/golden_shell.tscn").instantiate()
 shell.position=Vector2(-3000,-120)
 level.add_child(shell)
 await frames(30)
 var scene: String=level.scene_file_path
 player.invincible=999
 player.global_position=shell.home
 player.velocity=Vector2.ZERO
 await frames(2)
 check(shell.state==shell.State.FOLLOWING,"Touching the golden shell picks it up")
 player.invincible=0
 player.hurt()
 check(shell.state==shell.State.RETURNING,"Death before landing drops the carried shell")
 await frames(60)
 check(shell.state==shell.State.WAITING and shell.global_position.distance_to(shell.home)<1,"Dropped shell flies back home")
 check(not save.has_golden_shell(scene),"Dying before landing banks nothing")
 player.respawn()
 player.invincible=999
 player.global_position=shell.home
 player.velocity=Vector2.ZERO
 await frames(2)
 player.global_position=Vector2(-2900,-12)
 var gap_before: float=shell.global_position.distance_to(player.global_position)
 await frames(6)
 check(shell.state==shell.State.FOLLOWING and shell.global_position.distance_to(player.global_position)<gap_before,"Carried shell trails the player")
 await frames(25)
 check(shell.state==shell.State.BANKED and save.has_golden_shell(scene),"Landing safely banks the carried shell")
 var config := ConfigFile.new()
 config.load(save.path)
 check(scene in config.get_value("records","golden_shells",[]),"Banked shell is written to the save file")
 var first: Dictionary=save.record_run(scene,95.5,4)
 check(first.first,"First clear creates a record")
 var slower: Dictionary=save.record_run(scene,120.0,2)
 check(not slower.time and slower.falls,"A slower run with fewer falls keeps best time, improves falls")
 check(is_equal_approx(save.best_record(scene).time,95.5) and save.best_record(scene).falls==2,"Best time and fewest falls are tracked independently")
 check(save.format_time(95.5)=="01:35.50","Times display as minutes, seconds and hundredths")
 save.reset_progress()
 check(not save.has_golden_shell(scene) and save.best_record(scene).is_empty(),"Reset progress clears replay goals")
 print("REPLAY GOALS RESULT: %d checks, %d failures" % [checks,failures])
 await root.get_node("Sfx").shutdown(1 if failures else 0)
