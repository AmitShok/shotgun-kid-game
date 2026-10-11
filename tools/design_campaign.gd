extends SceneTree
const NAMES=["mossy_comet","copper_cloud","velvet_glacier","echo_orchard"]
const TITLES=["MOSSY COMET","COPPER CLOUD","VELVET GLACIER","ECHO ORCHARD"]
func _initialize(): call_deferred("run")
func own(parent: Node,node: Node,root_node: Node):
 parent.add_child(node)
 node.owner=root_node
 return node
func actor(parent: Node,path: String,label: String,pos: Vector2,root_node: Node):
 var node=load(path).instantiate()
 node.name=label
 if node is Node2D: node.position=pos
 own(parent,node,root_node)
 return node
func run():
 for difficulty in range(4):
  var id=NAMES[difficulty]
  var level=Node2D.new()
  level.name=TITLES[difficulty].replace(" ","")
  level.set_script(load("res://scripts/level.gd"))
  level.level_title=TITLES[difficulty]
  level.set("checkpoint_fall_distance",420.0)
  var root_scene=level
  actor(level,"res://scenes/components/"+id+"_backdrop.tscn","Backdrop",Vector2.ZERO,level)
  var terrain=Node2D.new();terrain.name="Terrain";own(level,terrain,level)
  var ground=TileMapLayer.new();ground.name="Ground";ground.tile_set=load("res://assets/"+id+"_tileset.tres");own(terrain,ground,level)
  var containers={}
  for label in ["Mines","Pickups","Hazards","Scenery","Signs"]:
   var node=Node2D.new();node.name=label;own(level,node,level);containers[label]=node
  var details=Node2D.new();details.name="ThemeDetails";details.z_index=-1;own(containers.Scenery,details,level)
  # Authored routes: direction, elevation and mechanic change independently.
  # dx, dy, mechanic, landmark. Values are tile-aligned, positive y is DOWN.
  var courses=[
   [[320,-64,"diagonal","FIRST LEAP"],[304,96,"drop","LOW CANOPY"],[768,-64,"mine","COMET SLING"],[640,-32,"shell","VINE RELAY"],[160,-416,"lift","CROWN WELL"],[-352,-64,"diagonal","RETURN BRANCH"],[-320,0,"dash","ROOT PASSAGE"],[-320,160,"drop","FERN FALL"],[-640,-48,"shell","STAR SEEDS"],[-768,-64,"mine","HOMEWARD ARC"]],
   [[320,0,"dash","MARKET ARCADE"],[400,-80,"diagonal","ROOFTOP STEP"],[800,-48,"mine","SKYBRIDGE"],[288,176,"drop","LOWER BALCONY"],[624,-32,"shell","COURIER RUN"],[160,-416,"lift","BELL TOWER"],[-336,0,"dash","RETURN ARCADE"],[-416,-96,"diagonal","PATINA ROOFS"],[832,-48,"mine","CLOUD EXPRESS"],[320,128,"drop","SERVICE DECK"],[624,-64,"shell","LAST DELIVERY"],[400,-96,"diagonal","SUNSET STATION"]],
   [[368,-96,"diagonal","BLUE THRESHOLD"],[336,0,"dash","ICE GALLERY"],[288,160,"drop","MELTWATER DROP"],[592,-64,"shell","CRYSTAL THREAD"],[832,-80,"mine","FROZEN LAKE"],[160,-416,"lift","CHIMNEY"],[-320,0,"dash","VIOLET TUNNEL"],[-432,-96,"diagonal","BROKEN SHELF"],[-608,-48,"shell","REFRACTION"],[-352,192,"drop","DEEP POCKET"],[-864,-64,"mine","ECHO VAULT"],[-160,-416,"lift","SECOND CHIMNEY"],[432,-96,"diagonal","DAYLIGHT CRACK"],[320,0,"dash","THAW EXIT"]],
   [[400,-112,"diagonal","PETAL STEPS"],[592,-64,"shell","POLLEN RELAY"],[1152,-80,"relay","BLOOM CANNON"],[336,176,"drop","FALLING PETALS"],[320,0,"dash","ROOT ARCH"],[160,-416,"lift","GIANT STEM"],[-416,-96,"diagonal","BACK THROUGH BLOOMS"],[-592,-64,"shell","NECTAR THREAD"],[-896,-64,"mine","SEED SLING"],[-352,144,"drop","LOWER BOUGH"],[-320,0,"dash","HOLLOW TRUNK"],[-160,-416,"lift","CROWN ASCENT"],[592,-64,"shell","FINAL RELAY"],[416,-96,"diagonal","LAST PETALS"],[1280,-80,"relay","HARVEST FLIGHT"],[320,0,"dash","ORCHARD GATE"]]
  ]
  var route=[]
  var center=Vector2(144,544)
  var course=courses[difficulty]
  var width=192-difficulty*16
  var centers=[center]
  for row in course: centers.append(centers[-1]+Vector2(row[0],row[1]))
  var min_corner=center;var max_corner=center
  for i in range(centers.size()):
   center=centers[i]
   min_corner=min_corner.min(center);max_corner=max_corner.max(center)
   var platform_width=224 if i==0 else width
   # Broad islands, deep city piers, faceted ice shelves, and thick orchard roots.
   var depth=[4,12,5,7][difficulty]+i%3
   if difficulty==1 and i==9: depth=4 # A shallow overpass above the earlier arcade.
   island(ground,center-Vector2(platform_width/2.0,0),Vector2i(platform_width/16,depth),i,difficulty)
   for xx in range(1,platform_width/16-1,3):
    var hanging_cell=Vector2i(floori((center.x-platform_width/2.0)/16)+xx,floori(center.y/16)+depth)
    if ground.get_cell_source_id(hanging_cell-Vector2i(0,1))==0:
     ground.set_cell(hanging_cell,0,Vector2i((xx+i)%8,3))
   # Dress both ends of the safe landing, never the gap or checkpoint.
   for side in [-1,1]:
    var ornament=Sprite2D.new();ornament.name="Detail%d_%d"%[i,side+1]
    ornament.texture=load("res://assets/textures/"+id+"_decor.png");ornament.hframes=4;ornament.vframes=2;ornament.frame=(i+(1 if side>0 else 0))%3
    ornament.position=center+Vector2(side*(platform_width/2.0-20),-15);own(details,ornament,level)
   var flag=actor(level,"res://scenes/actors/checkpoint.tscn","Checkpoint%d"%i,center,level)
   flag.landing_width=platform_width
   if i==course.size(): continue
   var row=course[i];var kind=row[2];var target: Vector2=centers[i+1]
   var direction=signf(float(row[0]))
   var launch=center+Vector2(direction*(platform_width/2.0-32),0)
   if kind=="lift": launch=center+Vector2(direction*32,0)
   var item_pos=launch
   if kind in ["mine","relay"]: item_pos=launch+Vector2(-direction*24,-32)
   if kind=="lift": item_pos=launch+Vector2(0,-44)
   if kind in ["mine","lift","relay"]: actor(containers.Mines,"res://scenes/actors/boost_mine.tscn","Mine%d"%(i+1),item_pos,level)
   if kind=="shell":
    item_pos=launch+Vector2(direction*240,-144)
    actor(containers.Pickups,"res://scenes/actors/shell_pickup.tscn","Shell%d"%(i+1),item_pos,level)
   if kind=="relay":
    var relay_shell=actor(containers.Pickups,"res://scenes/actors/shell_pickup.tscn","Shell%d"%(i+1),launch+Vector2(direction*640,-192),level)
    relay_shell.collection_radius=22.0 # Forgiving catch at mine-boost speed; within the visible glow.
   # The arcade roof is solid terrain: side shots stay low; upward spam hits it.
   if kind=="dash":
    var roof_left=center.x+platform_width/2.0+16 if direction>0 else target.x+width/2.0+32
    var roof_right=target.x-width/2.0-32 if direction>0 else center.x-platform_width/2.0-16
    paint(ground,Vector2(roof_left,center.y-144),Vector2i(ceili((roof_right-roof_left)/16),2),i+3)
    for roof_x in range(floori(roof_left/16),ceili(roof_right/16)):
     actor(containers.Hazards,"res://scenes/actors/spikes.tscn","RoofSpikes%d_%d"%[i,roof_x],Vector2(roof_x*16+8,center.y-144),level)
   # Cave and root silhouettes above diagonal passages keep each theme architectural.
   if difficulty>=2 and kind=="diagonal":
    paint(ground,target+Vector2(-width/2.0,-256),Vector2i(width/16,3),i+2)
   # Landing hazards sit at the far lip, leaving a readable central catch zone.
   if difficulty>0 and kind in ["diagonal","drop","shell"] and i<course.size()-1:
    actor(containers.Hazards,"res://scenes/actors/spikes.tscn","EdgeSpikes%d"%i,target+Vector2(direction*(width/2.0-8),0),level)
   # Obstacles define the flight corridor without instructional signs or arrows.
   if (difficulty==0 and i==9) or (difficulty==1 and kind=="mine") or (difficulty==3 and kind=="relay"):
    var obstacle_x=snappedf(lerpf(launch.x,target.x,0.52),16)
    var obstacle_top=center.y-96 if difficulty!=1 else center.y-112
    var obstacle_width=48 if difficulty==0 else 64
    paint(ground,Vector2(obstacle_x-obstacle_width/2,obstacle_top),Vector2i(obstacle_width/16,5),i)
    for tile in range(obstacle_width/16):
     actor(containers.Hazards,"res://scenes/actors/spikes.tscn","FlightThorns%d_%d"%[i,tile],Vector2(obstacle_x-obstacle_width/2+tile*16+8,obstacle_top),level)
   if difficulty==2 and kind in ["mine","shell"]:
    # Hanging ice over the central flight path constrains excessive height.
    var vault_x=snappedf(lerpf(launch.x,target.x,0.48),16)
    paint(ground,Vector2(vault_x-96,center.y-336),Vector2i(12,3),i)
    for tile in range(12):
     var icicle=actor(containers.Hazards,"res://scenes/actors/spikes.tscn","VaultIcicle%d_%d"%[i,tile],Vector2(vault_x-88+tile*16,center.y-288),level)
     icicle.rotation=PI
   route.append({"kind":kind,"launch":launch,"start":center,"target":target,"width":width,"item":item_pos,"landmark":row[3]})
  center=centers[-1]
  actor(level,"res://scenes/actors/exit.tscn","Exit",center+Vector2(32*signf(float(course[-1][0])),0),level)
  actor(level,"res://scenes/actors/player.tscn","Player",Vector2(144,530),level)
  var hud=load("res://scenes/ui/hud.tscn").instantiate();hud.name="HUD";own(level,hud,level)
  level.camera_bounds=Rect2(min_corner-Vector2(400,400),max_corner-min_corner+Vector2(800,880))
  level.fall_limit_y=max_corner.y+480
  level.set_meta("traversal_route",route)
  var packed=PackedScene.new();packed.pack(level)
  var error=ResourceSaver.save(packed,"res://scenes/levels/"+id+".tscn")
  var path="res://scenes/levels/"+id+".tscn"
  var lines=FileAccess.get_file_as_string(path).split("\n")
  var clean=PackedStringArray()
  for line in lines:
   if not line.begins_with("[connection "): clean.append(line)
  var file=FileAccess.open(path,FileAccess.WRITE);file.store_string("\n".join(clean));file.close()
  print("BUILT ",id," challenges=",course.size()," result=",error)
  level.free()
 quit()


func paint(grid: TileMapLayer,top_left: Vector2,size: Vector2i,seed: int):
 var origin=Vector2i(floori(top_left.x/16),floori(top_left.y/16))
 for y in range(size.y):
  for x in range(size.x):
   grid.set_cell(origin+Vector2i(x,y),0,Vector2i(1+posmod(x+seed,3),0 if y==0 else 2 if y==size.y-1 else 1))

func island(grid: TileMapLayer,top_left: Vector2,size: Vector2i,seed: int,biome: int):
 var origin=Vector2i(floori(top_left.x/16),floori(top_left.y/16))
 for y in range(size.y):
  var inset=0
  if y>1:
   if biome==0: inset=mini((y-1)/2+seed%2,size.x/2-2)
   elif biome==1: inset=1 if y<7 else 2
   elif biome==2: inset=mini(y/2,size.x/2-2)
   else: inset=1 if y<4 else 2+(seed%2)
  for x in range(inset,size.x-inset):
   # Preserve a continuous top; lower roots and comet facets break the silhouette.
   if biome==3 and y>size.y-3 and posmod(x+seed,4)==0: continue
   grid.set_cell(origin+Vector2i(x,y),0,Vector2i(1+posmod(x+seed,3),0 if y==0 else 2 if y==size.y-1 else 1))
