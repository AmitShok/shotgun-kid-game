extends CanvasLayer
var message := "SPACE jump  /  SHIFT or J fire  /  shoot mines for a blast boost"
var show_input := false
var message_left := 0.0
@onready var player: CharacterBody2D=get_parent().get_node("Player")
func _ready() -> void:
 process_mode=Node.PROCESS_MODE_ALWAYS
 $Overlay/Center/Menu/Resume.pressed.connect(_toggle_pause)
 $Overlay/Center/Menu/Restart.pressed.connect(_restart)
 $Overlay/Center/Menu/Options.pressed.connect(_open_options)
 $Overlay/Center/Menu/Quit.pressed.connect(func(): Sfx.shutdown())
 $Overlay/Center/Options/Back.pressed.connect(_close_options)
 $Overlay/Center/Options/VolumeRow/Volume.set_value_no_signal(Sfx.volume*100)
 $Overlay/Center/Options/VolumeRow/Volume.value_changed.connect(func(value: float): Sfx.set_volume(value/100.0))
 for pair in [["CameraShake","camera_shake"],["CameraZoom","camera_zoom"],["ShotShake","shot_shake"],["MineShake","mine_shake"],["Controls","show_controls"],["LevelHints","show_level_hints"],["HUD","show_hud"]]:
  var toggle: CheckButton=get_node("Overlay/Center/Options/"+pair[0])
  toggle.set_pressed_no_signal(SaveData.get(pair[1]))
  toggle.toggled.connect(func(value: bool): SaveData.set_preference(pair[1],value))
 SaveData.preferences_changed.connect(_apply_preferences)
 _apply_preferences()
func _apply_preferences() -> void:
 $Bottom.visible=SaveData.show_controls
 $Top.visible=SaveData.show_hud
 get_parent().get_node("Signs").visible=SaveData.show_level_hints
func _open_options() -> void:
 Sfx.play("ui",-13)
 $Overlay/Center/Menu.hide()
 $Overlay/Center/Options.show()
 $Overlay/Center/Options/VolumeRow/Volume.grab_focus()
func _close_options() -> void:
 Sfx.play("ui",-13)
 $Overlay/Center/Options.hide()
 $Overlay/Center/Menu.show()
 $Overlay/Center/Menu/Options.grab_focus()
func _process(delta: float) -> void:
 if Input.is_action_just_pressed("pause"): _toggle_pause()
 if Input.is_action_just_pressed("restart"): _restart()
 $Top/Margin/Row/Mode.text="LANTERN RIDGE"
 $Top/Margin/Row/Ammo.text="SHELLS  %d / 2" % player.shotgun.ammo
 $Top/Margin/Row/Shell1.modulate=Color.WHITE if player.shotgun.ammo>0 else Color(0.3,0.35,0.45)
 $Top/Margin/Row/Shell2.modulate=Color.WHITE if player.shotgun.ammo>1 else Color(0.3,0.35,0.45)
 if not get_tree().paused: message_left=maxf(0,message_left-delta)
 var hint := "Controls:"
 if player.position.x>500: hint="Controls:"
 if player.position.x>900: hint="Controls:"
 if player.position.x>1550: hint="Controls:"
 if player.position.x>2250: hint="Controls:"
 $Bottom/Margin/Column/Hint.text=message if message_left>0 else hint
 $Bottom/Margin/Column/Controls.text="A/D move  /  SPACE jump  /  ARROWS aim  /  SHIFT fire  /  ESC pause"
 $InputReadout.visible=show_input
 if show_input:
  var states := PackedStringArray()
  for binding in [["SPACE",KEY_SPACE],["W",KEY_W],["CTRL",KEY_CTRL],["LEFT",KEY_LEFT],["RIGHT",KEY_RIGHT],["UP",KEY_UP],["DOWN",KEY_DOWN]]:
   states.append(binding[0]+(":ON" if Input.is_physical_key_pressed(binding[1]) else ":--"))
  $InputReadout/Margin/Keys.text="KEYS RECEIVED [F3]\n"+"  ".join(states)
func _input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F3:
  show_input=not show_input
func show_message(text: String) -> void:
 message=text
 message_left=3.0
func _toggle_pause() -> void:
 if $Overlay/Center/Options.visible:
  _close_options()
  return
 if get_parent().complete: return
 Sfx.play("ui",-13.0)
 get_tree().paused=not get_tree().paused
 $Overlay.visible=get_tree().paused
 if get_tree().paused: $Overlay/Center/Menu/Resume.grab_focus()
func _restart() -> void:
 SaveData.clear_progress()
 get_tree().paused=false
 get_tree().reload_current_scene()
func show_completion(seconds: float,deaths: int) -> void:
 get_tree().paused=true
 $Overlay.show()
 $Overlay/Center/Menu/Title.text="RIDGE CLEARED"
 $Overlay/Center/Menu/Description.text="%02d:%02d  /  %d falls
Two shells. A long way up." % [int(seconds)/60,int(seconds)%60,deaths]
 $Overlay/Center/Menu/Resume.hide()
 $Overlay/Center/Menu/Restart.grab_focus()
