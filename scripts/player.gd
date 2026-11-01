extends CharacterBody2D
const PARTICLES=preload("res://scripts/traversal_particles.gd")
var trail_time := 0.0
signal died
@export var fall_limit_y := 720.0
@export var run_speed := 170.0
@export var jump_speed := 310.0
@export var gravity := 900.0
@export var recoil_speed := 390.0
@export var air_acceleration := 1050.0
@export var ground_acceleration := 2200.0
@export var ground_braking := 1900.0
@export var air_drag := 180.0
@export var ice_acceleration := 120.0
@export var ice_braking := 40.0
var on_ice := false
# Forgiveness: pixels a near-miss is nudged so corners don't steal jumps.
@export var corner_correction := 4
@export var ledge_assist := 5
# Death beat: burst, iris closes, respawn, iris opens. Short enough to keep retries snappy.
@export var death_time := 0.26
@export var respawn_reveal_time := 0.22
var dying := 0.0
var iris: CanvasLayer
# Well above shot recoil (390) so a pod pull is clearly the strongest move available.
@export var pull_speed := 700.0
@export var pull_max_time := 0.6
var pull_target := Vector2.ZERO
var pull_time := 0.0
var tether: Line2D
var coyote := 0.0
var jump_buffer := 0.0
var fire_buffer := 0.0
var recoil_lock := 0.0
var invincible := 0.0
var spawn_point := Vector2.ZERO
var facing := 1.0
var animation_time := 0.0
var run_phase := 0.0
var land_pose := 0.0
var blast_boost_time := 0.0
var can_cut_jump := false
var step_distance := 0.0
var visual_scale := Vector2.ONE
@onready var shotgun: Node2D=$Shotgun
func _ready() -> void:
 spawn_point=global_position
 shotgun.fired.connect(_on_fired)
 iris=preload("res://scripts/death_iris.gd").new()
 add_child(iris)
 tether=Line2D.new()
 tether.width=2.0
 tether.default_color=Color("a9e4b5")
 tether.z_index=1
 tether.visible=false
 add_child(tether)
func _input(event: InputEvent) -> void:
 if dying>0: return
 if event.is_action_pressed("jump") and not event.is_echo():
  jump_buffer=0.14
 # Retain a discrete tap through the remaining cooldown; holding never auto-fires.
 # Empty-gun input is discarded so landing cannot trigger an unwanted shot.
 if event.is_action_pressed("fire") and not event.is_echo():
  if shotgun.ammo>0: fire_buffer=shotgun.cooldown+0.05
  else: Sfx.play("empty",-11.0)
func _notification(what: int) -> void:
 if what==NOTIFICATION_PAUSED or what==NOTIFICATION_WM_WINDOW_FOCUS_OUT:
  fire_buffer=0.0
  jump_buffer=0.0
func _physics_process(delta: float) -> void:
 if dying>0:
  dying-=delta
  if dying<=0:
   respawn()
   iris.open_on(self,respawn_reveal_time)
   visual_scale=Vector2(0.55,1.45)
   PARTICLES.burst(self,global_position,Vector2.UP,"spawn")
  return
 invincible=maxf(0,invincible-delta)
 $Sprite2D.modulate.a=0.45 if invincible>0 and int(invincible*15)%2==0 else 1.0
 recoil_lock=maxf(0,recoil_lock-delta)
 blast_boost_time=maxf(0,blast_boost_time-delta)
 visual_scale=visual_scale.lerp(Vector2.ONE,1.0-exp(-16.0*delta))
 $Sprite2D.scale=visual_scale
 var axis := Input.get_axis("left","right")
 if axis: facing=axis
 var was_grounded := is_on_floor()
 coyote=0.12 if is_on_floor() else maxf(0,coyote-delta)
 jump_buffer=maxf(0,jump_buffer-delta)
 var gravity_scale := 1.22 if velocity.y>0 else 1.0
 if can_cut_jump and absf(velocity.y)<55 and Input.is_action_pressed("jump"): gravity_scale=0.65
 velocity.y=minf(velocity.y+gravity*gravity_scale*delta,580)
 # Spore pod pull: fly straight at the pod, then keep that speed through it (slingshot).
 if pull_time>0:
  pull_time-=delta
  var to_target := pull_target-global_position
  if to_target.length()<=pull_speed*delta*1.5 or pull_time<=0:
   _end_pull()
  else:
   velocity=to_target.normalized()*pull_speed
   recoil_lock=maxf(recoil_lock,delta)
 if recoil_lock<=0:
  _steer(axis,delta)
 if jump_buffer>0 and coyote>0:
  velocity.y=-jump_speed
  can_cut_jump=true
  visual_scale=Vector2(0.88,1.12)
  $Camera2D.impact(0.25)
  Sfx.play("jump",-8.0)
  PARTICLES.burst(self,global_position+Vector2(0,10),Vector2.UP,"jump",0.4)
  jump_buffer=0
  coyote=0
 if Input.is_action_just_released("jump") and velocity.y< -120 and can_cut_jump:
  velocity.y=-120
  can_cut_jump=false
 # Resolve neutral aim after jumping, before move_and_slide updates its floor flag.
 var raw := Vector2(Input.get_axis("aim_left","aim_right"),Input.get_axis("aim_up","aim_down"))
 if raw==Vector2.ZERO:
  raw=Vector2(facing,0) if is_on_floor() and velocity.y>=0 else Vector2.DOWN
 shotgun.aim=raw.normalized()
 if fire_buffer>0:
  if shotgun.shoot(): fire_buffer=0.0
  else: fire_buffer=maxf(0.0,fire_buffer-delta)
 # Wind gusts (Echo Orchard) push while they blow; each zone caps the speed it adds.
 for zone in get_tree().get_nodes_in_group("wind_zones"): zone.push_body(self,delta)
 var before_move := position
 var impact_speed := velocity.y
 if not is_on_floor() and pull_time<=0: _assist_near_misses(delta)
 move_and_slide()
 # Only a head-on block ends a pull; the floor you're leaving or a wall you graze doesn't.
 if pull_time>0:
  var heading := (pull_target-global_position).normalized()
  for i in get_slide_collision_count():
   if get_slide_collision(i).get_normal().dot(heading)< -0.6:
    _end_pull()
    break
 # Floors can react to being stood on (crumbling ice) or change footing (slippery ice).
 on_ice=false
 if is_on_floor():
  for i in get_slide_collision_count():
   var hit := get_slide_collision(i)
   if hit.get_normal().y> -0.5: continue
   var floor_body := hit.get_collider()
   if floor_body is Node and floor_body.is_in_group("ice"): on_ice=true
   if floor_body and floor_body.has_method("stepped_on"): floor_body.stepped_on()
 tether.visible=pull_time>0
 if tether.visible: tether.points=PackedVector2Array([Vector2(0,2),to_local(pull_target)])
 if is_on_floor():
  if not was_grounded and impact_speed>90:
   Sfx.play("land",lerpf(-16.0,-5.0,clampf(impact_speed/580.0,0,1)))
   $Camera2D.impact(clampf(impact_speed/360.0,0.3,1.5))
   visual_scale=Vector2(1.15,0.88)
   land_pose=clampf(impact_speed/580.0,0.4,1.0)*0.12
   PARTICLES.burst(self,global_position+Vector2(0,10),Vector2.UP,"land",impact_speed/580.0)
   step_distance=0
  step_distance+=absf(position.x-before_move.x)
  if step_distance>=34 and absf(velocity.x)>35:
   step_distance=0
   Sfx.play("step",-15.0,randf_range(0.9,1.12))
   PARTICLES.burst(self,global_position+Vector2(-facing*4,10),Vector2(-facing,-0.5),"step")
 else: step_distance=0
 # Confirmed landing restores shells immediately, including before a buffered jump.
 # A shot made while already grounded still waits for its recoil recovery.
 if is_on_floor() and (not was_grounded or recoil_lock<=0):
  shotgun.refill()
 trail_time-=delta
 if blast_boost_time>0 and trail_time<=0:
  trail_time=0.07
  PARTICLES.burst(self,global_position,-velocity.normalized(),"boost")
 animation_time+=delta
 land_pose=maxf(0.0,land_pose-delta)
 $Sprite2D.frame=_pose_frame(axis)
 $Sprite2D.flip_h=facing<0
 if global_position.y>fall_limit_y: hurt()
func _on_fired(direction: Vector2) -> void:
 # Firing breaks any pod pull; a pod hit by this same shot starts a new one right after.
 pull_time=0.0
 PARTICLES.burst(self,global_position+Vector2(0,5)+direction*23,direction,"shot")
 var tangent := velocity-direction*velocity.dot(direction)
 # Keep useful lateral motion without weakening an upward boost with downward carry.
 if direction.y>0: tangent.y=minf(tangent.y,0.0)
 velocity=(velocity-direction*recoil_speed*0.7).limit_length(900.0) if blast_boost_time>0 else tangent*0.85-direction*recoil_speed
 can_cut_jump=false
 recoil_lock=0.075
 coyote=0
 visual_scale=Vector2(0.93,1.07)
 $Camera2D.impact(1.4,"shot")
 preload("res://scripts/shell_casing.gd").eject(self,global_position+Vector2(0,4),direction,facing)
# Sheet layout: idle 0-3, run 4-9, rise 10, apex 11, fall 12-13, land 14, skid 15.
func _pose_frame(axis: float) -> int:
 if not is_on_floor():
  if velocity.y< -120: return 10
  if velocity.y<120: return 11
  return 12+int(animation_time*10)%2
 if land_pose>0: return 14
 if axis!=0 and axis*velocity.x<0 and absf(velocity.x)>60: return 15
 if absf(velocity.x)>15:
  # Stride rate follows ground speed so feet don't slide.
  run_phase+=absf(velocity.x)/run_speed*get_physics_process_delta_time()*13.0
  return 4+int(run_phase)%6
 return int(animation_time*5)%4
func _steer(axis: float, delta: float) -> void:
 if is_on_floor():
  # Hard reversal at speed kicks up skid dust from the planted foot.
  if axis!=0 and axis*velocity.x<0 and absf(velocity.x)>110 and trail_time<=0:
   trail_time=0.06
   PARTICLES.burst(self,global_position+Vector2(signf(velocity.x)*4,10),Vector2(signf(velocity.x),-0.6),"step")
  if on_ice:
   # Ice keeps momentum: slow to start, very slow to stop. A shot's kick is the real brake.
   velocity.x=move_toward(velocity.x,axis*run_speed,(ice_braking if axis==0 or axis*velocity.x<0 else ice_acceleration)*delta)
   return
  velocity.x=move_toward(velocity.x,axis*run_speed,(ground_braking if axis==0 else ground_acceleration)*delta)
 elif axis==0:
  velocity.x=move_toward(velocity.x,0,(65.0 if blast_boost_time>0 else air_drag)*delta)
 elif signf(axis)==signf(velocity.x) and absf(velocity.x)>run_speed:
  # Holding the boost direction preserves useful speed instead of snapping to walk speed.
  velocity.x=move_toward(velocity.x,axis*run_speed,90.0*delta)
 else:
  var acceleration := air_acceleration*1.45 if axis*velocity.x<0 else air_acceleration
  velocity.x=move_toward(velocity.x,axis*run_speed,acceleration*delta)
# Shifts the body before move_and_slide only when a few pixels separate a blocked move from a free one.
func _assist_near_misses(delta: float) -> void:
 var step := velocity*delta
 # Rising into a ceiling edge: slide sideways around it, nearest offset first, preferring travel direction.
 if step.y<0 and test_move(global_transform,Vector2(0,step.y)):
  var sides := [1,-1] if velocity.x>=0 else [-1,1]
  for nudge in range(1,corner_correction+1):
   for side in sides:
    var shift := Vector2(side*nudge,0)
    if not test_move(global_transform,shift) and not test_move(global_transform.translated(shift),Vector2(0,step.y)):
     global_position+=shift
     return
 # Pushing into a wall just below its top: lift onto the ledge instead of sliding down its face.
 var push := Input.get_axis("left","right")
 if push!=0 and velocity.y>-60 and signf(velocity.x)!=-signf(push):
  var reach := Vector2(push*maxf(absf(step.x),1.0),0)
  if test_move(global_transform,reach):
   for lift in range(1,ledge_assist+1):
    var up := Vector2(0,-lift)
    if not test_move(global_transform,up) and not test_move(global_transform.translated(up),reach):
     global_position+=up
     velocity.y=minf(velocity.y,0.0)
     return
func apply_blast(direction: Vector2, strength: float) -> void:
 velocity=(velocity+direction.normalized()*strength).limit_length(900.0)
 recoil_lock=0.16
 blast_boost_time=0.65
 can_cut_jump=false
 coyote=0
 visual_scale=Vector2(0.86,1.16)
# Spore pod grapple: pulled toward the pod until arriving, blocked, timing out or firing again.
func pull_to(point: Vector2) -> void:
 pull_target=point
 pull_time=pull_max_time
 can_cut_jump=false
 coyote=0
 visual_scale=Vector2(0.84,1.16)
 $Camera2D.impact(1.2,"mine")
func _end_pull() -> void:
 pull_time=0.0
 # Keep the pull speed with low drag so the pod acts as a slingshot.
 blast_boost_time=0.35
 recoil_lock=0.06
func hurt() -> void:
 if invincible>0 or dying>0: return
 Sfx.play("respawn",-6.0)
 # Level state (mines, pickups, fall count) resets now; the body returns after the death beat.
 died.emit()
 dying=death_time
 velocity=Vector2.ZERO
 fire_buffer=0.0
 jump_buffer=0.0
 _set_body_visible(false)
 PARTICLES.burst(self,global_position,Vector2.UP,"death")
 $Camera2D.impact(2.0)
 iris.close_on(self,death_time)
func _set_body_visible(shown: bool) -> void:
 for part in [$Sprite2D,$Scarf,shotgun]: part.visible=shown
func respawn() -> void:
 # Also completes any death beat in progress, so direct calls (level load, tests) stay instant.
 dying=0.0
 pull_time=0.0
 _set_body_visible(true)
 iris.clear()
 fire_buffer=0.0
 jump_buffer=0.0
 global_position=spawn_point
 velocity=Vector2.ZERO
 recoil_lock=0
 blast_boost_time=0
 can_cut_jump=false
 step_distance=0
 visual_scale=Vector2.ONE
 $Scarf.reset_trail()
 $Camera2D.reset_feedback()
 invincible=1.0
 shotgun.refill()
 # Teleport: don't interpolate a streak from the death spot to the spawn.
 reset_physics_interpolation()
 $Camera2D.reset_smoothing()
