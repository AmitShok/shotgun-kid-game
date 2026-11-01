@tool
extends Node2D
## A camera-locked room. While the player is inside its rectangle the camera clamps to it,
## and entering it moves the respawn point to its Spawn marker. Size is in pixels.
@export var size := Vector2i(640,368):
 set(value):
  size=value
  queue_redraw()
func rect() -> Rect2:
 return Rect2(global_position,Vector2(size))
func spawn_point() -> Vector2:
 return $Spawn.global_position if has_node("Spawn") else global_position+Vector2(32,size.y-40)
func _draw() -> void:
 if Engine.is_editor_hint(): draw_rect(Rect2(Vector2.ZERO,Vector2(size)),Color(1,0.8,0.3,0.7),false,2.0)
