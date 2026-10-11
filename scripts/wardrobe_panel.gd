extends PanelContainer
signal back_requested
const CATALOG=preload("res://scripts/wardrobe_catalog.gd")
const PLAYER=preload("res://scenes/actors/player.tscn")
var category="hats"
var cards: Array[Button]=[]
var tabs: Dictionary={}
var grid: GridContainer
var preview: CharacterBody2D
var pose=0
var facing=1.0
var clock=0.0
var pose_button: Button
var back_button: Button
func label(text: String,size_px: int) -> Label:
 var node=Label.new();node.text=text;node.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 node.add_theme_font_size_override("font_size",size_px);node.mouse_filter=Control.MOUSE_FILTER_IGNORE
 return node
func button(text: String,parent: Node,callback: Callable) -> Button:
 var node=Button.new();node.text=text;node.custom_minimum_size.y=26;node.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 node.add_theme_font_size_override("font_size",12);parent.add_child(node);node.pressed.connect(callback)
 return node
func _ready() -> void:
 process_mode=Node.PROCESS_MODE_ALWAYS
 set_meta("static_menu_layout",true)
 var style=StyleBoxTexture.new();style.texture=preload("res://assets/textures/ui_hud_panel.png")
 style.texture_margin_left=5;style.texture_margin_right=5;style.texture_margin_top=5;style.texture_margin_bottom=5
 add_theme_stylebox_override("panel",style)
 var margin=MarginContainer.new()
 for side in ["left","right","top","bottom"]: margin.add_theme_constant_override("margin_"+side,12)
 add_child(margin)
 var column=VBoxContainer.new();column.add_theme_constant_override("separation",8);margin.add_child(column)
 column.add_child(label("WARDROBE",24))
 var body=HBoxContainer.new();body.add_theme_constant_override("separation",16);column.add_child(body)
 var left=VBoxContainer.new();left.add_theme_constant_override("separation",4);body.add_child(left)
 var view=SubViewportContainer.new();view.custom_minimum_size=Vector2(192,192);view.stretch=true;view.stretch_shrink=3
 view.mouse_filter=Control.MOUSE_FILTER_IGNORE;left.add_child(view)
 var viewport=SubViewport.new();viewport.size=Vector2i(64,64);viewport.world_2d=World2D.new()
 viewport.render_target_update_mode=SubViewport.UPDATE_WHEN_VISIBLE;view.add_child(viewport)
 var stage=Sprite2D.new();stage.texture=preload("res://assets/textures/wardrobe_stage.png");stage.centered=false;viewport.add_child(stage)
 preview=PLAYER.instantiate();preview.name="PreviewPlayer";preview.remove_from_group("player")
 preview.set_physics_process(false);preview.set_process_input(false);preview.get_node("Camera2D").enabled=false
 preview.get_node("Shotgun").hide();preview.position=Vector2(34,35);viewport.add_child(preview)
 preview.set_physics_process(false);preview.set_process_input(false)
 preview.get_node("Camera2D").process_mode=Node.PROCESS_MODE_DISABLED
 var poses=HBoxContainer.new();left.add_child(poses)
 pose_button=button("Idle",poses,func(): pose=(pose+1)%3;pose_button.text=["Idle","Run","Air"][pose])
 button("Turn",poses,func(): facing=-facing)
 var right=VBoxContainer.new();right.size_flags_horizontal=Control.SIZE_EXPAND_FILL;right.add_theme_constant_override("separation",6);body.add_child(right)
 var categories=HBoxContainer.new();right.add_child(categories)
 for key in ["hats","scarves","outfits"]:
  var tab=button(key.capitalize(),categories,func(): _select_category(key))
  tab.toggle_mode=true;tabs[key]=tab
 grid=GridContainer.new();grid.columns=4;grid.custom_minimum_size=Vector2(332,188)
 grid.add_theme_constant_override("h_separation",4);grid.add_theme_constant_override("v_separation",4);right.add_child(grid)
 var footer=HBoxContainer.new();footer.add_theme_constant_override("separation",12);column.add_child(footer)
 button("Randomize",footer,_randomize)
 button("Reset look",footer,func(): SaveData.set_appearance(CATALOG.DEFAULTS);Sfx.play("ui",-13))
 back_button=button("Done",footer,func(): back_requested.emit())
 SaveData.appearance_changed.connect(_sync)
 _select_category("hats",false)
func _select_category(next: String,sound: bool=true) -> void:
 category=next
 for child in grid.get_children(): child.free()
 cards.clear()
 for entry in CATALOG.entries(category):
  var card=Button.new();card.custom_minimum_size=Vector2(80,44);card.toggle_mode=true;card.tooltip_text=entry.name
  card.set_meta("item_id",entry.id);grid.add_child(card);cards.append(card)
  var content=VBoxContainer.new();content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
  content.add_theme_constant_override("separation",0);content.mouse_filter=Control.MOUSE_FILTER_IGNORE;card.add_child(content)
  var icon=TextureRect.new();icon.custom_minimum_size=Vector2(0,28);icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
  icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;icon.mouse_filter=Control.MOUSE_FILTER_IGNORE
  icon.texture=CATALOG.tail(entry.id) if category=="scarves" else CATALOG.texture(category,entry.id,true)
  content.add_child(icon);content.add_child(label(entry.name,8))
  var check=TextureRect.new();check.name="Equipped";check.texture=preload("res://assets/textures/wardrobe_check.png")
  check.position=Vector2(70,3);check.mouse_filter=Control.MOUSE_FILTER_IGNORE;card.add_child(check)
  card.pressed.connect(func(): SaveData.equip(category,entry.id);_sync();Sfx.play("ui",-13))
 _sync()
 if sound: Sfx.play("ui",-13)
func _sync() -> void:
 for key in tabs: tabs[key].set_pressed_no_signal(key==category)
 for card in cards:
  var selected=card.get_meta("item_id")==SaveData.appearance[category]
  card.set_pressed_no_signal(selected);card.get_node("Equipped").visible=selected
func _randomize() -> void:
 var selection={}
 for key in CATALOG.DEFAULTS: selection[key]=CATALOG.entries(key).pick_random().id
 SaveData.set_appearance(selection);Sfx.play("ui",-13)
func focus_first() -> void:
 tabs[category].grab_focus()
func _process(delta: float) -> void:
 if not is_visible_in_tree() or not is_instance_valid(preview): return
 clock+=delta
 preview.facing=facing
 preview.velocity=Vector2(facing*110,0) if pose==1 else Vector2(facing*80,-100) if pose==2 else Vector2.ZERO
 preview.position=Vector2(34+sin(clock*2)*2 if pose==1 else 34,32+sin(clock*3)*2 if pose==2 else 35)
 var sprite=preview.get_node("Sprite2D")
 sprite.frame=2+int(clock*10)%4 if pose==1 else 6 if pose==2 else int(clock*2)%2
 sprite.flip_h=facing<0
 preview.get_node("Appearance")._process(0)
