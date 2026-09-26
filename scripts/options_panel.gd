extends VBoxContainer
signal back_requested
const TOGGLES = [["CameraShake","camera_shake"],["ShotShake","shot_shake"],["MineShake","mine_shake"],["Controls","show_controls"],["LevelHints","show_level_hints"],["HUD","show_hud"]]
func _ready() -> void:
 $ResetProgress.pressed.connect(func(): $ResetConfirmation.popup_centered())
 $ResetConfirmation.confirmed.connect(_reset_progress)
 for label in ["Off","Light","Heavy"]: $CRT/Preset.add_item(label)
 $CRT/Preset.item_selected.connect(func(index: int): SaveData.set_preference("crt_mode",index))
 $Back.pressed.connect(func(): back_requested.emit())
 $VolumeRow/Volume.value_changed.connect(func(value: float): Sfx.set_volume(value/100.0))
 for pair in TOGGLES:
  var toggle: CheckButton=get_node(pair[0])
  toggle.toggled.connect(func(value: bool): SaveData.set_preference(pair[1],value))
 SaveData.preferences_changed.connect(_sync)
 visibility_changed.connect(_sync)
 _sync()
func _sync() -> void:
 if not is_node_ready(): return
 $VolumeRow/Volume.set_value_no_signal(Sfx.volume*100)
 $CRT/Preset.select(SaveData.crt_mode)
 for pair in TOGGLES:
  get_node(pair[0]).set_pressed_no_signal(SaveData.get(pair[1]))
func focus_first() -> void:
 $VolumeRow/Volume.grab_focus()

func _reset_progress() -> void:
 SaveData.reset_progress()
 var scene := get_tree().current_scene
 # Leave an active level so a tester cannot immediately re-unlock it from its exit.
 if scene and scene.has_node("Player"):
  get_tree().paused=false
  get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
