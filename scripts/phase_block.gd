extends StaticBody2D
## Phase plate (Copper Cloud): a run of riveted plates that is solid only in its own phase.
## The level has one phase at a time: 0 = copper plates solid, 1 = teal plates solid. Shooting a
## phase switch swaps it. A plate never closes on the player: if the player overlaps it when its
## phase comes on, it waits as a flickering outline until the player is clear, then locks solid.
## Every room starts in phase 0 (on entry and on respawn), so routes are repeatable.
const TEXTURE=preload("res://assets/textures/phase_block.png")
const TILE := 16
static var phase := 0
static var _toggled_frame := -1
@export_range(0,1) var block_phase := 0
@export var tiles := 1
@export var rows := 1
var solid := true
var pending := false
var time := 0.0
var shape: CollisionShape2D
static func set_phase(tree: SceneTree, value: int) -> void:
 phase=value
 tree.call_group("phase_blocks","refresh")
 tree.call_group("phase_switches","refresh")
# One shot can sweep two switches; it still counts as a single swap.
static func toggle(tree: SceneTree) -> bool:
 if _toggled_frame==Engine.get_physics_frames(): return false
 _toggled_frame=Engine.get_physics_frames()
 set_phase(tree,1-phase)
 return true
func _ready() -> void:
 add_to_group("phase_blocks")
 collision_layer=1
 collision_mask=0
 shape=CollisionShape2D.new()
 var rect := RectangleShape2D.new()
 rect.size=Vector2(tiles*TILE,rows*TILE)
 shape.shape=rect
 shape.position=Vector2(tiles*TILE,rows*TILE)*0.5
 add_child(shape)
 refresh()
func refresh() -> void:
 var want := phase==block_phase
 pending=want and _player_inside()
 _set_solid(want and not pending)
func _physics_process(delta: float) -> void:
 time+=delta
 if pending and not _player_inside():
  pending=false
  _set_solid(true)
 queue_redraw()
func _set_solid(on: bool) -> void:
 solid=on
 shape.set_deferred("disabled",not on)
 queue_redraw()
func _player_inside() -> bool:
 if not is_inside_tree(): return false
 var query := PhysicsShapeQueryParameters2D.new()
 query.shape=shape.shape
 query.transform=global_transform*Transform2D(0,shape.position)
 query.collision_mask=2
 return not get_world_2d().direct_space_state.intersect_shape(query,1).is_empty()
func _draw() -> void:
 # Waiting plates flicker between outline and solid so the player sees them about to close.
 var show_solid := solid or (pending and int(time*20.0)%2==0)
 var frame := block_phase*2+(0 if show_solid else 1)
 var alpha := 1.0 if solid else 0.9
 # Hollow plates keep a light tint of their colour so the other layout can be read ahead.
 if not show_solid:
  draw_rect(Rect2(0,0,tiles*TILE,rows*TILE),(Color("d08a4f") if block_phase==0 else Color("6fc2b4"))*Color(1,1,1,0.16))
 for j in rows:
  for i in tiles:
   draw_texture_rect_region(TEXTURE,Rect2(i*TILE,j*TILE,TILE,TILE),Rect2(frame*TILE,0,TILE,TILE),Color(1,1,1,alpha))
