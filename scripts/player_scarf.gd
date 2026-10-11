extends Node2D
## Following-node scarf inspired by Celeste's published hair approach, not rigid-body cloth.
@export var segment_length := 2.7
@export var follow_rate := 19.0
var points: Array[Vector2] = []
var segments: Array[Sprite2D] = []
var clock := 0.0
@onready var player: CharacterBody2D=get_parent()
func _ready() -> void:
 for i in range(7):
  var sprite=Sprite2D.new()
  sprite.texture=preload("res://assets/textures/scarf_segment.png")
  add_child(sprite)
  segments.append(sprite)
 reset_trail()
func anchor() -> Vector2:
 var body: Sprite2D=player.get_node("Sprite2D")
 var bob=1.0 if body.frame in [1,3,5] else 0.0
 return player.global_position+Vector2(-4.5*player.facing,1.0+bob)*body.scale
func reset_trail() -> void:
 points.clear()
 var head=anchor()
 for i in range(7): points.append(head+Vector2(-player.facing*(i+1)*segment_length,0.5*i))
 _place_segments(head)
func _physics_process(delta: float) -> void:
 clock+=delta
 var head=anchor()
 if points.is_empty() or head.distance_to(points[0])>64.0: reset_trail()
 var previous=head
 var airflow=(-player.velocity*0.006).limit_length(2.3)
 for i in range(points.size()):
  var rest=Vector2(-player.facing*1.7,0.9+sin(clock*5.0-i*.7)*.3)+airflow
  var target=previous+rest
  points[i]=points[i].lerp(target,1.0-exp(-follow_rate*delta))
  var offset=points[i]-previous
  if offset.length()>segment_length: points[i]=previous+offset.normalized()*segment_length
  previous=points[i]
 _place_segments(head)
func _place_segments(head: Vector2) -> void:
 var previous=head
 for i in range(segments.size()):
  var offset=points[i]-previous
  segments[i].global_position=((points[i]+previous)*0.5).round()
  segments[i].rotation=offset.angle()
  segments[i].scale=Vector2(maxf(0.4,offset.length()/5.0),1.0 if i<5 else 0.7)
  segments[i].modulate.a=player.get_node("Sprite2D").modulate.a
  previous=points[i]

func set_style(id: String) -> void:
 var catalog=preload("res://scripts/wardrobe_catalog.gd")
 visible=id!="no_scarf"
 segment_length=maxf(0.1,float(catalog.item("scarves",id).length))
 for sprite in segments: sprite.texture=catalog.tail(id)
 reset_trail()
