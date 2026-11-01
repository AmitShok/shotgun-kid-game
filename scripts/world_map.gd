extends VBoxContainer
## Level select: a row of world cards (biome thumbnail, progress, golden shells) above the chosen
## world's five stages on a winding trail. Stages not built yet show as "coming soon" slots.
## Children Title, List, Status and Back come from main_menu.tscn; the rest is built here.
signal world_changed(index: int)
signal start_requested(scene_path: String)
const WORLDS=preload("res://scripts/world_catalog.gd")
const NODE_SIZE := Vector2(40,40)
var selected_world := 0
var cards: Array[Button] = []
var clock := 0.0
var worlds_row: HBoxContainer
var header: Label
var mechanic: Label
var info: Label
@onready var list: Control=$List

func _ready() -> void:
 worlds_row=HBoxContainer.new()
 worlds_row.name="Worlds"
 worlds_row.alignment=BoxContainer.ALIGNMENT_CENTER
 worlds_row.add_theme_constant_override("separation",6)
 worlds_row.set_meta("static_menu_layout",true)
 add_child(worlds_row)
 move_child(worlds_row,1)
 header=_label("Header",20,Color.WHITE)
 move_child(header,2)
 mechanic=_label("Mechanic",10,Color(0.75,0.95,0.9))
 move_child(mechanic,3)
 list.custom_minimum_size=Vector2(560,70)
 list.set_meta("static_menu_layout",true)
 list.draw.connect(_draw_trail)
 info=_label("Info",11,Color(1,0.93,0.8))
 move_child(info,list.get_index()+1)
 for i in WORLDS.WORLDS.size():
  var card := Button.new()
  card.name="World%d" % (i+1)
  card.custom_minimum_size=Vector2(104,62)
  card.focus_mode=Control.FOCUS_ALL
  card.draw.connect(_draw_card.bind(card,i))
  card.pressed.connect(func(): select_world(i,true))
  card.focus_entered.connect(func(): select_world(i,false))
  card.mouse_entered.connect(func(): select_world(i,false))
  worlds_row.add_child(card)
  cards.append(card)

func _label(label_name: String,font_size: int,color: Color) -> Label:
 var label := Label.new()
 label.name=label_name
 label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 label.add_theme_font_size_override("font_size",font_size)
 label.add_theme_color_override("font_color",color)
 label.add_theme_constant_override("outline_size",3)
 label.add_theme_color_override("font_outline_color",Color(0.05,0.08,0.13))
 add_child(label)
 return label

# Levels of one world, keyed by stage (1-5), from the catalog.
func stages(world: int) -> Dictionary:
 var found := {}
 for definition in SaveData.CATALOG.levels:
  if definition.world==world: found[definition.stage]=definition
 return found

func world_unlocked(world: int) -> bool:
 for definition in stages(world).values():
  if SaveData.is_level_unlocked(definition.scene_path): return true
 return false

func world_progress(world: int) -> Vector2i:
 var cleared := 0
 var gold := 0
 for definition in stages(world).values():
  if SaveData.is_level_cleared(definition.scene_path): cleared+=1
  if SaveData.has_golden_shell(definition.scene_path): gold+=1
 return Vector2i(cleared,gold)

# The world holding the first unlocked, uncleared level: where the player left off.
func frontier_world() -> int:
 for definition in SaveData.CATALOG.levels:
  if SaveData.is_level_unlocked(definition.scene_path) and not SaveData.is_level_cleared(definition.scene_path): return definition.world
 return WORLDS.WORLDS.size()-1

func refresh() -> void:
 for card in cards:
  card.queue_redraw()
 select_world(selected_world,false,true)

func select_world(index: int,focus_stage: bool,force := false) -> void:
 if index==selected_world and not force:
  if focus_stage: focus_best_stage()
  return
 if index!=selected_world: Sfx.play("ui",-20,1.1)
 selected_world=index
 var entry: Dictionary=WORLDS.WORLDS[index]
 header.text="WORLD %d  ·  %s" % [index+1,entry.title]
 header.add_theme_color_override("font_color",entry.color)
 mechanic.text="NEW: %s  —  %s" % [entry.mechanic,entry.intro]
 _build_stages()
 for card in cards: card.queue_redraw()
 world_changed.emit(index)
 if focus_stage: focus_best_stage()

func _build_stages() -> void:
 for child in list.get_children(): child.free()
 var found := stages(selected_world)
 var entry: Dictionary=WORLDS.WORLDS[selected_world]
 for stage in range(1,WORLDS.STAGES+1):
  var node := Button.new()
  node.name="Stage%d" % stage
  node.custom_minimum_size=NODE_SIZE
  node.size=NODE_SIZE
  node.position=_stage_point(stage)-NODE_SIZE*0.5
  node.pivot_offset=NODE_SIZE*0.5
  node.text=str(stage)
  var definition: Resource=found.get(stage)
  if definition==null:
   node.disabled=true
   node.text="?"
   node.tooltip_text="Coming soon"
   node.set_meta("info","%d-%d  ·  COMING SOON" % [selected_world+1,stage])
  else:
   var scene: String=definition.scene_path
   var unlocked := SaveData.is_level_unlocked(scene)
   node.disabled=not unlocked
   node.set_meta("scene",scene)
   node.set_meta("info",_stage_info(definition,stage))
   node.pressed.connect(func(): start_requested.emit(scene))
  node.focus_entered.connect(func(): info.text=node.get_meta("info"))
  node.mouse_entered.connect(func(): info.text=node.get_meta("info"))
  node.add_theme_color_override("font_color",entry.color)
  list.add_child(node)
 _link_focus()
 info.text=_first_info()
 list.queue_redraw()

func _stage_info(definition: Resource,stage: int) -> String:
 var scene: String=definition.scene_path
 var text := "%d-%d  ·  %s" % [selected_world+1,stage,definition.title]
 if not SaveData.is_level_unlocked(scene): return text+"  ·  LOCKED"
 if SaveData.is_level_cleared(scene): text+="  ·  CLEARED"
 elif SaveData.level_path==scene and not SaveData.checkpoint.is_empty(): text+="  ·  CONTINUE"
 else: text+="  ·  READY"
 var best := SaveData.best_record(scene)
 if not best.is_empty(): text+="  ·  "+SaveData.format_time(best.time)
 if SaveData.has_golden_shell(scene): text+="  ·  GOLD"
 return text

func _first_info() -> String:
 for node in list.get_children():
  if not node.disabled: return node.get_meta("info")
 return "Clear the world before this one to open it." if not world_unlocked(selected_world) else ""

func _link_focus() -> void:
 for card in cards:
  card.focus_neighbor_bottom=card.get_path_to(list.get_child(0))
 for node in list.get_children():
  node.focus_neighbor_top=node.get_path_to(cards[selected_world])

func focus_best_stage() -> void:
 # Prefer the next stage to play; otherwise the last open one; otherwise the world card.
 var best: Button=null
 for node in list.get_children():
  if node.disabled: continue
  best=node
  if node.has_meta("scene") and not SaveData.is_level_cleared(node.get_meta("scene")): break
 if best: best.grab_focus()
 else: cards[selected_world].grab_focus()

func _stage_point(stage: int) -> Vector2:
 var t := float(stage-1)/(WORLDS.STAGES-1)
 return Vector2(lerpf(48,list.custom_minimum_size.x-48,t),35+sin(t*PI*2.0)*14.0)

func _process(delta: float) -> void:
 clock+=delta
 if not is_visible_in_tree(): return
 list.queue_redraw()
 for i in cards.size():
  var card: Button=cards[i]
  card.pivot_offset=card.size*0.5
  var lifted: bool=i==selected_world
  var target := 1.06 if lifted else (1.02 if card.is_hovered() else 1.0)
  card.scale=card.scale.lerp(Vector2.ONE*(target+(sin(clock*2.4)*0.012 if lifted else 0.0)),1.0-exp(-12.0*delta))
  card.queue_redraw()
 for node in list.get_children():
  var ready: bool=not node.disabled and node.has_meta("scene") and not SaveData.is_level_cleared(node.get_meta("scene"))
  var pulse := 1.0+(0.08*sin(clock*5.0) if ready else 0.0)+(0.06 if node.has_focus() or node.is_hovered() else 0.0)
  node.scale=node.scale.lerp(Vector2.ONE*pulse,1.0-exp(-14.0*delta))

func _draw_card(card: Button,index: int) -> void:
 var entry: Dictionary=WORLDS.WORLDS[index]
 var area := Rect2(Vector2(4,4),card.size-Vector2(8,22))
 var sky: Texture2D=WORLDS.texture(entry.sky)
 if sky: card.draw_texture_rect_region(sky,area,Rect2(Vector2.ZERO,sky.get_size()))
 var near: Texture2D=WORLDS.texture(entry.layers[-1])
 if near:
  # A slowly panning slice of the nearest layer, cropped to the card.
  var region_w: float=near.get_width()*area.size.x/640.0*2.0
  var region_x: float=fposmod(clock*10.0+index*90.0,maxf(1.0,near.get_width()-region_w))
  var region_h: float=minf(near.get_height(),region_w*area.size.y/area.size.x)
  card.draw_texture_rect_region(near,area,Rect2(region_x,near.get_height()-region_h,region_w,region_h))
 var unlocked := world_unlocked(index)
 if not unlocked: card.draw_rect(area,Color(0.02,0.03,0.06,0.62))
 var selected: bool=index==selected_world
 card.draw_rect(area,Color(entry.color,0.9 if selected else 0.35),false,2.0 if selected else 1.0)
 var font: Font=card.get_theme_font("font")
 var progress := world_progress(index)
 var line := "%d  %s" % [index+1,entry.title]
 card.draw_string(font,Vector2(6,card.size.y-9),line,HORIZONTAL_ALIGNMENT_LEFT,card.size.x-12,8,entry.color if unlocked else Color(0.55,0.58,0.62))
 var badge := "LOCKED" if not unlocked else "%d/%d" % [progress.x,WORLDS.STAGES]
 card.draw_string(font,Vector2(area.position.x+3,area.position.y+10),badge,HORIZONTAL_ALIGNMENT_LEFT,-1,8,Color(1,1,1,0.95))
 if progress.y>0:
  var bob := sin(clock*3.0+index)*1.5
  var at := Vector2(area.end.x-14,area.position.y+8+bob)
  card.draw_circle(at,3.5,Color(1,0.82,0.3))
  card.draw_string(font,at+Vector2(5,3),str(progress.y),HORIZONTAL_ALIGNMENT_LEFT,-1,8,Color(1,0.9,0.5))

func _draw_trail() -> void:
 var entry: Dictionary=WORLDS.WORLDS[selected_world]
 var found := stages(selected_world)
 for stage in range(1,WORLDS.STAGES):
  var a := _stage_point(stage)
  var b := _stage_point(stage+1)
  var definition: Resource=found.get(stage)
  var walked: bool=definition!=null and SaveData.is_level_cleared(definition.scene_path)
  # Marching dashes along each leg; legs you've walked glow in the world's colour.
  var steps := 14
  for i in steps:
   var t0 := (float(i)+fposmod(clock*1.6,1.0))/steps
   if t0>1.0: continue
   var t1 := minf(1.0,t0+0.4/steps)
   var bend := Vector2(0,-10)
   var p0 := a.lerp(b,t0)+bend*sin(t0*PI)
   var p1 := a.lerp(b,t1)+bend*sin(t1*PI)
   list.draw_line(p0,p1,Color(entry.color,0.9) if walked else Color(1,1,1,0.28),2.0)
 for stage in range(1,WORLDS.STAGES+1):
  var definition: Resource=found.get(stage)
  if definition and SaveData.has_golden_shell(definition.scene_path):
   var at := _stage_point(stage)+Vector2(0,-28+sin(clock*3.0+stage)*2.0)
   list.draw_circle(at,4.0,Color(1,0.82,0.3))
   list.draw_circle(at,6.5,Color(1,0.82,0.3,0.25+0.15*sin(clock*4.0)))
