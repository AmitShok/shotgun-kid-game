extends SceneTree
var checks := 0
var failures := 0
var player: CharacterBody2D
func _initialize() -> void: call_deferred("run")
func frames(count: int) -> void:
 for i in count: await physics_frame
func key(code: int, pressed: bool) -> void:
 var event := InputEventKey.new()
 event.physical_keycode=code
 event.pressed=pressed
 Input.parse_input_event(event)
 Input.flush_buffered_events()
func check(ok: bool, label: String) -> void:
 checks+=1
 if ok: print("PASS: ",label)
 else:
  failures+=1
  push_error("FAIL: "+label)
func run() -> void:
 var level=load("res://scenes/levels/training_yard.tscn").instantiate()
 root.add_child(level)
 current_scene=level
 player=level.get_node("Player")
 var sound=root.get_node("Sfx")
 await frames(35)
 check(sound.sounds.size()==12 and sound.voices.size()==14,"All 12 sounds load into a bounded voice pool")
 for stream in sound.sounds.values(): check(stream.get_length()>0.04,"Audio sample has playable duration")
 key(KEY_D,true)
 await frames(22)
 check(player.velocity.x>=169,"Walking reaches new run speed quickly")
 check(int(sound.event_counts.get("step",0))>0,"Walking dispatches footstep audio")
 key(KEY_D,false)
 key(KEY_A,true)
 await frames(7)
 check(player.velocity.x<0,"Ground reversal responds within seven physics ticks")
 key(KEY_A,false)
 key(KEY_SPACE,true)
 await frames(3)
 check(int(sound.event_counts.get("jump",0))>0,"Normal jump dispatches jump audio")
 var steps: int=sound.event_counts.get("step",0)
 await frames(10)
 check(int(sound.event_counts.get("step",0))==steps,"Airborne movement does not play footsteps")
 key(KEY_SPACE,false)
 player.velocity=Vector2(170,-50)
 player.shotgun.aim=Vector2.DOWN
 player.shotgun.remaining=0
 player.shotgun.shoot()
 check(player.velocity.x>140 and player.velocity.y< -380,"Downward shot preserves lateral momentum")
 check(int(sound.event_counts.get("shot",0))>0,"Shot dispatches firing audio")
 check(player.get_node("Camera2D").shot_impact>1.0,"Shot triggers bounded camera impact")
 await frames(4)
 var camera=player.get_node("Camera2D")
 check(camera.zoom.x>=camera.minimum_landing_zoom*0.95 and camera.zoom.x<=1.04,"Zoom pulse stays within subtle limits")
 var saved_fx: bool=sound.camera_fx
 sound.set_camera_fx(false)
 camera.impact(3)
 await frames(3)
 check(camera.offset==Vector2.ZERO and camera.zoom.is_equal_approx(Vector2.ONE*camera.landing_zoom),"Camera effects can be disabled")
 sound.set_camera_fx(saved_fx)
 player.shotgun.ammo=0
 key(KEY_J,true)
 key(KEY_J,false)
 await frames(3)
 check(int(sound.event_counts.get("empty",0))>0,"Empty gun gives immediate audible feedback")
 player.shotgun.refill()
 check(int(sound.event_counts.get("reload",0))>0,"Ammo restoration dispatches reload audio")
 player.invincible=0
 player.hurt()
 check(int(sound.event_counts.get("respawn",0))>0,"Death dispatches respawn audio")
 var original_volume: float=sound.volume
 sound.set_volume(0.35)
 var config := ConfigFile.new()
 config.load(root.get_node("SaveData").path)
 check(is_equal_approx(float(config.get_value("audio","volume")),0.35),"Volume preference is saved")
 sound.set_volume(original_volume)
 check(not InputMap.has_action("mode") and root.get_node_or_null("Settings")==null,"Manual-only control preference remains intact")
 print("FEEL/AUDIO RESULT: %d checks, %d failures" % [checks,failures])
 await root.get_node("Sfx").shutdown(1 if failures else 0)

