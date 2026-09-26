extends Node
## Preferences and checkpoint progress are written immediately, independently of quitting.
signal preferences_changed
signal progress_changed
const CATALOG=preload("res://data/level_catalog.tres")
var completed_count := 0
var path := "user://settings.cfg"
var volume := 0.55
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

func _ready() -> void:
 process_mode=Node.PROCESS_MODE_ALWAYS
 # Dedicated profiles let automated tests exercise persistence without touching a player's save.
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--save-file="): path=arg.trim_prefix("--save-file=")
 var config := ConfigFile.new()
 if config.load(path)!=OK: return
 var saved_volume: Variant=config.get_value("audio","volume",0.55)
 if (saved_volume is float or saved_volume is int) and is_finite(float(saved_volume)):
  volume=clampf(float(saved_volume),0,1)
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
 var saved_completed: Variant=config.get_value("progress","completed_count",0)
 if saved_completed is int: completed_count=clampi(saved_completed,0,CATALOG.levels.size())
 var saved_checkpoint: Variant=config.get_value("progress","checkpoint","")
 var saved_level: Variant=config.get_value("progress","level","")
 var saved_position: Variant=config.get_value("progress","position",Vector2.ZERO)
 if saved_checkpoint is String and saved_level is String and saved_position is Vector2:
  checkpoint=saved_checkpoint
  level_path=saved_level
  checkpoint_position=saved_position

func _read_bool(config: ConfigFile,key: String) -> bool:
 var value: Variant=config.get_value("accessibility",key,true)
 return value if value is bool else true

func set_preference(key: String,value: Variant) -> void:
 if not key in ["volume","camera_fx","camera_shake","crt_filter","crt_mode","shot_shake","mine_shake","show_controls","show_level_hints","show_hud"]: return
 if key=="crt_mode": value=clampi(int(value),0,2)
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
 for key in ["camera_fx","camera_shake","crt_filter","crt_mode","shot_shake","mine_shake","show_controls","show_level_hints","show_hud"]:
  config.set_value("accessibility",key,get(key))
 config.set_value("progress","completed_count",completed_count)
 config.set_value("progress","checkpoint",checkpoint)
 config.set_value("progress","level",level_path)
 config.set_value("progress","position",checkpoint_position)
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
 return index>=0 and index<=completed_count
func complete_level(scene: String) -> void:
 var index := level_index(scene)
 # Replaying a finished level never skips a future level. F6 can preview locked levels,
 # but cannot award out-of-order campaign progress.
 if index<0 or index!=completed_count: return
 completed_count=mini(completed_count+1,CATALOG.levels.size())
 save()
 progress_changed.emit()
func next_level(scene: String) -> String:
 var index := level_index(scene)+1
 if index<=0 or index>=CATALOG.levels.size(): return ""
 var next: String=CATALOG.levels[index].scene_path
 return next if is_level_unlocked(next) else ""
func reset_progress() -> void:
 completed_count=0
 clear_progress()
 progress_changed.emit()
