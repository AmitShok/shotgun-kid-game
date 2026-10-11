extends CanvasLayer
const AMMO_FULL = preload("res://assets/textures/ui_ammo_full.png")
const AMMO_EMPTY = preload("res://assets/textures/ui_ammo_empty.png")
var show_input := false
@onready var player: CharacterBody2D=get_parent().get_node("Player")
func _ready() -> void:
	process_mode=Node.PROCESS_MODE_ALWAYS
	$Overlay/Center/Menu/Resume.pressed.connect(_toggle_pause)
	$Overlay/Center/Menu/NextLevel.pressed.connect(_next_level)
	$Overlay/Center/Menu/Restart.text="Restart level  [R]"
	$Overlay/Center/Menu/Restart.pressed.connect(_restart)
	$Overlay/Center/Menu/Wardrobe.pressed.connect(_open_wardrobe)
	$Overlay/Center/Wardrobe.back_requested.connect(_close_wardrobe)
	$Overlay/Center/Menu/Options.pressed.connect(_open_options)
	$Overlay/Center/Menu/Quit.pressed.connect(func(): Sfx.shutdown())
	$Overlay/Center/Menu/MainMenu.pressed.connect(_main_menu)
	$Overlay/Center/Options.back_requested.connect(_close_options)
	SaveData.preferences_changed.connect(_apply_preferences)
	_apply_preferences()
func _apply_preferences() -> void:
	$Top.visible=SaveData.show_hud
func _open_options() -> void:
	Sfx.play("ui",-13)
	$Overlay/Center/Menu.hide()
	$Overlay/Center/Options.show()
	$MenuMotion.reveal($Overlay/Center/Options)
	$Overlay/Center/Options/VolumeRow/Volume.grab_focus()
func _close_options() -> void:
	Sfx.play("ui",-13)
	$Overlay/Center/Options.hide()
	$Overlay/Center/Menu.show()
	$MenuMotion.reveal($Overlay/Center/Menu)
	$Overlay/Center/Menu/Options.grab_focus()
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"): _toggle_pause()
	if Input.is_action_just_pressed("restart") and not $Overlay/Center/Wardrobe.visible: _restart()
	$Top/Margin/Row/Ammo.modulate=Color(1.0,0.76,0.51) if player.shotgun.ammo==0 else Color.WHITE
	$Top/Margin/Row/Ammo.text="SHELLS  %d / 2" % player.shotgun.ammo
	$Top/Margin/Row/Shell1.texture=AMMO_FULL if player.shotgun.ammo>0 else AMMO_EMPTY
	$Top/Margin/Row/Shell2.texture=AMMO_FULL if player.shotgun.ammo>1 else AMMO_EMPTY
	$InputReadout.visible=show_input
	if show_input:
		var states := PackedStringArray()
		for binding in [["SPACE",KEY_SPACE],["W",KEY_W],["CTRL",KEY_CTRL],["LEFT",KEY_LEFT],["RIGHT",KEY_RIGHT],["UP",KEY_UP],["DOWN",KEY_DOWN]]:
			states.append(binding[0]+(":ON" if Input.is_physical_key_pressed(binding[1]) else ":--"))
		$InputReadout/Margin/Keys.text="KEYS RECEIVED [F3]\n"+"  ".join(states)
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F3:
		show_input=not show_input
func _toggle_pause() -> void:
	if $Overlay/Center/Wardrobe.visible:
		_close_wardrobe()
		return
	if $Overlay/Center/Options.visible:
		_close_options()
		return
	if get_parent().complete: return
	Sfx.play("ui",-13.0)
	get_tree().paused=not get_tree().paused
	$Overlay.visible=get_tree().paused
	if get_tree().paused: $Overlay/Center/Menu/Resume.grab_focus()
func _main_menu() -> void:
	get_tree().paused=false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
func _restart() -> void:
	SaveData.clear_progress()
	get_tree().paused=false
	get_tree().reload_current_scene()
func _next_level() -> void:
	var next := SaveData.next_level(get_parent().scene_file_path)
	if next.is_empty(): return
	get_tree().paused=false
	get_tree().change_scene_to_file(next)
func show_completion(seconds: float,deaths: int) -> void:
	get_tree().paused=true
	$Overlay.show()
	$Overlay/Center/Menu/Title.text="LEVEL CLEARED"
	$Overlay/Center/Menu/Description.show()
	$Overlay/Center/Menu/Description.text="%02d:%02d  /  %d falls" % [int(seconds)/60,int(seconds)%60,deaths]
	$Overlay/Center/Menu/Resume.hide()
	var next := SaveData.next_level(get_parent().scene_file_path)
	$Overlay/Center/Menu/NextLevel.visible=not next.is_empty()
	if not next.is_empty(): $Overlay/Center/Menu/NextLevel.grab_focus()
	else: $Overlay/Center/Menu/MainMenu.grab_focus()

func _open_wardrobe() -> void:
	Sfx.play("ui",-13)
	$Overlay/Center/Menu.hide()
	$Overlay/Center/Wardrobe.show()
	$Overlay/Center/Wardrobe.focus_first()
func _close_wardrobe() -> void:
	Sfx.play("ui",-13)
	$Overlay/Center/Wardrobe.hide()
	$Overlay/Center/Menu.show()
	$Overlay/Center/Menu/Wardrobe.grab_focus()
