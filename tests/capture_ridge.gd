extends SceneTree
func _initialize() -> void: call_deferred("run")
func frames(count: int) -> void:
 for i in count: await physics_frame
func run() -> void:
 var level=load("res://scenes/levels/training_yard.tscn").instantiate()
 root.add_child(level)
 current_scene=level
 await frames(60)
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/lantern_ridge.png")
 var player=level.get_node("Player")
 player.position=Vector2(1000,430)
 player.get_node("Camera2D").reset_smoothing()
 await frames(45)
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/high_road.png")
 player.position=Vector2(1100,355)
 player.velocity=Vector2.ZERO
 player.set_physics_process(false)
 player.shotgun.aim=Vector2.DOWN
 player.shotgun.shoot()
 await frames(6)
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/mine_blast.png")
 quit()
