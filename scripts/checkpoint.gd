extends Area2D
# Zero retains the small flag trigger used by existing levels.
@export var landing_width := 0.0
var activated := false
func _ready() -> void:
 if landing_width>0:
  var shape=RectangleShape2D.new()
  shape.size=Vector2(landing_width,40)
  $CollisionShape2D.shape=shape
func _on_body_entered(body: Node2D) -> void:
 if not body.is_in_group("player") or activated: return
 activated=true
 body.spawn_point=global_position+Vector2(0,-14)
 SaveData.save_checkpoint(self,body.spawn_point)
 $Sprite2D.modulate=Color("ffda92")
 get_tree().current_scene.checkpoint_reached()
