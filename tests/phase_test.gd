extends SceneTree
## Copper Cloud phase plates and switches.
##   godot --headless --path . --script res://tests/phase_test.gd
const PHASE=preload("res://scripts/phase_block.gd")
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
 print(("PASS " if ok else "FAIL ")+label)
 if not ok: failures+=1
func plate_at(level: Node, point: Vector2) -> StaticBody2D:
 for plate in level.get_tree().get_nodes_in_group("phase_blocks"):
  if Rect2(plate.global_position,Vector2(plate.tiles,plate.rows)*16).has_point(point): return plate
 return null
func run() -> void:
 var level: Node2D=load("res://scenes/levels/copper_cloud.tscn").instantiate()
 root.add_child(level)
 current_scene=level
 var player: CharacterBody2D=level.get_node("Player")
 for i in 4: await physics_frame
 var gate := plate_at(level,Vector2(22*16+4,10*16))
 var bridge := plate_at(level,Vector2(30*16,19*16+8))
 check(gate!=null and bridge!=null,"C01 gate and bridge are built as plates")
 check(gate.rows>1,"a gate is one plate, not one per row (%d rows)" % gate.rows)
 check(PHASE.phase==0 and gate.solid and not bridge.solid,"rooms start copper: gate solid, bridge hollow")
 var switch: Node2D=level.get_tree().get_nodes_in_group("phase_switches")[0]
 switch.hit()
 await physics_frame
 check(PHASE.phase==1 and not gate.solid and bridge.solid,"a switch hit swaps: gate hollow, bridge solid")
 # Two switches struck by one shot are a single swap.
 await physics_frame
 PHASE.toggle(self)
 PHASE.toggle(self)
 check(PHASE.phase==0,"one swap per physics frame")
 PHASE.set_phase(self,1)
 # A plate never closes on the player: it waits until they are clear.
 player.set_physics_process(false)
 player.global_position=gate.global_position+Vector2(16,60)
 await physics_frame
 await physics_frame
 PHASE.set_phase(self,0)
 check(gate.pending and not gate.solid,"a gate closing on the player waits")
 player.global_position=gate.global_position+Vector2(-40,60)
 for i in 3: await physics_frame
 check(gate.solid and not gate.pending,"it locks solid once the player is clear")
 player.set_physics_process(true)
 PHASE.set_phase(self,1)
 player.hurt()
 check(PHASE.phase==0,"dying resets to copper")
 for i in 40: await physics_frame
 PHASE.set_phase(self,1)
 player.global_position=level.get_node("Rooms/C02").spawn_point()
 for i in 3: await physics_frame
 check(String(level.current_room.name)=="C02" and PHASE.phase==0,"entering a room resets to copper")
 print("PHASE RESULT: %d failures" % failures)
 await root.get_node("Sfx").shutdown(1 if failures else 0)
