extends Node2D
const PHASE=preload("res://scripts/phase_block.gd")
@export var level_title := "LANTERN RIDGE"
@export var fall_limit_y := 720.0
@export var camera_bounds := Rect2(0,-160,2560,840)
@export var checkpoint_fall_distance := 0.0
## Track name in assets/music/. Empty picks the track named after this scene's file.
@export var music := ""
var deaths := 0
var elapsed := 0.0
var complete := false
# Room mode: the level is a chain of camera-locked rooms (children of a Rooms node).
var rooms: Array[Node] = []
var current_room: Node2D
func room_at(point: Vector2) -> Node2D:
	for room in rooms:
		if room.rect().has_point(point): return room
	return null
func _physics_process(_delta: float) -> void:
	if not rooms.is_empty() and $Player.dying<=0: _track_room(false)
func _track_room(initial: bool) -> void:
	var at: Vector2=$Player.global_position
	var room := room_at(at)
	if room and room!=current_room:
		_enter_room(room,initial)
	elif room==null and current_room and at.y>current_room.rect().end.y+8:
		# Fell out of the bottom of the room with no room below: that's a death.
		$Player.hurt()
func _enter_room(room: Node2D,initial: bool) -> void:
	current_room=room
	# Every room starts with copper phase plates solid, the same state its respawn uses.
	PHASE.set_phase(get_tree(),0)
	get_tree().call_group("crumble_blocks","reset")
	get_tree().call_group("wind_zones","reset")
	var camera: Camera2D=$Player/Camera2D
	var bounds: Rect2=room.rect()
	camera.limit_left=int(bounds.position.x)
	camera.limit_top=int(bounds.position.y)
	camera.limit_right=int(bounds.end.x)
	camera.limit_bottom=int(bounds.end.y)
	$Player.spawn_point=room.spawn_point()
	if initial:
		camera.reset_smoothing()
		return
	# Progress is saved at each room's entrance. Shells are NOT refilled here: crossing a room
	# edge mid-air must not grant free shots (landing refills as usual).
	SaveData.save_checkpoint(room,room.spawn_point())
func _ready() -> void:
	var camera: Camera2D=$Player/Camera2D
	camera.limit_left=int(camera_bounds.position.x)
	camera.limit_top=int(camera_bounds.position.y)
	camera.limit_right=int(camera_bounds.end.x)
	camera.limit_bottom=int(camera_bounds.end.y)
	$Player.fall_limit_y=fall_limit_y
	_scatter_terrain()
	# Entering any level counts as starting the game: the menu offers Continue from now on.
	SaveData.mark_started()
	$Player.died.connect(_on_player_died)
	PHASE.set_phase(get_tree(),0)
	get_tree().call_group("crumble_blocks","reset")
	get_tree().call_group("wind_zones","reset")
	var track := music
	if track.is_empty(): track="lantern_ridge" if scene_file_path.get_file()=="training_yard.tscn" else scene_file_path.get_file().get_basename()
	Sfx.play_music(track)
	if has_node("Rooms"):
		rooms=$Rooms.get_children()
		camera.room_mode=true
		camera.limit_smoothed=true
		# Resume in a saved room, otherwise start wherever the player was placed.
		var start: Node2D=null
		if SaveData.level_path==scene_file_path:
			for room in rooms:
				if String(room.name)==SaveData.checkpoint: start=room
		if start:
			$Player.spawn_point=start.spawn_point()
			$Player.respawn()
		_track_room(true)
		return
	if SaveData.level_path==scene_file_path:
		# Resolve only known flags; never trust an arbitrary node path or coordinates from disk.
		for flag in get_children():
			if flag.get_script()==preload("res://scripts/checkpoint.gd") and String(flag.name)==SaveData.checkpoint:
				$Player.spawn_point=flag.global_position+Vector2(0,-14)
				$Player.respawn()
				flag.activated=true
				flag.get_node("Sprite2D").modulate=Color("ffda92")
				break
# Painted scenes cycle a few atlas columns, which reads as an obvious repeat. Re-pick each
# solid cell's column (top, fill and bottom rows share collision) from a hash of its position,
# so the layout stays stable run to run. Row 3 decorations are placed by hand and are left alone.
const INTERIOR_COLUMNS := [1,2,3,5,6,7]
func _scatter_terrain() -> void:
	if not has_node("Terrain"): return
	for layer in $Terrain.get_children():
		if not layer is TileMapLayer: continue
		for cell in layer.get_used_cells():
			var coords: Vector2i=layer.get_cell_atlas_coords(cell)
			# Columns 0 and 4 are left/right edge caps in the Lantern Ridge atlas; keep them in place.
			if coords.y<0 or coords.y>2 or coords.x==0 or coords.x==4: continue
			var hashed: int=INTERIOR_COLUMNS[absi((cell.x*73856093)^(cell.y*19349663))%INTERIOR_COLUMNS.size()]
			layer.set_cell(cell,layer.get_cell_source_id(cell),Vector2i(hashed,coords.y),layer.get_cell_alternative_tile(cell))
func _on_player_died() -> void:
	deaths+=1
	for mine in get_tree().get_nodes_in_group("boost_mines"): mine.reset()
	for pickup in get_tree().get_nodes_in_group("shell_pickups"): pickup.reset()
	get_tree().call_group("golden_shells","drop")
	get_tree().call_group("spore_pods","reset")
	PHASE.set_phase(get_tree(),0)
	get_tree().call_group("crumble_blocks","reset")
	get_tree().call_group("wind_zones","reset")
func _process(delta: float) -> void:
	if checkpoint_fall_distance>0:
		$Player.fall_limit_y=minf(fall_limit_y,$Player.spawn_point.y+checkpoint_fall_distance)
	if not complete and not get_tree().paused: elapsed+=delta
func checkpoint_reached() -> void:
	Sfx.play("checkpoint",-7.0)
func finish() -> void:
	if complete: return
	complete=true
	get_tree().call_group("golden_shells","bank")
	SaveData.complete_level(scene_file_path)
	var improved := SaveData.record_run(scene_file_path,elapsed,deaths)
	Sfx.play("clear",-5.0)
	$HUD.show_completion(elapsed,deaths,improved)
