extends SceneTree
## Wind gusts (Echo Orchard): calm then gust rhythm, reset, updraft lift, headwind push, speed cap.
##   godot --headless --fixed-fps 60 --path . --script res://tests/wind_test.gd
const WIND=preload("res://scripts/wind_zone.gd")
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool,label: String) -> void:
 print(("PASS " if ok else "FAIL ")+label)
 if not ok: failures+=1
func run() -> void:
 var level: Node2D=load("res://scenes/levels/echo_orchard.tscn").instantiate()
 root.add_child(level)
 current_scene=level
 var player: CharacterBody2D=level.get_node("Player")
 var zones: Array=level.get_tree().get_nodes_in_group("wind_zones")
 check(zones.size()>=5,"echo orchard has wind zones (%d)" % zones.size())
 var zone: Node2D=zones[0]
 zone.reset()
 check(not zone.blowing(),"calm right after reset")
 zone.time=WIND.CALM-0.1
 check(zone.warning() and not zone.blowing(),"warning flickers before the gust")
 zone.time=WIND.CALM+0.1
 check(zone.blowing(),"gust after the calm")
 zone.time=WIND.CALM+WIND.GUST+0.1
 check(not zone.blowing(),"calm again after the gust")
 var updraft: Node2D
 var headwind: Node2D
 for z in zones:
  if z.direction==Vector2.UP and updraft==null: updraft=z
  if z.direction==Vector2.LEFT and headwind==null: headwind=z
 # Updraft: a still body in a gust gains upward speed, capped at max_speed.
 updraft.time=WIND.CALM+0.05
 player.global_position=updraft.rect().get_center()
 player.velocity=Vector2.ZERO
 for i in 60: updraft.push_body(player,1.0/60.0)
 check(player.velocity.y<0 and absf(player.velocity.y)<=updraft.max_speed+0.1,"updraft lifts, capped (vy=%d)" % int(player.velocity.y))
 updraft.reset()
 player.velocity=Vector2.ZERO
 updraft.push_body(player,1.0/60.0)
 check(player.velocity==Vector2.ZERO,"no push while calm")
 # Headwind: rightward motion is pushed back.
 headwind.time=WIND.CALM+0.05
 player.global_position=headwind.rect().get_center()
 player.velocity=Vector2(300,0)
 for i in 10: headwind.push_body(player,1.0/60.0)
 check(player.velocity.x<300,"headwind slows you (vx=%d)" % int(player.velocity.x))
 headwind.available=false
 player.velocity=Vector2(300,0)
 headwind.push_body(player,1.0/60.0)
 check(player.velocity.x==300,"stripped wind does nothing")
 print("WIND RESULT: %d failures" % failures)
 quit(failures)
