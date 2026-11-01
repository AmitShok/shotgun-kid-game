extends Node
## Cosmetic transforms only: native button focus, navigation, and hit testing stay intact.
var items: Array[Dictionary] = []
var clock := 0.0
var reveal_tween: Tween
func _ready() -> void:
 process_mode=Node.PROCESS_MODE_ALWAYS
 refresh()
func refresh() -> void:
 items.clear()
 _collect(get_parent())
func _collect(node: Node) -> void:
 if node is Window or node.has_meta("static_menu_layout"): return
 if node.name=="Top" or node.name=="Bottom": return
 if (node is Button and not node is CheckButton and not node is OptionButton) or (node is Label and node.name=="Title"):
  var title := node is Label
  var compact := "/Center/Options/" in String(node.get_path())
  # The shell selector points at list-style buttons; the world map draws its own highlights.
  if node is Button and not ("/Center/Levels/" in String(node.get_path()) and node.name!="Back"):
   node.add_to_group("menu_selectable")
  # Buttons sit straight; only page titles keep a slight tilt and sway.
  var tilt := (-0.8 if compact else -2.7) if title else 0.0
  items.append({"node":weakref(node),"tilt":tilt,"title":title,"compact":compact,"phase":items.size()*0.8,"active":false})
 for child in node.get_children(): _collect(child)
func _process(delta: float) -> void:
 clock+=delta
 var weight := 1.0-exp(-14.0*delta)
 for item in items:
  var control=item.node.get_ref()
  if not is_instance_valid(control) or not control.is_visible_in_tree(): continue
  control.pivot_offset=control.size*0.5
  var active: bool=control is Button and not control.disabled and control.is_hovered()
  var pressed: bool=control is Button and control.button_pressed
  var target_scale := 0.985 if pressed else (1.018 if active else 1.0)
  var angle: float=item.tilt
  if item.title: angle+=sin(clock*1.4+item.phase)*0.22
  else:
   angle*=_button_direction(control)
   if active: angle*=0.8
  control.rotation=lerp_angle(control.rotation,deg_to_rad(angle),weight)
  control.scale=control.scale.lerp(Vector2.ONE*target_scale,weight)
  if active and not item.active: Sfx.play("ui",-25,1.15)
  item.active=active

func _button_direction(button: Button) -> float:
 var index := 0
 for sibling in button.get_parent().get_children():
  if sibling==button: break
  if sibling is Button and not sibling is CheckButton and not sibling is OptionButton and sibling.visible:
   index+=1
 return 1.0 if index%2==0 else -1.0

func reveal(panel: Control) -> void:
 if reveal_tween and reveal_tween.is_valid(): reveal_tween.kill()
 # A page switched mid-reveal must not leave its buttons half faded.
 for item in items:
  var control=item.node.get_ref()
  if is_instance_valid(control): control.self_modulate.a=1.0
 for sibling in panel.get_parent().get_children():
  if sibling is Control: sibling.modulate.a=1.0
 # Pages pop in: a quick fade with a slight zoom and settle, scaled about their centre, and their
 # buttons slide in one after another.
 panel.modulate.a=0.0
 panel.pivot_offset=panel.size*0.5
 panel.scale=Vector2.ONE*0.94
 reveal_tween=create_tween().set_parallel()
 reveal_tween.tween_property(panel,"modulate:a",1.0,0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
 reveal_tween.tween_property(panel,"scale",Vector2.ONE,0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
 var order := 0
 for child in panel.get_children():
  if child is Button and child.visible:
   child.self_modulate.a=0.0
   reveal_tween.tween_property(child,"self_modulate:a",1.0,0.2).set_delay(0.06+order*0.05)
   order+=1
