extends CanvasLayer
func _ready() -> void:
 process_mode=Node.PROCESS_MODE_ALWAYS
 SaveData.preferences_changed.connect(_apply_preference)
 _apply_preference()
func _apply_preference() -> void:
 $Filter.visible=SaveData.crt_filter
