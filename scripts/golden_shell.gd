extends Area2D
## Optional per-level collectible. Once grabbed it trails the player; it is banked at the next
## checkpoint or the exit, and flies home if the player dies first.
enum State {WAITING,FOLLOWING,RETURNING,BANKED}
const PARTICLES=preload("res://scripts/traversal_particles.gd")
var state := State.WAITING
var home := Vector2.ZERO
var follower: Node2D
var time := 0.0
const BANK_GROUND_TIME := 0.3
var grounded := 0.0
func _ready() -> void:
 add_to_group("golden_shells")
 home=global_position
 body_entered.connect(_on_body_entered)
 # Already banked on an earlier run: shown as a faint ghost that can still be chased for fun.
 if SaveData.has_golden_shell(_scene()): $Visual.modulate=Color(1,1,1,0.4)
func _scene() -> String:
 var scene := get_tree().current_scene
 return scene.scene_file_path if scene else ""
func _physics_process(delta: float) -> void:
 time+=delta
 $Visual.position.y=sin(time*2.0)*3.0
 $Visual/Glow.modulate.a=0.5+sin(time*4.0)*0.12
 match state:
  State.FOLLOWING:
   var target: Vector2=follower.global_position+Vector2(-follower.facing*16.0,-20.0)
   global_position=global_position.lerp(target,1.0-exp(-7.0*delta))
   # Standing safely on solid ground for a moment banks it, as well as checkpoints and the exit.
   grounded=grounded+delta if follower.is_on_floor() and follower.dying<=0 else 0.0
   if grounded>=BANK_GROUND_TIME: bank()
  State.RETURNING:
   global_position=global_position.move_toward(home,520.0*delta)
   if global_position.distance_to(home)<1.0:
    global_position=home
    state=State.WAITING
func _on_body_entered(body: Node2D) -> void:
 if state!=State.WAITING or not body.is_in_group("player"): return
 follower=body
 state=State.FOLLOWING
 grounded=0.0
 Sfx.play("reload",-4.0,1.5)
 PARTICLES.burst(self,global_position,Vector2.UP,"gold")
## Called by checkpoints and the exit.
func bank() -> void:
 if state!=State.FOLLOWING: return
 state=State.BANKED
 SaveData.bank_golden_shell(_scene())
 Sfx.play("checkpoint",-3.0,1.35)
 PARTICLES.burst(self,global_position,Vector2.UP,"gold",1.0)
 PARTICLES.burst(self,global_position,Vector2.DOWN,"gold",1.0)
 var pop := create_tween()
 pop.tween_property($Visual,"scale",Vector2(1.8,1.8),0.12)
 pop.tween_property($Visual,"scale",Vector2.ZERO,0.18)
 pop.tween_callback(hide)
## Called when the player dies.
func drop() -> void:
 if state==State.FOLLOWING: state=State.RETURNING
