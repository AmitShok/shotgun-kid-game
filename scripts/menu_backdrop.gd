extends Control
## Animated menu background: the chosen world's sky and parallax layers drift sideways, motes
## float up through them, and switching worlds crossfades between the two biomes.
const WORLDS=preload("res://scripts/world_catalog.gd")
const MOTES := 46
var world := 0
var previous := -1
var fade := 1.0
var clock := 0.0
var skies: Array[Texture2D] = []
var layers: Array = []
var motes: Array[Texture2D] = []
var seeds: Array[Vector3] = []
func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 for entry in WORLDS.WORLDS:
  skies.append(WORLDS.texture(entry.sky))
  layers.append(entry.layers.map(func(name): return WORLDS.texture(name)))
  motes.append(WORLDS.texture(entry.mote))
 for i in MOTES: seeds.append(Vector3(randf(),randf(),randf_range(0.5,1.4)))
func set_world(index: int) -> void:
 if index==world: return
 previous=world
 world=index
 fade=0.0
func _process(delta: float) -> void:
 clock+=delta
 fade=minf(1.0,fade+delta*2.2)
 queue_redraw()
func _draw() -> void:
 if previous>=0 and fade<1.0: _draw_world(previous,1.0)
 _draw_world(world,fade if previous>=0 else 1.0)
 _draw_motes()
func _draw_world(index: int,alpha: float) -> void:
 var tint := Color(1,1,1,alpha)
 var sky: Texture2D=skies[index]
 if sky: draw_texture_rect(sky,Rect2(Vector2.ZERO,size),false,tint)
 var planes: Array=layers[index]
 for i in planes.size():
  var texture: Texture2D=planes[i]
  if texture==null: continue
  # Nearer layers drift faster, with a slow sway so the scene breathes.
  var speed := 6.0+i*9.0
  var width: float=texture.get_width()
  var offset := fposmod(clock*speed,width)
  var y: float=size.y-texture.get_height()+sin(clock*0.4+i)*2.0
  var x := -offset
  while x<size.x:
   draw_texture(texture,Vector2(x,y),tint)
   x+=width
func _draw_motes() -> void:
 var color: Color=WORLDS.WORLDS[world].color
 var texture: Texture2D=motes[world]
 for seed in seeds:
  var rise := fposmod(seed.y*size.y-clock*14.0*seed.z,size.y+20.0)-10.0
  var x: float=seed.x*size.x+sin(clock*0.9*seed.z+seed.x*12.0)*10.0
  var a := 0.35+0.35*sin(clock*2.0+seed.x*20.0)
  if texture: draw_texture(texture,Vector2(x,size.y-rise)-texture.get_size()*0.5,Color(1,1,1,a*fade))
  else: draw_circle(Vector2(x,size.y-rise),1.0+seed.z,Color(color,a*0.6*fade))
