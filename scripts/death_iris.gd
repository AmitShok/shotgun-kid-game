extends CanvasLayer
## Iris wipe that closes on the death spot and reopens on the respawn point. Cosmetic only.
const SHADER=preload("res://assets/shaders/iris.gdshader")
const OPEN_RADIUS := 1.3
var rect := ColorRect.new()
var tween: Tween
func _ready() -> void:
 layer=90
 rect.set_anchors_preset(Control.PRESET_FULL_RECT)
 rect.mouse_filter=Control.MOUSE_FILTER_IGNORE
 rect.material=ShaderMaterial.new()
 rect.material.shader=SHADER
 rect.hide()
 add_child(rect)
func close_on(target: Node2D, duration: float) -> void:
 _run(target,OPEN_RADIUS,0.0,duration,Tween.EASE_IN)
func open_on(target: Node2D, duration: float) -> void:
 _run(target,0.0,OPEN_RADIUS,duration,Tween.EASE_OUT)
func clear() -> void:
 if tween: tween.kill()
 rect.hide()
func _run(target: Node2D, from: float, to: float, duration: float, easing: Tween.EaseType) -> void:
 if tween: tween.kill()
 var size := rect.get_viewport_rect().size
 var material: ShaderMaterial=rect.material
 material.set_shader_parameter("aspect",size.x/maxf(size.y,1.0))
 material.set_shader_parameter("center",target.get_global_transform_with_canvas().origin/size)
 material.set_shader_parameter("radius",from)
 rect.show()
 tween=create_tween().set_trans(Tween.TRANS_QUAD).set_ease(easing)
 tween.tween_method(func(r: float): material.set_shader_parameter("radius",r),from,to,duration)
 if to>=OPEN_RADIUS: tween.tween_callback(rect.hide)
