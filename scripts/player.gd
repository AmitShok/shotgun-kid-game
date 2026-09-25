extends CharacterBody2D
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
var coyote := 0.0
var jump_buffer := 0.0
var fire_buffer := 0.0
var recoil_lock := 0.0
var invincible := 0.0
var spawn_point := Vector2.ZERO
var facing := 1.0
var animation_time := 0.0
var blast_boost_time := 0.0
var can_cut_jump := false
var step_distance := 0.0
var visual_scale := Vector2.ONE
@onready var shotgun: Node2D=$Shotgun
func _ready() -> void:
 spawn_point=global_position
 shotgun.fired.connect(_on_fired)
func _input(event: InputEvent) -> void:
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
 if recoil_lock<=0:
  _steer(axis,delta)
 if jump_buffer>0 and coyote>0:
  velocity.y=-jump_speed
  can_cut_jump=true
  visual_scale=Vector2(0.88,1.12)
  $Camera2D.impact(0.25,0.012)
  Sfx.play("jump",-8.0)
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
 var before_move := position
 var impact_speed := velocity.y
 move_and_slide()
 if is_on_floor():
  if not was_grounded and impact_speed>90:
   Sfx.play("land",lerpf(-16.0,-5.0,clampf(impact_speed/580.0,0,1)))
   $Camera2D.impact(clampf(impact_speed/360.0,0.3,1.5),0.013)
   visual_scale=Vector2(1.15,0.88)
   step_distance=0
  step_distance+=absf(position.x-before_move.x)
  if step_distance>=34 and absf(velocity.x)>35:
   step_distance=0
   Sfx.play("step",-15.0,randf_range(0.9,1.12))
 else: step_distance=0
 # Confirmed landing restores shells immediately, including before a buffered jump.
 # A shot made while already grounded still waits for its recoil recovery.
 if is_on_floor() and (not was_grounded or recoil_lock<=0):
  shotgun.refill()
 animation_time+=delta
 $Sprite2D.frame=(6 if velocity.y<0 else 7) if not is_on_floor() else (2+int(animation_time*12)%4 if absf(velocity.x)>15 else int(animation_time*2)%2)
 $Sprite2D.flip_h=facing<0
 if global_position.y>fall_limit_y: hurt()
func _on_fired(direction: Vector2) -> void:
 var tangent := velocity-direction*velocity.dot(direction)
 # Keep useful lateral motion without weakening an upward boost with downward carry.
 if direction.y>0: tangent.y=minf(tangent.y,0.0)
 velocity=(velocity-direction*recoil_speed*0.7).limit_length(900.0) if blast_boost_time>0 else tangent*0.85-direction*recoil_speed
 can_cut_jump=false
 recoil_lock=0.075
 coyote=0
 visual_scale=Vector2(0.93,1.07)
 $Camera2D.impact(1.4,0.025,"shot")
func _steer(axis: float, delta: float) -> void:
 if is_on_floor():
  velocity.x=move_toward(velocity.x,axis*run_speed,(ground_braking if axis==0 else ground_acceleration)*delta)
 elif axis==0:
  velocity.x=move_toward(velocity.x,0,(65.0 if blast_boost_time>0 else air_drag)*delta)
 elif signf(axis)==signf(velocity.x) and absf(velocity.x)>run_speed:
  # Holding the boost direction preserves useful speed instead of snapping to walk speed.
  velocity.x=move_toward(velocity.x,axis*run_speed,90.0*delta)
 else:
  var acceleration := air_acceleration*1.45 if axis*velocity.x<0 else air_acceleration
  velocity.x=move_toward(velocity.x,axis*run_speed,acceleration*delta)
func apply_blast(direction: Vector2, strength: float) -> void:
 velocity=(velocity+direction.normalized()*strength).limit_length(900.0)
 recoil_lock=0.16
 blast_boost_time=0.65
 can_cut_jump=false
 coyote=0
 visual_scale=Vector2(0.86,1.16)
func hurt() -> void:
 if invincible>0: return
 Sfx.play("respawn",-6.0)
 died.emit()
 respawn()
func respawn() -> void:
 fire_buffer=0.0
 jump_buffer=0.0
 global_position=spawn_point
 velocity=Vector2.ZERO
 recoil_lock=0
 blast_boost_time=0
 can_cut_jump=false
 step_distance=0
 visual_scale=Vector2.ONE
 $Camera2D.reset_feedback()
 invincible=1.0
 shotgun.refill()
 $Camera2D.reset_smoothing()
