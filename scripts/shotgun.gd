extends Node2D
signal fired(direction: Vector2)
signal ammo_changed(value: int)
const MAX_AMMO := 2
@export var cooldown := 0.18
@export var blast_range := 140.0
var ammo := MAX_AMMO
var remaining := 0.0
var aim := Vector2.DOWN
func _physics_process(delta: float) -> void:
 remaining=maxf(0.0,remaining-delta)
func _process(_delta: float) -> void:
 rotation=aim.angle()
 $Sprite2D.flip_v=aim.x<0
func refill() -> void:
 if ammo==MAX_AMMO: return
 ammo=MAX_AMMO
 ammo_changed.emit(ammo)
func shoot() -> bool:
 if ammo<=0 or remaining>0: return false
 ammo-=1
 remaining=cooldown
 ammo_changed.emit(ammo)
 fired.emit(aim)
 $Flash.visible=true
 $FlashTimer.start()
 # Wide close-range cone. A world ray blocks hits through platforms/walls.
 for group in ["shot_targets"]:
  for target in get_tree().get_nodes_in_group(group):
   var offset: Vector2=target.global_position-global_position
   if offset.length()>blast_range: continue
   if offset.length()>20 and aim.dot(offset.normalized())<0.80: continue
   var query := PhysicsRayQueryParameters2D.create(global_position,target.global_position,1)
   if not get_world_2d().direct_space_state.intersect_ray(query).is_empty(): continue
   target.hit()
 return true
func _on_flash_timer_timeout() -> void:
 $Flash.visible=false
