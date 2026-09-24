extends Node2D
var elapsed := 0.0
func _process(delta: float) -> void:
 elapsed+=delta
 $Ring.frame=mini(5,int(elapsed*18.0))
 $Ring.scale=Vector2.ONE*(1.0+elapsed*1.5)
 if elapsed>=0.4: queue_free()
