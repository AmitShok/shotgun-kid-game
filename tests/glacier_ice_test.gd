extends SceneTree
## Velvet Glacier crumbling ice and slippery ice.
##   godot --headless --path . --script res://tests/glacier_ice_test.gd
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
 print(("PASS " if ok else "FAIL ")+label)
 if not ok: failures+=1
func block_near(level: Node, group: String, point: Vector2) -> StaticBody2D:
 for block in level.get_tree().get_nodes_in_group(group):
  if Rect2(block.global_position,Vector2(block.tiles,block.rows)*16).grow(2).has_point(point): return block
 return null
func run() -> void:
 var level: Node2D=load("res://scenes/levels/velvet_glacier.tscn").instantiate()
 root.add_child(level)
 current_scene=level
 var player: CharacterBody2D=level.get_node("Player")
 for i in 4: await physics_frame
 # V01's first crumbling ledge: stand on it and it shakes, then shatters.
 var crumble := block_near(level,"crumble_blocks",Vector2(10*16+16,12*16))
 check(crumble!=null and crumble.tiles==2,"crumble ledge is one block of 2 tiles")
 player.global_position=crumble.global_position+Vector2(16,-11)
 player.velocity=Vector2.ZERO
 for i in 6: await physics_frame
 check(crumble.state==crumble.State.SHAKING,"standing on crumbling ice starts it shaking")
 for i in 30: await physics_frame
 check(crumble.state==crumble.State.GONE and not player.is_on_floor(),"it shatters after a moment and drops the player")
 # It never regrows into the player.
 player.set_physics_process(false)
 player.global_position=crumble.global_position+Vector2(16,8)
 for i in 170: await physics_frame
 check(crumble.state==crumble.State.GONE,"it waits to regrow while the player is inside")
 player.global_position=crumble.global_position+Vector2(16,-80)
 for i in 3: await physics_frame
 check(crumble.state==crumble.State.SOLID,"it regrows once the player is clear")
 player.set_physics_process(true)
 crumble.stepped_on()
 for i in 30: await physics_frame
 player.hurt()
 for i in 2: await physics_frame
 check(crumble.state==crumble.State.SOLID,"dying restores every crumble")
 for i in 40: await physics_frame
 # Slippery ice: V02's floor keeps sliding after the input is released.
 var ice := block_near(level,"ice",level.get_node("Rooms/V02").global_position+Vector2(10*16,19*16))
 check(ice!=null,"V02 has a slick ice floor")
 player.global_position=ice.global_position+Vector2(40,-11)
 player.velocity=Vector2(170,0)
 for i in 3: await physics_frame
 var start_x: float=player.global_position.x
 for i in 30: await physics_frame
 var ice_slide: float=player.global_position.x-start_x
 check(player.on_ice and ice_slide>25,"ice keeps momentum with no input (slid %.0fpx)" % (player.global_position.x-start_x))
 var ground: Vector2=level.get_node("Rooms/V01").spawn_point()
 player.global_position=ground
 player.velocity=Vector2(170,0)
 for i in 3: await physics_frame
 start_x=player.global_position.x
 for i in 30: await physics_frame
 check(not player.on_ice and (player.global_position.x-start_x)*5<ice_slide,"normal ground stops far sooner (slid %.0fpx)" % (player.global_position.x-start_x))
 print("GLACIER ICE RESULT: %d failures" % failures)
 await root.get_node("Sfx").shutdown(1 if failures else 0)
