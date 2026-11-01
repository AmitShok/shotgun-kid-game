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
 if not body.is_in_group("player"): return
 # Any checkpoint, even a used one, banks a golden shell the player is carrying.
 get_tree().call_group("golden_shells","bank")
 if activated: return
 activated=true
 body.spawn_point=global_position+Vector2(0,-14)
 SaveData.save_checkpoint(self,body.spawn_point)
 $Sprite2D.modulate=Color("ffda92")
 preload("res://scripts/traversal_particles.gd").burst(self,global_position+Vector2(0,-24),Vector2.UP,"gold",0.6)
 var wave := create_tween()
 wave.tween_property($Sprite2D,"scale",Vector2(1.25,0.85),0.07)
 wave.tween_property($Sprite2D,"scale",Vector2.ONE,0.25).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
 get_tree().current_scene.checkpoint_reached()
