extends Node2D
## Wind gust (Echo Orchard): a rectangle of air that shoves the player while it blows. Every zone
## shares one rhythm (calm, a flickering warning, then the gust) restarted on room entry and on
## death, so gusts are timing you can learn. Gusts add speed only up to max_speed along their
## direction: they carry a kick further, they don't fling you at any speed.
const TILE := 16
const CALM := 0.9
const WARN := 0.35
const GUST := 1.1
@export var tiles := 1
@export var rows := 1
@export var direction := Vector2.RIGHT
@export var strength := 1400.0
@export var max_speed := 280.0
var time := 0.0
# Cleared by the route tests' skip search to prove a room needs its wind.
var available := true:
 set(value):
  available=value
  visible=value
func _ready() -> void:
 add_to_group("wind_zones")
func reset() -> void:
 time=0.0
func blowing() -> bool:
 return available and fmod(time,CALM+GUST)>=CALM
func warning() -> bool:
 var t := fmod(time,CALM+GUST)
 return available and t>=CALM-WARN and t<CALM
func rect() -> Rect2:
 return Rect2(global_position,Vector2(tiles*TILE,rows*TILE))
func push_body(body: CharacterBody2D,delta: float) -> void:
 if not blowing() or not rect().has_point(body.global_position): return
 var along := body.velocity.dot(direction)
 if along<max_speed: body.velocity+=direction*minf(strength*delta,max_speed-along)
func _physics_process(delta: float) -> void:
 time+=delta
 queue_redraw()
func _draw() -> void:
 if not available: return
 var size := Vector2(tiles*TILE,rows*TILE)
 var gust := blowing()
 var warn := warning()
 draw_rect(Rect2(Vector2.ZERO,size),Color(0.78,0.95,0.86,0.10 if gust else (0.06 if warn else 0.03)))
 # Streaks drift with the wind: fast and bright in a gust, a faint stutter while it warns.
 var across := Vector2(-direction.y,direction.x).abs()
 var length := size.dot(direction.abs())
 var width := size.dot(across)
 var count := int(maxf(2.0,width/12.0))
 var speed := 260.0 if gust else 40.0
 var alpha := 0.55 if gust else (0.35 if warn and int(time*16.0)%2==0 else 0.0)
 if alpha<=0: return
 for i in count:
  var lane := (float(i)+0.5)/count*width
  var travel := fposmod(time*speed+float(i*53%97)*7.0,length+24.0)-12.0
  var start := direction*travel if direction.x+direction.y>0 else direction*travel+size*direction.abs()
  var a := start+across*lane
  var b := a+direction*(14.0 if gust else 6.0)
  var lo := Vector2.ZERO
  if Rect2(lo,size).has_point(a) or Rect2(lo,size).has_point(b):
   draw_line(a.clamp(lo,size),b.clamp(lo,size),Color(0.92,1.0,0.94,alpha),1.0)
