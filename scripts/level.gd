extends Node2D
var deaths := 0
var elapsed := 0.0
var complete := false
func _ready() -> void:
 $Player.died.connect(_on_player_died)
func _on_player_died() -> void:
 deaths+=1
 for mine in get_tree().get_nodes_in_group("boost_mines"): mine.reset()
func _process(delta: float) -> void:
 if not complete and not get_tree().paused: elapsed+=delta
func checkpoint_reached() -> void:
 $HUD.show_message("CHECKPOINT SAVED  /  take another run whenever you need")
func finish() -> void:
 if complete: return
 complete=true
 $HUD.show_completion(elapsed,deaths)
