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
# Two music players crossfade between original looping tracks in assets/music/.
const MUSIC_GAIN := -11.0
var music_players: Array[AudioStreamPlayer] = []
var music_track := ""
var music_fade: Tween
func _ready() -> void:
 process_mode=Node.PROCESS_MODE_ALWAYS
 for i in 2:
  var player := AudioStreamPlayer.new()
  player.volume_db=-80.0
  add_child(player)
  music_players.append(player)
 SaveData.preferences_changed.connect(_apply_music_volume)
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
func music_db() -> float:
 return MUSIC_GAIN+linear_to_db(maxf(SaveData.music_volume,0.001))
func play_music(track: String, fade: float = 0.8) -> void:
 if shutting_down or track==music_track: return
 var path := "res://assets/music/%s.wav" % track
 if not ResourceLoader.exists(path): return
 music_track=track
 var outgoing := music_players[0]
 var incoming := music_players[1]
 music_players.reverse()
 incoming.stream=load(path)
 incoming.volume_db=-40.0
 if DisplayServer.get_name()!="headless": incoming.play()
 if music_fade: music_fade.kill()
 music_fade=create_tween().set_parallel()
 music_fade.tween_property(incoming,"volume_db",music_db(),fade)
 music_fade.tween_property(outgoing,"volume_db",-60.0,fade)
 music_fade.chain().tween_callback(outgoing.stop)
 event_counts["music:"+track]=int(event_counts.get("music:"+track,0))+1
func _apply_music_volume() -> void:
 if music_track.is_empty(): return
 if music_fade and music_fade.is_running(): return
 music_players[0].volume_db=music_db()
func set_volume(value: float) -> void:
 volume=clampf(value,0,1)
 _apply_volume()
 _save()
func set_camera_fx(value: bool) -> void:
 camera_fx=value
 SaveData.camera_shake=value
 _save()
func _apply_volume() -> void:
 AudioServer.set_bus_volume_db(0,linear_to_db(maxf(volume,0.001)))
 AudioServer.set_bus_mute(0,volume<=0.001)
func _save() -> void:
 SaveData.volume=volume
 SaveData.camera_fx=camera_fx
 SaveData.save()
func stop_all() -> void:
 for voice in voices+music_players:
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
