extends Node2D
## Spore pod (Mossy Comet): a grapple point. Shoot it from up to shot_range away (aim must be
## close, within shot_cone) and it pulls the player straight in; the player keeps that speed past
## the pod, like a slingshot, and gets one shell back. Its rotation only orients the art toward
## the surface it grows from. Regrows after a moment.
signal burst
const PARTICLES=preload("res://scripts/traversal_particles.gd")
@export var shot_range := 240.0
@export_range(0.5,1.0,0.01) var shot_cone := 0.94
@export_range(0.2,10.0,0.1) var regrow_seconds := 1.6
var armed := true
var regrow_left := 0.0
var time := 0.0
# 0 = out of reach, 1 = grabbable from here, 2 = the current aim would grab it.
var reach_state := 0
var light := 0.0
func _ready() -> void:
 add_to_group("shot_targets")
 add_to_group("spore_pods")
func _physics_process(delta: float) -> void:
 time+=delta
 reach_state=_reach_state() if armed else 0
 # Light up while the player can grab the pod, and flare when the current aim would grab it.
 light=lerpf(light,[0.0,0.7,1.0][reach_state],1.0-exp(-16.0*delta))
 var pulse := sin(time*(4.0+light*6.0))*(0.04+light*0.04)
 $Sprite2D.scale=Vector2(1.0+pulse,1.0-pulse)*(1.0+light*0.12) if armed else Vector2.ONE
 $Sprite2D.modulate=Color.WHITE.lerp(Color(1.7,2.0,1.6),light) if armed else Color.WHITE
 $Glow.modulate.a=(0.3+sin(time*3.0)*0.08+light*0.65) if armed else 0.0
 $Glow.scale=Vector2.ONE*(0.55+light*0.45)
 _update_marker()
 if armed: return
 regrow_left-=delta
 if regrow_left<=0:
  reset()
  Sfx.play_at("mine_ready",global_position,-14.0)
# Off-screen pods show a pulsing arrow at the screen edge: any pod in the player's room, and
# pods in neighbouring rooms the player has a clear line to (the next grab across a doorway).
var marker_at := Vector2.ZERO
var marker_alpha := 0.0
func _update_marker() -> void:
 var shown := 0.0
 var level := get_tree().current_scene
 var player: Node2D=get_tree().get_first_node_in_group("player")
 if armed and player and "current_room" in level and level.current_room and global_position.distance_to(player.global_position)<=shot_range*1.6:
  var view: Rect2=get_viewport().get_canvas_transform().affine_inverse()*get_viewport().get_visible_rect()
  if not view.grow(-4).has_point(global_position) and (level.current_room.rect().has_point(global_position) or _clear_line_to(player)):
   shown=1.0 if reach_state>0 else 0.55
   marker_at=global_position.clamp(view.position+Vector2(14,14),view.end-Vector2(14,14))
 marker_alpha=move_toward(marker_alpha,shown,6.0*get_physics_process_delta_time())
 queue_redraw()
func _clear_line_to(player: Node2D) -> bool:
 var ray := PhysicsRayQueryParameters2D.create(global_position,player.global_position,1)
 return get_world_2d().direct_space_state.intersect_ray(ray).is_empty()
func _draw() -> void:
 if marker_alpha<=0.01: return
 var at := to_local(marker_at)
 var dir := (Vector2.ZERO-at).normalized()
 var side := dir.orthogonal()
 var bob := sin(time*8.0)*2.0
 var tip := at+dir*(7.0+bob)
 var color := Color(0.62,1.0,0.66,marker_alpha)
 var ink := Color(0.05,0.1,0.08,marker_alpha)
 draw_colored_polygon(PackedVector2Array([tip+dir*1.5,tip-dir*8.5+side*6.5,tip-dir*8.5-side*6.5]),ink)
 draw_colored_polygon(PackedVector2Array([tip,tip-dir*7+side*5,tip-dir*7-side*5]),color)
 draw_circle(tip-dir*11,2.5,color)
func _reach_state() -> int:
 for player in get_tree().get_nodes_in_group("player"):
  if player.dying>0: continue
  var gun: Node2D=player.shotgun
  var offset: Vector2=global_position-gun.global_position
  if offset.length()>shot_range: continue
  var ray := PhysicsRayQueryParameters2D.create(gun.global_position,global_position,1)
  if not get_world_2d().direct_space_state.intersect_ray(ray).is_empty(): continue
  return 2 if offset.length()<=20 or gun.aim.dot(offset.normalized())>=shot_cone else 1
 return 0
func hit() -> void:
 if not armed: return
 armed=false
 regrow_left=regrow_seconds
 $Sprite2D.frame=1
 Sfx.play_at("mine_blast",global_position,-6.0)
 for player in get_tree().get_nodes_in_group("player"):
  var ray := PhysicsRayQueryParameters2D.create(global_position,player.global_position,1)
  if not get_world_2d().direct_space_state.intersect_ray(ray).is_empty(): continue
  PARTICLES.burst(self,global_position,(player.global_position-global_position).normalized(),"spore")
  player.pull_to(global_position)
  player.shotgun.add_ammo(1)
 burst.emit()
func reset() -> void:
 armed=true
 regrow_left=0.0
 $Sprite2D.frame=0
