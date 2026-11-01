extends Control
const WORLDS=preload("res://scripts/world_catalog.gd")
var levels: Array[Resource] = []
var page := "Home"
var clock := 0.0
# On the title screen the backdrop tours the unlocked worlds.
var tour_time := 0.0
var tour_world := 0
@onready var world_map: VBoxContainer=$Center/Levels
func _ready() -> void:
 get_tree().paused=false
 Sfx.play_music("menu")
 $Center/Home/Start.pressed.connect(func(): _show_page("Levels"))
 $Center/Home/Wardrobe.pressed.connect(func(): _show_page("Wardrobe"))
 $Center/Wardrobe.back_requested.connect(func(): _show_page("Home"))
 $Center/Home/Options.pressed.connect(func(): _show_page("Options"))
 $Center/Home/Quit.pressed.connect(func(): Sfx.shutdown())
 $Center/Levels/Back.pressed.connect(func(): _show_page("Home"))
 $Center/Options.back_requested.connect(func(): _show_page("Home"))
 world_map.world_changed.connect(func(index): $Backdrop.set_world(index); $Mascot.set_world(index))
 # The title flinches a little every time the kid on the title screen fires.
 $Mascot.fired.connect(func(_direction): $Center/Home/Title.kick(0.5))
 world_map.start_requested.connect(_start_level)
 levels=SaveData.CATALOG.levels
 SaveData.progress_changed.connect(_refresh_levels)
 world_map.selected_world=world_map.frontier_world()
 tour_world=world_map.selected_world
 $Backdrop.world=tour_world
 $Mascot.set_world(tour_world)
 _refresh_levels()
 _refresh_start_label()
 $Center/Home/Start.grab_focus()
func _refresh_levels() -> void:
 world_map.refresh()
 var progress := Vector2i.ZERO
 for i in WORLDS.WORLDS.size(): progress+=world_map.world_progress(i)
 $Center/Levels/Status.text="%d / %d levels cleared   ·   %d golden shells" % [progress.x,WORLDS.WORLDS.size()*WORLDS.STAGES,progress.y]
 var frontier: int=world_map.frontier_world()
 $Center/Home/Footer.text="WORLD %d  ·  %s   |   %d / %d cleared   |   %d golden shells" % [frontier+1,WORLDS.WORLDS[frontier].title,progress.x,WORLDS.WORLDS.size()*WORLDS.STAGES,progress.y]
 _refresh_start_label()
 $MenuMotion.refresh()
func _process(delta: float) -> void:
 clock+=delta
 # The icon floats and the tagline breathes; small, constant life on the title screen.
 var icon: Control=$Center/Home/GameIcon
 icon.pivot_offset=icon.size*0.5
 icon.rotation=sin(clock*1.3)*0.08
 icon.scale=Vector2.ONE*(1.0+sin(clock*2.1)*0.04)
 $Center/Home/Tagline.modulate.a=0.75+0.25*sin(clock*1.7)
 if page=="Home":
  tour_time+=delta
  if tour_time>6.0:
   tour_time=0.0
   var open: Array = []
   for i in WORLDS.WORLDS.size():
    if world_map.world_unlocked(i): open.append(i)
   if open.size()>1:
    tour_world=open[(open.find(tour_world)+1)%open.size()]
    $Backdrop.set_world(tour_world)
    $Mascot.set_world(tour_world)
func _unhandled_input(event: InputEvent) -> void:
 if event.is_action_pressed("pause") and page!="Home":
  _show_page("Home")
  get_viewport().set_input_as_handled()
func _show_page(next_page: String) -> void:
 Sfx.play("ui",-13)
 page=next_page
 for panel in $Center.get_children(): panel.visible=panel.name==page
 $Mascot.visible=page=="Home"
 $MenuMotion.reveal(get_node("Center/"+page))
 if page=="Wardrobe": $Center/Wardrobe.focus_first()
 elif page=="Options": $Center/Options.focus_first()
 elif page=="Levels":
  $Backdrop.set_world(world_map.selected_world)
  $Mascot.set_world(world_map.selected_world)
  world_map.focus_best_stage()
 else:
  tour_time=0.0
  _refresh_start_label()
  $Center/Home/Start.grab_focus()
func _start_level(scene_path: String) -> void:
 if not SaveData.is_level_unlocked(scene_path): return
 Sfx.play("ui",-13)
 var error := get_tree().change_scene_to_file(scene_path)
 if error!=OK:
  $Center/Levels/Status.text="This level could not be opened."
## Continue once the player has entered a level (or cleared one); Play on a fresh or reset save.
func _refresh_start_label() -> void:
 $Center/Home/Start.text="Continue" if SaveData.has_progress() else "Play"
