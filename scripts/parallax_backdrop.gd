extends CanvasLayer
func _process(_delta: float) -> void:
 var camera := get_viewport().get_camera_2d()
 if not camera: return
 var center := camera.get_screen_center_position()
 $Far.position=Vector2(-fposmod(center.x*0.08,640.0),-clampf((center.y-400.0)*0.035,-14,14))
 $Near.position=Vector2(-fposmod(center.x*0.19,640.0),-clampf((center.y-400.0)*0.065,-25,25))
