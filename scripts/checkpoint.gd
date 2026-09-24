extends Area2D
var activated := false
func _on_body_entered(body: Node2D) -> void:
 if not body.is_in_group("player") or activated: return
 activated=true
 body.spawn_point=global_position+Vector2(0,-14)
 SaveData.save_checkpoint(self,body.spawn_point)
 $Sprite2D.modulate=Color("ffda92")
 get_tree().current_scene.checkpoint_reached()
