extends Area2D
const ORB=preload("res://scenes/actors/projectile.tscn")
@export var fire_interval := 2.1
var elapsed := 0.0
var origin := Vector2.ZERO
var time := 0.0
func _ready() -> void:
 origin=position
 elapsed=fire_interval*0.4
func _physics_process(delta: float) -> void:
 time+=delta
 position.y=origin.y+sin(time*2)*5
 var player := get_tree().get_first_node_in_group("player")
 if not player: return
 elapsed+=delta
 $Sprite2D.modulate=Color("ffbe91") if elapsed>fire_interval-0.45 else Color.WHITE
 if elapsed>=fire_interval and global_position.distance_to(player.global_position)<290:
  elapsed=0
  var orb := ORB.instantiate()
  orb.position=global_position
  orb.velocity=global_position.direction_to(player.global_position)*100
  get_parent().add_child(orb)
func hit() -> void:
 var burst=preload("res://scenes/components/burst.tscn").instantiate()
 burst.position=global_position
 get_tree().current_scene.add_child(burst)
 queue_free()
func _on_body_entered(body: Node2D) -> void:
 if body.has_method("hurt"): body.hurt()
