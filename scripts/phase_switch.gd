extends Node2D
## Phase switch (Copper Cloud): shoot it to swap which phase plates are solid (see phase_block.gd).
## Its lit face shows the active phase. It does not refund the shell and the shot still kicks,
## so every swap costs a shot and moves the player.
const PHASE=preload("res://scripts/phase_block.gd")
const PARTICLES=preload("res://scripts/traversal_particles.gd")
@export var shot_range := 180.0
@export_range(0.5,1.0,0.01) var shot_cone := 0.80
var armed := true
var time := 0.0
var flash := 0.0
func _ready() -> void:
 add_to_group("shot_targets")
 add_to_group("phase_switches")
 refresh()
func _physics_process(delta: float) -> void:
 time+=delta
 flash=move_toward(flash,0.0,delta*4.0)
 $Sprite2D.scale=Vector2.ONE*(1.0+flash*0.25)
 $Glow.modulate=(Color(1.0,0.75,0.45) if PHASE.phase==0 else Color(0.5,1.0,0.9))*Color(1,1,1,0.35+sin(time*3.0)*0.08+flash*0.6)
func hit() -> void:
 if not armed: return
 if not PHASE.toggle(get_tree()): return
 flash=1.0
 Sfx.play_at("mine_ready",global_position,-4.0)
 PARTICLES.burst(self,global_position,Vector2.UP,"phase")
func refresh() -> void:
 $Sprite2D.frame=PHASE.phase
func reset() -> void:
 flash=0.0
 refresh()
