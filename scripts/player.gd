extends CharacterBody2D
signal died
@export var run_speed := 150.0
@export var jump_speed := 285.0
@export var gravity := 850.0
@export var recoil_speed := 390.0
@export var air_acceleration := 500.0
var coyote := 0.0
var jump_buffer := 0.0
var fire_buffer := 0.0
var recoil_lock := 0.0
var invincible := 0.0
var spawn_point := Vector2.ZERO
var facing := 1.0
var animation_time := 0.0
var blast_boost_time := 0.0
var shake_time := 0.0
var can_cut_jump := false
@onready var shotgun: Node2D=$Shotgun
func _ready() -> void:
 spawn_point=global_position
 shotgun.fired.connect(_on_fired)
func _input(event: InputEvent) -> void:
 if event.is_action_pressed("jump") and not event.is_echo():
  jump_buffer=0.12
 # Retain a discrete tap through the remaining cooldown; holding never auto-fires.
 # Empty-gun input is discarded so landing cannot trigger an unwanted shot.
 if event.is_action_pressed("fire") and not event.is_echo() and shotgun.ammo>0:
  fire_buffer=shotgun.cooldown+0.05
func _notification(what: int) -> void:
 if what==NOTIFICATION_PAUSED or what==NOTIFICATION_WM_WINDOW_FOCUS_OUT:
  fire_buffer=0.0
  jump_buffer=0.0
func _physics_process(delta: float) -> void:
 invincible=maxf(0,invincible-delta)
 $Sprite2D.modulate.a=0.45 if invincible>0 and int(invincible*15)%2==0 else 1.0
 recoil_lock=maxf(0,recoil_lock-delta)
 blast_boost_time=maxf(0,blast_boost_time-delta)
 shake_time=maxf(0,shake_time-delta)
 $Camera2D.offset=Vector2(sin(animation_time*117),cos(animation_time*93))*shake_time*8.0
 var axis := Input.get_axis("left","right")
 if axis: facing=axis
 var was_grounded := is_on_floor()
 coyote=0.1 if is_on_floor() else maxf(0,coyote-delta)
 jump_buffer=maxf(0,jump_buffer-delta)
 velocity.y=minf(velocity.y+gravity*delta,550)
 if recoil_lock<=0:
  velocity.x=move_toward(velocity.x,axis*run_speed,(1800.0 if is_on_floor() else air_acceleration)*delta)
 if jump_buffer>0 and coyote>0:
  velocity.y=-jump_speed
  can_cut_jump=true
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
 move_and_slide()
 # Confirmed landing restores shells immediately, including before a buffered jump.
 # A shot made while already grounded still waits for its recoil recovery.
 if is_on_floor() and (not was_grounded or recoil_lock<=0):
  shotgun.refill()
 animation_time+=delta
 $Sprite2D.frame=(6 if velocity.y<0 else 7) if not is_on_floor() else (2+int(animation_time*12)%4 if absf(velocity.x)>15 else int(animation_time*2)%2)
 $Sprite2D.flip_h=facing<0
 if global_position.y>720: hurt()
func _on_fired(direction: Vector2) -> void:
 velocity=(velocity-direction*recoil_speed*0.7).limit_length(900.0) if blast_boost_time>0 else -direction*recoil_speed
 can_cut_jump=false
 recoil_lock=0.16
 coyote=0
func apply_blast(direction: Vector2, strength: float) -> void:
 velocity=(velocity+direction.normalized()*strength).limit_length(900.0)
 recoil_lock=0.3
 blast_boost_time=0.65
 can_cut_jump=false
 coyote=0
 shake_time=0.22
func hurt() -> void:
 if invincible>0: return
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
 shake_time=0
 invincible=1.0
 shotgun.refill()
 $Camera2D.reset_smoothing()
