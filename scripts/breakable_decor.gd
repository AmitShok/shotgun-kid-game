extends Sprite2D
## Scenery that breaks, Hollow Knight style: a shotgun blast (or a mine going off nearby) smashes
## the prop into pieces of its own sprite, which fly away from the blast, tumble, bounce on the
## ground and settle as debris before fading. Purely cosmetic: no collision, no effect on
## movement. A broken prop stays broken until the level is reloaded (dying does not restore it).
## The level builder (tools/build_rooms.gd) gives every scenery prop this script.
const PIECE := 8
const GRAVITY := 700.0
const DUST=preload("res://scripts/traversal_particles.gd")
# Which 8x8 pieces of each texture region actually hold pixels, so empty corners don't fly off.
static var solid_pieces: Dictionary = {}
var broken := false
var pieces: Array[Dictionary] = []
var age := 0.0

func _ready() -> void:
 add_to_group("shot_targets")
 add_to_group("breakable_decor")

## Shotgun hit: break away from whoever fired.
func hit() -> void:
 var player := get_tree().get_first_node_in_group("player") as Node2D
 var away := (global_position-player.global_position).normalized() if player else Vector2.UP
 smash(away,1.0)

## A mine blast breaks anything near it.
func blast(at: Vector2,radius: float) -> void:
 var offset := global_position-at
 if offset.length()<=radius*0.8: smash(offset.normalized() if offset.length()>1 else Vector2.UP,1.4)

func smash(away: Vector2,force: float) -> void:
 if broken: return
 broken=true
 var region := _region()
 for cell in _pieces_of(region):
  var piece := Sprite2D.new()
  var atlas := AtlasTexture.new()
  atlas.atlas=texture
  atlas.region=Rect2(region.position+Vector2(cell),Vector2(PIECE,PIECE))
  piece.texture=atlas
  piece.position=Vector2(cell)+Vector2(PIECE,PIECE)*0.5-region.size*0.5
  add_child(piece)
  # Pieces spread from the middle of the prop and are carried away from the blast.
  var spread := piece.position.normalized() if piece.position.length()>1 else Vector2.UP
  var velocity := (away*randf_range(90,190)+spread*randf_range(40,110)+Vector2(0,-randf_range(120,220)))*force
  pieces.append({"node":piece,"v":velocity,"spin":randf_range(-14,14),"resting":false})
 # Hide only the whole-prop drawing: the pieces are children and draw themselves.
 self_modulate.a=0.0
 remove_from_group("shot_targets")
 DUST.burst(get_parent(),global_position,Vector2.UP,"land",1.4)
 # Looked up at run time: the level builder loads this script without the game autoloads.
 var sfx := get_node_or_null("/root/Sfx")
 if sfx: sfx.play_at("land",global_position,-4.0)
 set_physics_process(true)

func _physics_process(delta: float) -> void:
 if not broken:
  set_physics_process(false)
  return
 age+=delta
 var space := get_world_2d().direct_space_state
 for p in pieces:
  var node: Sprite2D=p.node
  if p.resting: continue
  p.v.y+=GRAVITY*delta
  var from: Vector2=node.global_position
  var to: Vector2=from+p.v*delta
  var ray := PhysicsRayQueryParameters2D.create(from,to+Vector2(0,3),1)
  var hit_info := space.intersect_ray(ray)
  if hit_info.is_empty():
   node.global_position=to
   node.rotation+=p.spin*delta
  else:
   # Bounce off the world, losing most of the energy, and settle once slow.
   node.global_position=hit_info.position-Vector2(0,3)
   var n: Vector2=hit_info.normal
   p.v=(p.v-2.0*p.v.dot(n)*n)*0.35
   p.spin*=0.5
   if p.v.length()<40 and n.y<-0.5:
    p.resting=true
    node.rotation=snappedf(node.rotation,PI*0.5)
 # Debris lies on the ground a while, then fades out.
 if age>3.0:
  var fade := clampf(1.0-(age-3.0)/1.2,0.0,1.0)
  for p in pieces: p.node.modulate.a=fade
  if fade<=0.0:
   for p in pieces: p.node.queue_free()
   pieces.clear()
   set_physics_process(false)

func _region() -> Rect2:
 if region_enabled: return region_rect
 var size := texture.get_size()/Vector2(hframes,vframes)
 return Rect2(Vector2(frame%hframes,frame/hframes)*size,size)

func _pieces_of(region: Rect2) -> Array:
 var key := "%s/%s" % [texture.resource_path,region]
 if solid_pieces.has(key): return solid_pieces[key]
 var image := texture.get_image()
 var found := []
 for y in range(0,int(region.size.y),PIECE):
  for x in range(0,int(region.size.x),PIECE):
   var used := false
   for yy in range(y,mini(y+PIECE,int(region.size.y))):
    for xx in range(x,mini(x+PIECE,int(region.size.x))):
     if image.get_pixel(int(region.position.x)+xx,int(region.position.y)+yy).a>0.1: used=true;break
    if used: break
   if used: found.append(Vector2i(x,y))
 solid_pieces[key]=found
 return found
