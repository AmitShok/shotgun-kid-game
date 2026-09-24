extends CanvasLayer
var message := "SPACE jump  /  SHIFT or J fire  /  shoot mines for a blast boost"
var show_input := false
var message_left := 0.0
@onready var player: CharacterBody2D=get_parent().get_node("Player")
func _ready() -> void:
 process_mode=Node.PROCESS_MODE_ALWAYS
 $Overlay/Center/Menu/Resume.pressed.connect(_toggle_pause)
 $Overlay/Center/Menu/Restart.pressed.connect(_restart)
func _process(delta: float) -> void:
 if Input.is_action_just_pressed("pause"): _toggle_pause()
 if Input.is_action_just_pressed("restart"): _restart()
 $Top/Margin/Row/Mode.text="LANTERN RIDGE"
 $Top/Margin/Row/Ammo.text="SHELLS  %d / 2" % player.shotgun.ammo
 $Top/Margin/Row/Shell1.modulate=Color.WHITE if player.shotgun.ammo>0 else Color(0.3,0.35,0.45)
 $Top/Margin/Row/Shell2.modulate=Color.WHITE if player.shotgun.ammo>1 else Color(0.3,0.35,0.45)
 if not get_tree().paused: message_left=maxf(0,message_left-delta)
 var hint := "Jump above a mine. Shoot down. Ride the blast."
 if player.position.x>500: hint="Two shells. Land to reload. Chain your shots to climb."
 if player.position.x>900: hint="THE HIGH ROAD  /  Blast upward to reach the upper ruins."
 if player.position.x>1550: hint="Mines recharge after a blast. Aim diagonally to carry your speed."
 if player.position.x>2250: hint="The mountain gate is just ahead."
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
 if get_parent().complete: return
 get_tree().paused=not get_tree().paused
 $Overlay.visible=get_tree().paused
 if get_tree().paused: $Overlay/Center/Menu/Resume.grab_focus()
func _restart() -> void:
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
