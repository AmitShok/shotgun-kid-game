extends Node
## Preferences and checkpoint progress are written immediately, independently of quitting.
signal appearance_changed
const WARDROBE = preload("res://scripts/wardrobe_catalog.gd")
var appearance: Dictionary = WARDROBE.DEFAULTS.duplicate()
signal preferences_changed
signal progress_changed
const CATALOG=preload("res://data/level_catalog.tres")
# Cleared levels by scene path. A level unlocks once the level before it in the catalog is
# cleared, so new levels can be inserted into a world without disturbing earlier progress.
var completed: Array[String] = []
var completed_count: int:
 get: return completed.size()
# Campaign order before worlds existed: an old "completed_count" save means the first N of these.
const LEGACY_ORDER := ["res://scenes/levels/training_yard.tscn","res://scenes/levels/mossy_comet.tscn","res://scenes/levels/copper_cloud.tscn","res://scenes/levels/velvet_glacier.tscn","res://scenes/levels/echo_orchard.tscn"]
var path := "user://settings.cfg"
var volume := 0.55
var music_volume := 0.6 # Relative to the master volume above.
var camera_fx := true # Legacy preference used only for migration.
var camera_shake := true
var crt_mode := 2 # 0 Off, 1 Light, 2 Heavy.
# Compatibility for existing saves and code that only enables/disables CRT.
var crt_filter: bool:
 get: return crt_mode!=0
 set(value): crt_mode=2 if value else 0
var shot_shake := true
var mine_shake := true
var show_controls := true
var show_level_hints := true
var show_hud := true
var checkpoint := ""
var level_path := ""
var checkpoint_position := Vector2.ZERO
# Replay goals, keyed by level scene path: banked golden shells and best {time, falls}.
var golden_shells: Array[String] = []
var records := {}

func _ready() -> void:
 process_mode=Node.PROCESS_MODE_ALWAYS
 # Dedicated profiles let automated tests exercise persistence without touching a player's save.
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--save-file="): path=arg.trim_prefix("--save-file=")
 var config := ConfigFile.new()
 if config.load(path)!=OK: return
 for category in WARDROBE.DEFAULTS:
  var selection=config.get_value("wardrobe",category,WARDROBE.DEFAULTS[category])
  if WARDROBE.valid(category,selection): appearance[category]=selection
 var saved_volume: Variant=config.get_value("audio","volume",0.55)
 if (saved_volume is float or saved_volume is int) and is_finite(float(saved_volume)):
  volume=clampf(float(saved_volume),0,1)
 var saved_music: Variant=config.get_value("audio","music_volume",0.6)
 if (saved_music is float or saved_music is int) and is_finite(float(saved_music)):
  music_volume=clampf(float(saved_music),0,1)
 camera_fx=_read_bool(config,"camera_fx")
 for key in ["camera_shake","shot_shake","mine_shake"]:
  var value: Variant=config.get_value("accessibility",key,camera_fx)
  set(key,value if value is bool else camera_fx)
 crt_filter=_read_bool(config,"crt_filter")
 var saved_crt_mode: Variant=config.get_value("accessibility","crt_mode",crt_mode)
 if saved_crt_mode is int: crt_mode=clampi(saved_crt_mode,0,2)
 show_controls=_read_bool(config,"show_controls")
 show_level_hints=_read_bool(config,"show_level_hints")
 show_hud=_read_bool(config,"show_hud")
 var saved_completed: Variant=config.get_value("progress","completed",[]) if config.has_section_key("progress","completed") else null
 if saved_completed is Array:
  for scene in saved_completed:
   if scene is String and level_index(scene)>=0 and not scene in completed: completed.append(scene)
 else:
  var legacy: Variant=config.get_value("progress","completed_count",0)
  if legacy is int:
   for i in clampi(legacy,0,LEGACY_ORDER.size()): completed.append(LEGACY_ORDER[i])
 var saved_checkpoint: Variant=config.get_value("progress","checkpoint","")
 var saved_level: Variant=config.get_value("progress","level","")
 var saved_position: Variant=config.get_value("progress","position",Vector2.ZERO)
 if saved_checkpoint is String and saved_level is String and saved_position is Vector2:
  checkpoint=saved_checkpoint
  level_path=saved_level
  checkpoint_position=saved_position
 # Keep only entries for levels that still exist, with well-formed values.
 var saved_shells: Variant=config.get_value("records","golden_shells",[])
 if saved_shells is Array:
  for scene in saved_shells:
   if scene is String and level_index(scene)>=0 and not scene in golden_shells: golden_shells.append(scene)
 var saved_records: Variant=config.get_value("records","best",{})
 if saved_records is Dictionary:
  for scene in saved_records:
   var entry: Variant=saved_records[scene]
   if scene is String and level_index(scene)>=0 and entry is Dictionary and (entry.get("time") is float or entry.get("time") is int) and entry.get("falls") is int:
    records[scene]={"time":maxf(0.0,float(entry.time)),"falls":maxi(0,entry.falls)}

func _read_bool(config: ConfigFile,key: String) -> bool:
 var value: Variant=config.get_value("accessibility",key,true)
 return value if value is bool else true

func set_preference(key: String,value: Variant) -> void:
 if not key in ["volume","music_volume","camera_fx","camera_shake","crt_filter","crt_mode","shot_shake","mine_shake","show_controls","show_level_hints","show_hud"]: return
 if key=="crt_mode": value=clampi(int(value),0,2)
 if key=="music_volume": value=clampf(float(value),0,1)
 set(key,value)
 save()
 preferences_changed.emit()

func save_checkpoint(flag: Node2D,position: Vector2) -> void:
 checkpoint=String(flag.name)
 level_path=get_tree().current_scene.scene_file_path
 checkpoint_position=position
 save()

func clear_progress() -> void:
 checkpoint=""
 level_path=""
 checkpoint_position=Vector2.ZERO
 save()

func save() -> void:
 var config := ConfigFile.new()
 config.set_value("audio","volume",volume)
 config.set_value("audio","music_volume",music_volume)
 for category in appearance: config.set_value("wardrobe",category,appearance[category])
 for key in ["camera_fx","camera_shake","crt_filter","crt_mode","shot_shake","mine_shake","show_controls","show_level_hints","show_hud"]:
  config.set_value("accessibility",key,get(key))
 config.set_value("progress","completed",completed)
 config.set_value("progress","checkpoint",checkpoint)
 config.set_value("progress","level",level_path)
 config.set_value("progress","position",checkpoint_position)
 config.set_value("records","golden_shells",golden_shells)
 config.set_value("records","best",records)
 # Replace only after the complete new file has been written successfully.
 var error := config.save(path+".tmp")
 if error==OK:
  error=DirAccess.rename_absolute(ProjectSettings.globalize_path(path+".tmp"),ProjectSettings.globalize_path(path))
 if error!=OK: push_warning("Could not save settings and checkpoint: "+error_string(error))

func level_index(scene: String) -> int:
 for i in CATALOG.levels.size():
  if CATALOG.levels[i].scene_path==scene: return i
 return -1
func is_level_unlocked(scene: String) -> bool:
 var index := level_index(scene)
 if index<0: return false
 return index==0 or scene in completed or CATALOG.levels[index-1].scene_path in completed
func is_level_cleared(scene: String) -> bool:
 return scene in completed
func complete_level(scene: String) -> void:
 # Replaying a finished level never skips a future level. F6 can preview locked levels,
 # but cannot award out-of-order campaign progress.
 if not is_level_unlocked(scene) or scene in completed: return
 completed.append(scene)
 save()
 progress_changed.emit()
func next_level(scene: String) -> String:
 var index := level_index(scene)+1
 if index<=0 or index>=CATALOG.levels.size(): return ""
 var next: String=CATALOG.levels[index].scene_path
 return next if is_level_unlocked(next) else ""
func reset_progress() -> void:
 completed.clear()
 golden_shells.clear()
 records.clear()
 clear_progress()
 progress_changed.emit()

func has_golden_shell(scene: String) -> bool:
 return scene in golden_shells
func bank_golden_shell(scene: String) -> void:
 if level_index(scene)<0 or has_golden_shell(scene): return
 golden_shells.append(scene)
 save()
 progress_changed.emit()
func best_record(scene: String) -> Dictionary:
 return records.get(scene,{})
# Returns which stats improved, so the completion screen can celebrate them.
func record_run(scene: String,seconds: float,falls: int) -> Dictionary:
 if level_index(scene)<0: return {}
 var previous: Dictionary=records.get(scene,{})
 var result := {"time":previous.is_empty() or seconds<float(previous.time),"falls":previous.is_empty() or falls<int(previous.falls),"first":previous.is_empty()}
 records[scene]={"time":minf(seconds,float(previous.get("time",INF))),"falls":mini(falls,int(previous.get("falls",falls)))}
 save()
 progress_changed.emit()
 return result
static func format_time(seconds: float) -> String:
 return "%02d:%05.2f" % [int(seconds)/60,fmod(seconds,60.0)]

func equip(category: String,id: String) -> void:
 if not WARDROBE.valid(category,id) or appearance.get(category)==id: return
 appearance[category]=id
 save()
 appearance_changed.emit()

func set_appearance(selection: Dictionary) -> void:
 for category in WARDROBE.DEFAULTS:
  if WARDROBE.valid(category,selection.get(category)): appearance[category]=selection[category]
 save()
 appearance_changed.emit()
