extends Node2D
## Trailing scarf: a chain of follow points drawn as a crisp pixel ribbon (highlight, body,
## shadow rows taken from the style's swatch), tapering toward the tip. Plotting pixels
## directly keeps it sharp; rotated, stretched sprites smeared the pixel art.
@export var segment_length := 2.7
@export var follow_rate := 19.0
const COUNT := 7
var points: Array[Vector2] = []
var pattern: Image
var clock := 0.0
@onready var player: CharacterBody2D=get_parent()
func _ready() -> void:
 pattern=preload("res://assets/textures/scarf_segment.png").get_image()
 reset_trail()
# Torso offset per sprite frame (matches the pose table in tools/art_wardrobe.lua), so the
# scarf stays tied to the neck through every pose.
const TORSO := [Vector2(0,0),Vector2(0,0),Vector2(0,1),Vector2(0,0),Vector2(1,0),Vector2(1,1),Vector2(1,0),Vector2(1,0),
 Vector2(1,1),Vector2(1,0),Vector2(0,-1),Vector2(0,0),Vector2(0,0),Vector2(0,0),Vector2(0,2),Vector2(-1,0)]
func anchor() -> Vector2:
 var body: Sprite2D=player.get_node("Sprite2D")
 var pose: Vector2=TORSO[body.frame] if body.frame<TORSO.size() else Vector2.ZERO
 return player.global_position+Vector2((-4.5+pose.x)*player.facing,2.0+pose.y)*body.scale
func reset_trail() -> void:
 points.clear()
 var head=anchor()
 for i in range(COUNT): points.append(head+Vector2(-player.facing*(i+1)*segment_length*0.8,0.8*i))
 queue_redraw()
func _physics_process(delta: float) -> void:
 clock+=delta
 var head=anchor()
 if points.is_empty() or head.distance_to(points[0])>64.0: reset_trail()
 var previous=head
 # Speed adds a gentle airflow pull and a faster, wider ripple; at rest the scarf droops.
 var speed := clampf(player.velocity.length()/300.0,0.0,1.0)
 var airflow=(-player.velocity*0.004).limit_length(1.6)
 for i in range(points.size()):
  var ripple=sin(clock*(5.0+7.0*speed)-i*0.8)*(0.25+0.65*speed)
  var rest=Vector2(-player.facing*1.8,0.85+ripple)+airflow
  var target=previous+rest
  points[i]=points[i].lerp(target,1.0-exp(-follow_rate*delta))
  var offset=points[i]-previous
  if offset.length()>segment_length: points[i]=previous+offset.normalized()*segment_length
  previous=points[i]
 modulate.a=player.get_node("Sprite2D").modulate.a
 queue_redraw()
const INK := Color("202139")
func _draw() -> void:
 if points.is_empty() or pattern==null: return
 # Collect ribbon pixels first so a full ink outline can go underneath, matching the
 # outlined body sprite and the wardrobe neck wraps.
 var ribbon: Array[Array] = []
 var previous: Vector2=to_local(anchor()).round()
 var step := 0
 for i in range(points.size()):
  var next: Vector2=to_local(points[i]).round()
  var delta: Vector2=next-previous
  var count := int(maxf(absf(delta.x),absf(delta.y)))
  # Three rows near the neck, two mid-way, a single row at the tip.
  var thickness := 3 if i<5 else (2 if i<6 else 1)
  var across := Vector2(0,1) if absf(delta.x)>=absf(delta.y) else Vector2(1,0)
  for s in range(1 if i>0 else 0,count+1):
   ribbon.append([(previous+delta*(float(s)/maxf(count,1))).round(),across,thickness,step%pattern.get_width()])
   step+=1
  previous=next
 for pixel in ribbon:
  for row in range(-1,pixel[2]+1):
   draw_rect(Rect2(pixel[0]+pixel[1]*(row-1),Vector2.ONE),INK)
 for pixel in ribbon:
  for row in range(pixel[2]):
   # Thin tips keep the body and shadow rows; the highlight drops first.
   draw_rect(Rect2(pixel[0]+pixel[1]*(row-1),Vector2.ONE),pattern.get_pixel(pixel[3],row+3-pixel[2]))

func set_style(id: String) -> void:
 var catalog=preload("res://scripts/wardrobe_catalog.gd")
 visible=id!="no_scarf"
 segment_length=maxf(0.1,float(catalog.item("scarves",id).length))
 var tail: Texture2D=catalog.tail(id)
 if tail: pattern=tail.get_image()
 reset_trail()
