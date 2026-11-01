extends StaticBody2D
## Slippery ice (Velvet Glacier): solid ground with almost no grip. The player keeps momentum on
## it (see on_ice in player.gd), so a shot's kick is the only quick way to stop or turn.
const TEXTURE=preload("res://assets/textures/slick_ice.png")
const TILE := 16
@export var tiles := 1
@export var rows := 1
func _ready() -> void:
 add_to_group("ice")
 collision_layer=1
 collision_mask=0
 var shape := CollisionShape2D.new()
 var rect := RectangleShape2D.new()
 rect.size=Vector2(tiles*TILE,rows*TILE)
 shape.shape=rect
 shape.position=rect.size*0.5
 add_child(shape)
func _draw() -> void:
 # Frame 0 is the glossy top row, frame 1 the body below it.
 for j in rows:
  for i in tiles:
   draw_texture_rect_region(TEXTURE,Rect2(i*TILE,j*TILE,TILE,TILE),Rect2((0 if j==0 else 1)*TILE,0,TILE,TILE))
