extends Area2D
## Restores one airborne shot. Full/grounded players leave it available.
signal collected
@export_range(0.2,30.0,0.1) var recharge_seconds := 3.0
@export var bob_phase := 0.0
var available := true
var recharge_left := 0.0
var time := 0.0
func _physics_process(delta: float) -> void:
 time+=delta
 $Visual.position.y=sin(time*2.4+bob_phase)*3.0
 $CollisionShape2D.position.y=$Visual.position.y
 $Visual.modulate.a=move_toward($Visual.modulate.a,1.0 if available else 0.12,delta*5.0)
 $Visual/Glow.modulate.a=0.45+sin(time*3.0)*0.08 if available else 0.12
 if not available:
  recharge_left=maxf(0.0,recharge_left-delta)
  if recharge_left>0: return
  reset()
  Sfx.play_at("mine_ready",global_position,-18.0)
 # Poll overlaps so jumping or firing while already inside the area also works.
 for body in get_overlapping_bodies():
  if try_collect(body): break
func try_collect(body: Node2D) -> bool:
 if not available or not body.is_in_group("player") or body.is_on_floor(): return false
 var ray := PhysicsRayQueryParameters2D.create(global_position,body.global_position,1)
 if not get_world_2d().direct_space_state.intersect_ray(ray).is_empty(): return false
 if not body.shotgun.add_ammo(1): return false
 available=false
 recharge_left=recharge_seconds
 collected.emit()
 return true
func reset() -> void:
 available=true
 recharge_left=0.0
 $Visual.modulate.a=1.0
