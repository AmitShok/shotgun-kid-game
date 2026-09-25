extends Node2D
@export var level_title := "LANTERN RIDGE"
@export var fall_limit_y := 720.0
@export var camera_bounds := Rect2(0,-160,2560,840)
var deaths := 0
var elapsed := 0.0
var complete := false
func _ready() -> void:
 var camera: Camera2D=$Player/Camera2D
 camera.limit_left=int(camera_bounds.position.x)
 camera.limit_top=int(camera_bounds.position.y)
 camera.limit_right=int(camera_bounds.end.x)
 camera.limit_bottom=int(camera_bounds.end.y)
 $Player.fall_limit_y=fall_limit_y
 $Player.died.connect(_on_player_died)
 if SaveData.level_path==scene_file_path:
  # Resolve only known flags; never trust an arbitrary node path or coordinates from disk.
  for flag in get_children():
   if flag.get_script()==preload("res://scripts/checkpoint.gd") and String(flag.name)==SaveData.checkpoint:
    $Player.spawn_point=flag.global_position+Vector2(0,-14)
    $Player.respawn()
    flag.activated=true
    flag.get_node("Sprite2D").modulate=Color("ffda92")
    break
func _on_player_died() -> void:
 deaths+=1
 for mine in get_tree().get_nodes_in_group("boost_mines"): mine.reset()
func _process(delta: float) -> void:
 if not complete and not get_tree().paused: elapsed+=delta
func checkpoint_reached() -> void:
 Sfx.play("checkpoint",-7.0)
 $HUD.show_message("CHECKPOINT SAVED  /  take another run whenever you need")
func finish() -> void:
 if complete: return
 complete=true
 SaveData.complete_level(scene_file_path)
 Sfx.play("clear",-5.0)
 $HUD.show_completion(elapsed,deaths)
