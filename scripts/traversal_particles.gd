extends Node
const DUST=preload("res://assets/textures/traversal_dust.png")
const SPARK=preload("res://assets/textures/spark.png")
static func burst(host: Node,at: Vector2,direction: Vector2,kind: String,strength: float=1.0) -> void:
 var tree=host.get_tree()
 if tree.get_nodes_in_group("traversal_particles").size()>=40: return
 var particles=CPUParticles2D.new()
 particles.emitting=false
 particles.add_to_group("traversal_particles")
 particles.texture=DUST
 particles.one_shot=true
 particles.explosiveness=1.0
 particles.lifetime=0.35
 particles.amount=4
 particles.direction=direction
 particles.spread=65.0
 particles.gravity=Vector2(0,80)
 particles.initial_velocity_min=12.0
 particles.initial_velocity_max=40.0
 particles.scale_amount_min=0.35
 particles.scale_amount_max=0.8
 particles.color=Color("9eb7b8")
 if kind=="jump" or kind=="land":
  particles.amount=8+int(clampf(strength,0.0,1.0)*8)
  particles.initial_velocity_max=75.0
  particles.spread=80.0
 elif kind=="shot":
  particles.texture=SPARK
  particles.amount=13
  particles.lifetime=0.22
  particles.spread=22.0
  particles.initial_velocity_min=95.0
  particles.initial_velocity_max=210.0
  particles.color=Color("ffe3b3")
 elif kind=="pickup" or kind=="boost":
  particles.texture=SPARK
  particles.amount=12 if kind=="pickup" else 5
  particles.spread=180.0 if kind=="pickup" else 40.0
  particles.initial_velocity_max=70.0
  particles.color=Color("96e1cb")
 var fade=Gradient.new()
 fade.set_color(0,Color.WHITE)
 fade.set_color(1,Color(1,1,1,0))
 particles.color_ramp=fade
 particles.position=at
 particles.z_index=3
 tree.current_scene.add_child(particles)
 particles.finished.connect(particles.queue_free)
 particles.restart()
 particles.emitting=true
