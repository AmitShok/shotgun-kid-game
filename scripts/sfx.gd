extends Node
## Original one-shot SFX, bounded voice pool, distance falloff, persistent preferences.
signal played(sound: String)
var volume := 0.55
var camera_fx := true
var event_counts := {}
var voices: Array[AudioStreamPlayer] = []
var sounds := {}
var cursor := 0
var last_play := {}
var shutting_down := false
func _ready() -> void:
 process_mode=Node.PROCESS_MODE_ALWAYS
 for sound in ["step","jump","shot","empty","reload","mine_blast","land","mine_ready","checkpoint","clear","respawn","ui"]:
  sounds[sound]=load("res://assets/audio/"+sound+".wav")
 for i in range(14):
  var voice := AudioStreamPlayer.new()
  add_child(voice)
  voices.append(voice)
 volume=SaveData.volume
 camera_fx=SaveData.camera_fx
 _apply_volume()
 get_tree().set_auto_accept_quit(false)
 get_tree().root.close_requested.connect(shutdown)
func play(sound: String, gain: float = 0.0, pitch: float = 1.0) -> void:
 if shutting_down or not sounds.has(sound): return
 var now := Time.get_ticks_msec()
 if now-int(last_play.get(sound,-1000))<35: return
 last_play[sound]=now
 var voice := voices[cursor]
 cursor=(cursor+1)%voices.size()
 voice.stop()
 voice.stream=sounds[sound]
 voice.volume_db=gain-5.0
 voice.pitch_scale=pitch
 # Headless tests verify dispatch; actual playback is tested in the rendered build.
 if DisplayServer.get_name()!="headless": voice.play()
 event_counts[sound]=int(event_counts.get(sound,0))+1
 played.emit(sound)
func play_at(sound: String, position: Vector2, gain: float = 0.0) -> void:
 var player := get_tree().get_first_node_in_group("player")
 var distance: float=player.global_position.distance_to(position) if player else 0.0
 if distance>550: return
 play(sound,gain-clampf(distance/20,0,22))
func set_volume(value: float) -> void:
 volume=clampf(value,0,1)
 _apply_volume()
 _save()
func set_camera_fx(value: bool) -> void:
 camera_fx=value
 SaveData.camera_shake=value
 SaveData.camera_zoom=value
 _save()
func _apply_volume() -> void:
 AudioServer.set_bus_volume_db(0,linear_to_db(maxf(volume,0.001)))
 AudioServer.set_bus_mute(0,volume<=0.001)
func _save() -> void:
 SaveData.volume=volume
 SaveData.camera_fx=camera_fx
 SaveData.save()
func stop_all() -> void:
 for voice in voices:
  if is_instance_valid(voice):
   voice.stop()
   voice.stream=null
func _exit_tree() -> void:
 stop_all()
 sounds.clear()
func shutdown(exit_code: int = 0) -> void:
 if shutting_down: return
 SaveData.save()
 shutting_down=true
 get_tree().paused=true
 stop_all()
 # Let the audio mixer retire playback handles before the scene tree is destroyed.
 await get_tree().create_timer(0.08,true).timeout
 get_tree().quit(exit_code)
