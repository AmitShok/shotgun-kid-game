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
 # An empty gun reads cold and dim, so ammo is visible without looking at the HUD.
 $Sprite2D.modulate=$Sprite2D.modulate.lerp(Color(0.55,0.62,0.78,0.85) if ammo==0 else Color.WHITE,1.0-exp(-18.0*_delta))
func refill() -> void:
 if ammo==MAX_AMMO: return
 ammo=MAX_AMMO
 ammo_changed.emit(ammo)
 Sfx.play("reload",-10.0)
func add_ammo(amount: int = 1) -> bool:
 if amount<=0 or ammo>=MAX_AMMO: return false
 ammo=mini(ammo+amount,MAX_AMMO)
 ammo_changed.emit(ammo)
 Sfx.play("reload",-8.0,1.2)
 return true
func shoot() -> bool:
 if ammo<=0 or remaining>0: return false
 ammo-=1
 remaining=cooldown
 ammo_changed.emit(ammo)
 Sfx.play("shot",-2.0,randf_range(0.96,1.04))
 fired.emit(aim)
 $Flash.visible=true
 $FlashTimer.start()
 # Wide close-range cone. A world ray blocks hits through platforms/walls.
 for group in ["shot_targets"]:
  for target in get_tree().get_nodes_in_group(group):
   var offset: Vector2=target.global_position-global_position
   # Targets may override reach and aim tolerance (spore pods: long range, tight cone).
   var reach: float=target.shot_range if "shot_range" in target else blast_range
   var cone: float=target.shot_cone if "shot_cone" in target else 0.80
   if offset.length()>reach: continue
   if offset.length()>20 and aim.dot(offset.normalized())<cone: continue
   var query := PhysicsRayQueryParameters2D.create(global_position,target.global_position,1)
   if not get_world_2d().direct_space_state.intersect_ray(query).is_empty(): continue
   target.hit()
 return true
func _on_flash_timer_timeout() -> void:
 $Flash.visible=false
