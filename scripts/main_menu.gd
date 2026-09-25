extends Control
var levels: Array[Resource] = []
var page := "Home"
func _ready() -> void:
 get_tree().paused=false
 $Center/Home/Start.pressed.connect(func(): _show_page("Levels"))
 $Center/Home/Options.pressed.connect(func(): _show_page("Options"))
 $Center/Home/Quit.pressed.connect(func(): Sfx.shutdown())
 $Center/Levels/Back.pressed.connect(func(): _show_page("Home"))
 $Center/Options.back_requested.connect(func(): _show_page("Home"))
 levels=SaveData.CATALOG.levels
 SaveData.progress_changed.connect(_refresh_levels)
 _refresh_levels()
 $Center/Home/Start.grab_focus()
func _refresh_levels() -> void:
 for child in $Center/Levels/List.get_children(): child.free()
 for i in levels.size():
  var definition=levels[i]
  var unlocked := SaveData.is_level_unlocked(definition.scene_path)
  var button := Button.new()
  var status := "CLEARED" if i<SaveData.completed_count else ("READY" if unlocked else "LOCKED")
  if unlocked and SaveData.level_path==definition.scene_path and not SaveData.checkpoint.is_empty(): status="CONTINUE"
  button.text=definition.title+"  /  "+status
  button.custom_minimum_size.y=32
  button.disabled=not unlocked
  button.tooltip_text="Finish "+levels[i-1].title+" to unlock." if not unlocked else definition.description
  button.pressed.connect(func(): _start_level(definition.scene_path))
  $Center/Levels/List.add_child(button)
 $Center/Levels/Status.text="Reach each exit to unlock the next level."
 $MenuMotion.refresh()
func _unhandled_input(event: InputEvent) -> void:
 if event.is_action_pressed("pause") and page!="Home":
  _show_page("Home")
  get_viewport().set_input_as_handled()
func _show_page(next_page: String) -> void:
 Sfx.play("ui",-13)
 page=next_page
 for panel in $Center.get_children(): panel.visible=panel.name==page
 $MenuMotion.reveal(get_node("Center/"+page))
 if page=="Options": $Center/Options.focus_first()
 elif page=="Levels":
  if $Center/Levels/List.get_child_count()>0: $Center/Levels/List.get_child(0).grab_focus()
  else: $Center/Levels/Back.grab_focus()
 else: $Center/Home/Start.grab_focus()
func _start_level(scene_path: String) -> void:
 if not SaveData.is_level_unlocked(scene_path): return
 Sfx.play("ui",-13)
 var error := get_tree().change_scene_to_file(scene_path)
 if error!=OK:
  $Center/Levels/Status.text="This level could not be opened."
