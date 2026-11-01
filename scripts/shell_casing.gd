extends Sprite2D
## Cosmetic spent shell: arcs out of the gun, bounces off world geometry, then fades. No collision body.
const LIFETIME := 1.1
var velocity := Vector2.ZERO
var spin := 0.0
var age := 0.0
var bounces := 0
func _ready() -> void:
 add_to_group("shell_casings")
 z_index=2
func _physics_process(delta: float) -> void:
 age+=delta
 velocity.y+=700.0*delta
 var step := velocity*delta
 var hit := get_world_2d().direct_space_state.intersect_ray(PhysicsRayQueryParameters2D.create(global_position,global_position+step,1))
 if hit.is_empty():
  global_position+=step
 else:
  global_position=hit.position+hit.normal
  velocity=velocity.bounce(hit.normal)*0.38
  spin*=0.5
  bounces+=1
  if bounces==1: Sfx.play_at("step",global_position,-20.0)
 rotation+=spin*delta
 modulate.a=clampf((LIFETIME-age)/0.3,0.0,1.0)
 if age>=LIFETIME: queue_free()
static func eject(host: Node2D,at: Vector2,aim: Vector2,facing: float) -> void:
 # Keep the scene light during rapid play.
 var existing: Array=host.get_tree().get_nodes_in_group("shell_casings")
 if existing.size()>=8: existing[0].queue_free()
 var casing=new()
 casing.texture=preload("res://assets/textures/shell.png")
 casing.scale=Vector2(0.75,0.75)
 casing.modulate=Color("ff9a76")
 casing.global_position=at
 # Out of the side opposite the muzzle, with some upward kick.
 var side: float=-signf(aim.x) if absf(aim.x)>0.1 else -facing
 casing.velocity=Vector2(side*randf_range(60,110),randf_range(-170,-120))
 casing.spin=randf_range(14,22)*side
 host.get_tree().current_scene.add_child(casing)
