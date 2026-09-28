extends CanvasLayer
## Screen-space painted planes: camera zoom cannot reveal the edges of the backdrop.
@export var far_scroll := Vector2(0.06, 0.025)
@export var middle_scroll := Vector2(0.14, 0.045)
@export var near_scroll := Vector2(0.26, 0.07)
func _process(_delta: float) -> void:
 var camera := get_viewport().get_camera_2d()
 if not camera: return
 var center := camera.get_screen_center_position()
 _place($Far, center, far_scroll)
 _place($Middle, center, middle_scroll)
 _place($Near, center, near_scroll)
func _place(plane: Node2D, center: Vector2, speed: Vector2) -> void:
 plane.position=Vector2(-fposmod(center.x*speed.x,640.0), -clampf((center.y-400.0)*speed.y,-20.0,30.0))
