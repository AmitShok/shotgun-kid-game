extends Area2D
var velocity := Vector2.ZERO
var lifetime := 0.0
func _physics_process(delta: float) -> void:
 var next := global_position+velocity*delta
 var query := PhysicsRayQueryParameters2D.create(global_position,next,3)
 var hit_result := get_world_2d().direct_space_state.intersect_ray(query)
 if not hit_result.is_empty():
  if hit_result.collider.has_method("hurt"): hit_result.collider.hurt()
  queue_free()
  return
 global_position=next
 lifetime+=delta
 if lifetime>6: queue_free()
func hit() -> void:
 var burst=preload("res://scenes/components/burst.tscn").instantiate()
 burst.position=global_position
 get_tree().current_scene.add_child(burst)
 queue_free()
func _on_body_entered(body: Node2D) -> void:
 if body.has_method("hurt"): body.hurt()
 queue_free()
