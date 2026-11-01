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
 elif kind=="death":
  # Coral and cream sparks scatter outward from the body.
  particles.texture=SPARK
  particles.amount=22
  particles.lifetime=0.5
  particles.spread=180.0
  particles.gravity=Vector2(0,140)
  particles.initial_velocity_min=60.0
  particles.initial_velocity_max=170.0
  particles.scale_amount_max=1.2
  var palette=Gradient.new()
  palette.set_color(0,Color("ff8f73"))
  palette.set_color(1,Color("ffe3b3"))
  particles.color_initial_ramp=palette
  particles.color=Color.WHITE
 elif kind=="ice":
  # Shards of a shattered crumble ledge tumble away.
  particles.texture=SPARK
  particles.amount=10
  particles.lifetime=0.55
  particles.spread=70.0
  particles.gravity=Vector2(0,420)
  particles.initial_velocity_min=30.0
  particles.initial_velocity_max=90.0
  particles.color=Color("d6e8f6")
 elif kind=="phase":
  # A ring of cream sparks off a struck phase switch.
  particles.texture=SPARK
  particles.amount=16
  particles.lifetime=0.4
  particles.spread=180.0
  particles.gravity=Vector2.ZERO
  particles.initial_velocity_min=50.0
  particles.initial_velocity_max=120.0
  particles.color=Color("fff0cf")
 elif kind=="spore":
  particles.texture=SPARK
  particles.amount=18
  particles.lifetime=0.6
  particles.spread=35.0
  particles.gravity=Vector2(0,-20)
  particles.initial_velocity_min=60.0
  particles.initial_velocity_max=180.0
  particles.color=Color("a9e4b5")
 elif kind=="gold":
  particles.texture=SPARK
  particles.amount=10+int(clampf(strength,0.0,1.0)*10)
  particles.lifetime=0.45
  particles.spread=180.0
  particles.gravity=Vector2(0,60)
  particles.initial_velocity_min=30.0
  particles.initial_velocity_max=110.0
  particles.color=Color("ffd76a")
 elif kind=="spawn":
  particles.texture=SPARK
  particles.amount=12
  particles.lifetime=0.3
  particles.spread=180.0
  particles.gravity=Vector2.ZERO
  particles.initial_velocity_min=40.0
  particles.initial_velocity_max=80.0
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
