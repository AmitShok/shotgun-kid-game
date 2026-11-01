extends StaticBody2D
## Crumbling ice (Velvet Glacier): a ledge that holds for a moment once stood on, shakes, then
## shatters. It regrows after a few seconds (never on top of the player), and every crumble
## resets on death and on entering a room. Landing on it still refills shells, so a chain of
## crumbles is a chain of refills you have to keep moving through.
const TEXTURE=preload("res://assets/textures/crumble_ice.png")
const PARTICLES=preload("res://scripts/traversal_particles.gd")
const TILE := 16
@export var tiles := 1
@export var rows := 1
@export var hold_time := 0.4
@export var regrow_time := 2.4
enum State {SOLID, SHAKING, GONE}
var state := State.SOLID
var timer := 0.0
var time := 0.0
var shape: CollisionShape2D
# Cleared by the route tests' skip search to prove a room needs its crumbles.
var available := true:
 set(value):
  available=value
  if shape: shape.set_deferred("disabled",not value or state==State.GONE)
func _ready() -> void:
 add_to_group("crumble_blocks")
 collision_layer=1
 collision_mask=0
 shape=CollisionShape2D.new()
 var rect := RectangleShape2D.new()
 rect.size=Vector2(tiles*TILE,rows*TILE)
 shape.shape=rect
 shape.position=rect.size*0.5
 add_child(shape)
func stepped_on() -> void:
 if state!=State.SOLID or not available: return
 state=State.SHAKING
 timer=hold_time
 Sfx.play_at("step",global_position,-6.0)
func _physics_process(delta: float) -> void:
 time+=delta
 if state==State.SHAKING:
  timer-=delta
  if timer<=0: _shatter()
 elif state==State.GONE:
  timer-=delta
  if timer<=0 and not _player_inside(): reset()
 queue_redraw()
func _shatter() -> void:
 state=State.GONE
 timer=regrow_time
 shape.set_deferred("disabled",true)
 Sfx.play_at("land",global_position,-4.0)
 for i in tiles:
  PARTICLES.burst(self,global_position+Vector2(i*TILE+8,rows*TILE*0.5),Vector2.DOWN,"ice")
func reset() -> void:
 state=State.SOLID
 timer=0.0
 if shape: shape.set_deferred("disabled",not available)
func _player_inside() -> bool:
 var query := PhysicsShapeQueryParameters2D.new()
 query.shape=shape.shape
 query.transform=global_transform*Transform2D(0,shape.position)
 query.collision_mask=2
 return not get_world_2d().direct_space_state.intersect_shape(query,1).is_empty()
func _draw() -> void:
 if not available: return
 # Frames: 0 solid, 1 cracked (shaking), 2 outline of where it will regrow.
 var frame := 0 if state==State.SOLID else (1 if state==State.SHAKING else 2)
 var jitter := Vector2(randf_range(-1,1),0).round() if state==State.SHAKING else Vector2.ZERO
 var alpha := 0.5 if state==State.GONE else 1.0
 for j in rows:
  for i in tiles:
   draw_texture_rect_region(TEXTURE,Rect2(Vector2(i*TILE,j*TILE)+jitter,Vector2(TILE,TILE)),Rect2(frame*TILE,0,TILE,TILE),Color(1,1,1,alpha))
