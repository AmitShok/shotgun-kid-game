extends SceneTree
# Every level and the menu resolve to a looping track; restarts keep the music going; volume persists.
var failures := 0
var checks := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
 checks+=1
 print(("PASS: " if ok else "")+label)
 if not ok:
  failures+=1
  push_error("FAIL: "+label)
func run() -> void:
 var sfx=root.get_node("Sfx")
 var save=root.get_node("SaveData")
 for track in ["menu","lantern_ridge","mossy_comet","copper_cloud","velvet_glacier","echo_orchard"]:
  var stream: AudioStreamWAV=load("res://assets/music/%s.wav" % track)
  check(stream!=null and stream.loop_mode==AudioStreamWAV.LOOP_FORWARD and stream.get_length()>20.0,"Track %s exists and loops" % track)
 for definition in save.CATALOG.levels:
  var level=load(definition.scene_path).instantiate()
  root.add_child(level)
  current_scene=level
  await process_frame
  # Later levels of a world share its track: "mossy_comet_3" plays "mossy_comet".
  var expected: String = "lantern_ridge" if definition.scene_path.get_file()=="training_yard.tscn" else preload("res://scripts/room_map.gd").biome(definition.scene_path.get_file().get_basename())
  check(sfx.music_track==expected,"%s plays %s" % [definition.title,expected])
  level.free()
 var before: int=sfx.event_counts.get("music:echo_orchard",0)
 sfx.play_music("echo_orchard")
 check(sfx.event_counts.get("music:echo_orchard",0)==before,"Reloading the same level does not restart its track")
 save.set_preference("music_volume",0.25)
 var config := ConfigFile.new()
 config.load(save.path)
 check(is_equal_approx(float(config.get_value("audio","music_volume")),0.25),"Music volume is saved")
 print("MUSIC RESULT: %d checks, %d failures" % [checks,failures])
 await sfx.shutdown(1 if failures else 0)
