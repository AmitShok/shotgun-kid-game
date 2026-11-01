extends Control
## A shotgun shell that slides to whichever menu button is hovered or focused, with a glow sweeping
## behind that button. Pressing a button "fires" the shell: a muzzle flash and a quick recoil.
## Cosmetic only; it ignores the mouse and never takes focus.
const SHELL=preload("res://assets/textures/shell.png")
const BLAST=preload("res://assets/textures/blast.png")
var target: Button
var at := Vector2(-40,-40)
var speed := Vector2.ZERO
var band := Rect2()
var clock := 0.0
var flash := 0.0
var recoil := 0.0
var shown := 0.0
func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 set_anchors_preset(Control.PRESET_FULL_RECT)
func _process(delta: float) -> void:
 clock+=delta
 flash=maxf(0.0,flash-delta)
 recoil=maxf(0.0,recoil-delta*5.0)
 var next := _current_button()
 if next!=target:
  target=next
  if target and not target.has_meta("selector_hooked"):
   target.set_meta("selector_hooked",true)
   target.pressed.connect(fire)
 shown=move_toward(shown,1.0 if target else 0.0,delta*6.0)
 if target:
  var rect: Rect2=target.get_global_rect()
  var goal := Vector2(rect.position.x-14,rect.get_center().y)
  if at.x<0: at=goal
  # A springy slide between buttons.
  speed+=(goal-at)*delta*260.0
  speed*=pow(0.0008,delta)
  at+=speed*delta
  var w: float=1.0-exp(-18.0*delta)
  band=Rect2(band.position.lerp(rect.position,w),band.size.lerp(rect.size,w)) if band.size.x>0 else rect
 queue_redraw()
func fire() -> void:
 flash=0.12
 recoil=1.0
 Sfx.play("shot",-26.0,randf_range(1.15,1.3))
func _current_button() -> Button:
 var focus: Control=get_viewport().gui_get_focus_owner()
 # Hovering moves keyboard focus too, so the shell stays on the last hovered button after the
 # mouse leaves it, and arrow keys continue from there.
 for button in get_tree().get_nodes_in_group("menu_selectable"):
  if button is Button and button.is_visible_in_tree() and not button.disabled and button.is_hovered():
   if focus!=button: button.grab_focus()
   return button
 if focus is Button and focus.is_visible_in_tree() and focus.is_in_group("menu_selectable"): return focus
 return null
func _draw() -> void:
 if shown<=0.01 or band.size.x<=0: return
 # Glow band behind the selected button, with a light sweep running across it.
 var inv := get_global_transform().affine_inverse()
 var r := Rect2(inv*band.position,band.size)
 var pulse: float=0.5+0.5*sin(clock*4.0)
 draw_rect(r.grow(3),Color(1,0.72,0.4,(0.10+0.06*pulse)*shown))
 var sweep: float=fmod(clock*0.9,1.4)*(r.size.x+60)-30
 for i in 6:
  var x: float=r.position.x+sweep-i*4
  if x>r.position.x and x<r.end.x: draw_rect(Rect2(x,r.position.y+2,3,r.size.y-4),Color(1,0.95,0.8,(0.10-i*0.015)*shown))
 # The shell itself, bobbing and pointing at the button; it kicks back when fired.
 var p: Vector2=inv*at+Vector2(sin(clock*5.0)*2.0-recoil*8.0,0)
 draw_set_transform(p,PI*0.5,Vector2(1.4,1.4)*shown)
 draw_texture(SHELL,-Vector2(4,6))
 draw_set_transform(Vector2.ZERO)
 if flash>0:
  draw_set_transform(p+Vector2(10,0),0.0,Vector2(0.6,0.6))
  draw_texture(BLAST,Vector2(0,-16),Color(1,1,1,minf(1.0,flash*12.0)))
  draw_set_transform(Vector2.ZERO)
