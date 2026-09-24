extends Camera2D
## Grounded aim look, independent zoom, and separately gated impact sources.
var shake := 0.0
var shot_impact := 0.0
var mine_impact := 0.0
var zoom_kick := 0.0
var elapsed := 0.0
var aim_look := Vector2.ZERO
func _process(delta: float) -> void:
 var player := get_parent() as CharacterBody2D
 elapsed+=delta
 var weight := 1.0-exp(-8.0*delta)
 var look_target := Vector2.ZERO
 if player.is_on_floor():
  var aim_input := Vector2(Input.get_axis("aim_left","aim_right"),Input.get_axis("aim_up","aim_down"))
  look_target=aim_input.normalized()*Vector2(52,64)
 # In the air, return gently to the normal framing; aiming cannot pan the camera.
 aim_look=aim_look.lerp(look_target,1.0-exp(-5.0*delta))
 position.x=lerpf(position.x,clampf(player.velocity.x*0.18,-50,70)+aim_look.x,weight)
 position.y=lerpf(position.y,-48.0+clampf(player.velocity.y*0.035,-25,20)+aim_look.y,weight)
 shake=move_toward(shake,0,16.0*delta)
 shot_impact=move_toward(shot_impact,0,12.0*delta)
 mine_impact=move_toward(mine_impact,0,14.0*delta)
 zoom_kick=lerpf(zoom_kick,0,1.0-exp(-14.0*delta))
 if not SaveData.shot_shake: shot_impact=0.0
 if not SaveData.mine_shake: mine_impact=0.0
 if not SaveData.camera_shake:
  shake=0.0
  shot_impact=0.0
  mine_impact=0.0
 var amplitude := maxf(shake,maxf(shot_impact,mine_impact))
 offset=Vector2(sin(elapsed*103),cos(elapsed*127))*amplitude
 var speed_zoom := clampf((player.velocity.length()-260.0)/14000.0,0,0.035)
 zoom=Vector2.ONE*clampf(1.0-speed_zoom+zoom_kick,0.95,1.04) if SaveData.camera_zoom else Vector2.ONE
func impact(strength: float, pulse: float = 0.0, source: String = "movement") -> void:
 if SaveData.camera_shake:
  var amount := minf(strength,3.0)
  if source=="shot":
   if SaveData.shot_shake: shot_impact=maxf(shot_impact,amount)
  elif source=="mine":
   if SaveData.mine_shake: mine_impact=maxf(mine_impact,amount)
  else: shake=maxf(shake,amount)
 if SaveData.camera_zoom: zoom_kick=clampf(pulse,-0.045,0.035)
func reset_feedback() -> void:
 shake=0.0
 shot_impact=0.0
 mine_impact=0.0
 zoom_kick=0.0
 aim_look=Vector2.ZERO
 offset=Vector2.ZERO
 zoom=Vector2.ONE
 position=Vector2(0,-48)
 reset_smoothing()
