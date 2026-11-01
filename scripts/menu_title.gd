extends Label
## The title logo: letters drawn one by one with a slow wave, a warm gradient, a chunky outline and a
## light sweep. kick() makes the letters flinch outward, like the screen shaking from a shot.
var clock := 0.0
var shake := 0.0
var intro := 0.0
func _ready() -> void:
 # The Label keeps its size and text for layout and accessibility; we draw the letters ourselves.
 add_theme_color_override("font_color",Color(0,0,0,0))
 add_theme_color_override("font_outline_color",Color(0,0,0,0))
 add_theme_color_override("font_shadow_color",Color(0,0,0,0))
func kick(strength: float = 1.0) -> void:
 shake=maxf(shake,strength)
func _process(delta: float) -> void:
 clock+=delta
 intro=minf(1.0,intro+delta*1.6)
 shake=maxf(0.0,shake-delta*4.0)
 queue_redraw()
func _draw() -> void:
 var font: Font=get_theme_font("font")
 var font_size: int=get_theme_font_size("font_size")
 var total: float=font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x
 var x: float=0.0
 if horizontal_alignment==HORIZONTAL_ALIGNMENT_CENTER: x=(size.x-total)*0.5
 var base: float=size.y*0.5+font.get_ascent(font_size)*0.5-4
 var sweep: float=fmod(clock*0.45,1.6)*(total+80)-40
 for i in text.length():
  var ch := text[i]
  var w: float=font.get_string_size(ch,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x
  # Letters drop in one after another, then ride a gentle wave.
  var arrive: float=clampf(intro*1.8-i*0.06,0.0,1.0)
  var drop: float=(1.0-ease(arrive,0.3))*-40.0
  var wave: float=sin(clock*2.4-i*0.55)*2.5
  var jolt := Vector2(randf_range(-1,1),randf_range(-1,1))*shake*3.0
  var at := Vector2(x,base+wave+drop)+jolt
  var tilt: float=sin(clock*1.7-i*0.8)*0.04+shake*randf_range(-0.08,0.08)
  var t: float=float(i)/maxf(1.0,text.length()-1)
  var top := Color(1.0,0.86,0.6).lerp(Color(1.0,0.72,0.42),t)
  # Brighten letters as the light sweep passes over them.
  var shine: float=clampf(1.0-absf(x+w*0.5-sweep)/40.0,0.0,1.0)
  var fill: Color=top.lerp(Color(1,1,0.92),shine*0.8)
  fill.a=arrive
  draw_set_transform(at+Vector2(w*0.5,0),tilt,Vector2.ONE)
  var origin := Vector2(-w*0.5,0)
  draw_string(font,origin+Vector2(3,5),ch,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,Color(0.02,0.03,0.07,0.6*arrive))
  draw_string_outline(font,origin,ch,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,8,Color(0.05,0.07,0.13,arrive))
  draw_string_outline(font,origin+Vector2(0,2),ch,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,4,Color(0.55,0.22,0.16,arrive))
  draw_string(font,origin,ch,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,fill)
  draw_set_transform(Vector2.ZERO)
  x+=w
