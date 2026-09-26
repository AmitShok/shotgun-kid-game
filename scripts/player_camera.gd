extends Camera2D
## Grounded aim look, landing framing, and separately gated impact shakes.
@export_range(0.4,1.0,0.01) var minimum_landing_zoom := 0.55
@export_range(200.0,2000.0,10.0) var ground_scan_distance := 1000.0
var tracked_ground_y := 0.0
var has_ground_track := false
var ground_loss_time := 0.0
var was_airborne := false
var landing_return_delay := 0.0
var landing_zoom := 1.0
var landing_offset := 0.0
var ground_found := false
var landing_ground := Vector2.ZERO
var target_landing_zoom := 1.0
var target_landing_offset := 0.0
var shake := 0.0
var shot_impact := 0.0
var mine_impact := 0.0
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
 var framing_speed := 6.0 if target_landing_zoom<landing_zoom else 3.0
 landing_zoom=lerpf(landing_zoom,target_landing_zoom,1.0-exp(-framing_speed*delta))
 var offset_weight := 1.0-exp(-(6.0 if target_landing_offset>landing_offset else 4.0)*delta)
 landing_offset=lerpf(landing_offset,target_landing_offset,offset_weight)
 position.y=lerpf(position.y,-48.0+clampf(player.velocity.y*0.035,-25,20)+aim_look.y+landing_offset,weight)
 shake=move_toward(shake,0,16.0*delta)
 shot_impact=move_toward(shot_impact,0,12.0*delta)
 mine_impact=move_toward(mine_impact,0,14.0*delta)
 if not SaveData.shot_shake: shot_impact=0.0
 if not SaveData.mine_shake: mine_impact=0.0
 if not SaveData.camera_shake:
  shake=0.0
  shot_impact=0.0
  mine_impact=0.0
 var amplitude := maxf(shake,maxf(shot_impact,mine_impact))
 offset=Vector2(sin(elapsed*103),cos(elapsed*127))*amplitude
 zoom=Vector2.ONE*landing_zoom
func _physics_process(delta: float) -> void:
 var player := get_parent() as CharacterBody2D
 ground_found=false
 if player.is_on_floor():
  if was_airborne: landing_return_delay=0.10
  was_airborne=false
  has_ground_track=false
  ground_loss_time=0.0
  landing_return_delay=maxf(0,landing_return_delay-delta)
  # A brief settling period prevents touchdown from instantly changing direction.
  if landing_return_delay<=0:
   target_landing_zoom=1.0
   target_landing_offset=0.0
  return
 was_airborne=true
 var space := player.get_world_2d().direct_space_state
 var projected_x := clampf(player.velocity.x*0.3,-140,140)
 # Look below the body and slightly ahead along travel; arrows never steer this scan.
 var offsets := [0.0,projected_x,projected_x-32.0,projected_x+32.0,-48.0,48.0]
 for x in offsets:
  var start := player.global_position+Vector2(x,12)
  var query := PhysicsRayQueryParameters2D.create(start,start+Vector2(0,ground_scan_distance),1)
  var hit := space.intersect_ray(query)
  if not hit.is_empty() and hit.normal.y< -0.5:
   landing_ground=hit.position
   ground_found=true
   break
 if ground_found:
  ground_loss_time=0.0
  if not has_ground_track:
   tracked_ground_y=landing_ground.y
   has_ground_track=true
  else:
   # Blend surface HEIGHT in world space before deriving framing. A higher ledge
   # should not abruptly pull the camera up and zoom in as a ray crosses its edge.
   var higher := landing_ground.y<tracked_ground_y
   var height_weight := 1.0-exp(-(3.5 if higher else 8.0)*delta)
   var blended := lerpf(tracked_ground_y,landing_ground.y,height_weight)
   tracked_ground_y=move_toward(tracked_ground_y,blended,(220.0 if higher else 650.0)*delta)
 else:
  ground_loss_time+=delta
  # Ignore brief missed rays between neighboring ledges; real gaps still release.
  if not has_ground_track or ground_loss_time>0.18:
   has_ground_track=false
   target_landing_zoom=1.0
   target_landing_offset=clampf(player.velocity.y*0.10,0,60)
   return
 var distance := maxf(0,tracked_ground_y-player.global_position.y)
 var viewport_height := get_viewport_rect().size.y
 var usable_height := maxf(100,viewport_height-120.0)
 target_landing_zoom=clampf(usable_height/(distance+36.0),minimum_landing_zoom,1.0)
 var blend := smoothstep(70.0,200.0,distance)
 var center_offset := minf(distance*0.5,(viewport_height*0.5-58.0)/target_landing_zoom)
 # Remove the normal upward bias as distance grows; retain space for HUD and hints.
 var velocity_bias := clampf(player.velocity.y*0.035,-25,20)
 target_landing_offset=(center_offset+48.0-velocity_bias)*blend

func impact(strength: float, source: String = "movement") -> void:
 if SaveData.camera_shake:
  var amount := minf(strength,3.0)
  if source=="shot":
   if SaveData.shot_shake: shot_impact=maxf(shot_impact,amount)
  elif source=="mine":
   if SaveData.mine_shake: mine_impact=maxf(mine_impact,amount)
  else: shake=maxf(shake,amount)
func reset_feedback() -> void:
 tracked_ground_y=0.0
 has_ground_track=false
 ground_loss_time=0.0
 was_airborne=false
 landing_return_delay=0.0
 landing_zoom=1.0
 landing_offset=0.0
 target_landing_zoom=1.0
 target_landing_offset=0.0
 ground_found=false
 shake=0.0
 shot_impact=0.0
 mine_impact=0.0
 aim_look=Vector2.ZERO
 offset=Vector2.ZERO
 zoom=Vector2.ONE
 position=Vector2(0,-48)
 reset_smoothing()
