extends CanvasLayer
const LIGHT=preload("res://assets/shaders/crt_light.gdshader")
const HEAVY=preload("res://assets/shaders/crt.gdshader")
func _ready() -> void:
 process_mode=Node.PROCESS_MODE_ALWAYS
 SaveData.preferences_changed.connect(_apply_preference)
 _apply_preference()
func _apply_preference() -> void:
 $Filter.visible=SaveData.crt_mode!=0
 $Filter.material.shader=LIGHT if SaveData.crt_mode==1 else HEAVY
