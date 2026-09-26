extends Area2D
## Non-lethal traversal target. The blast adds velocity away from its center.
signal detonated
@export var blast_radius := 176.0
@export var impulse := 420.0
@export var recharge_seconds := 2.5
@export var bob_phase := 0.0
var armed := true
var recharge_left := 0.0
var time := 0.0
const EXPLOSION=preload("res://scenes/components/mine_explosion.tscn")
func _physics_process(delta: float) -> void:
 time+=delta
 $Sprite2D.position.y=sin(time*2.2+bob_phase)*3.0
 $Glow.position.y=$Sprite2D.position.y
 $Sprite2D.frame=int(time*6.0)%4
 if not armed:
  recharge_left=maxf(0.0,recharge_left-delta)
  if recharge_left<=0:
   reset()
   Sfx.play_at("mine_ready",global_position,-12.0)
func hit() -> void:
 if not armed: return
 armed=false
 Sfx.play_at("mine_blast",global_position,0.0)
 recharge_left=recharge_seconds
 $Sprite2D.modulate=Color(0.45,0.55,0.65,0.4)
 $Glow.hide()
 var effect := EXPLOSION.instantiate()
 effect.position=global_position
 get_tree().current_scene.add_child(effect)
 for player in get_tree().get_nodes_in_group("player"):
  var offset: Vector2=player.global_position-global_position
  # Camera feedback also reaches nearby spectators outside the impulse radius.
  if offset.length()<360:
   player.get_node("Camera2D").impact(2.2*(1.0-offset.length()/360.0),"mine")
  if offset.length()>blast_radius: continue
  var ray := PhysicsRayQueryParameters2D.create(global_position,player.global_position,1)
  if not get_world_2d().direct_space_state.intersect_ray(ray).is_empty(): continue
  var direction := offset.normalized() if offset.length()>1 else Vector2.UP
  player.apply_blast(direction,impulse)
 detonated.emit()
func reset() -> void:
 armed=true
 recharge_left=0.0
 $Sprite2D.modulate=Color.WHITE
 $Glow.show()
