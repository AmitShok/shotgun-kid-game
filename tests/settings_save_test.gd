extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool,label: String) -> void:
 print(("PASS " if ok else "FAIL ")+label)
 if not ok: failures+=1
func run() -> void:
 var data=root.get_node("SaveData")
 if data.path=="user://settings.cfg":
  push_error("Use -- --save-file=user://options_test.cfg to protect player data")
  quit(1)
  return
 var sound=root.get_node("Sfx")
 var args=OS.get_cmdline_user_args()
 var scene=load("res://scenes/levels/training_yard.tscn").instantiate()
 root.add_child(scene)
 current_scene=scene
 await process_frame
 var hud=scene.get_node("HUD")
 var player=scene.get_node("Player")
 if "--write" in args:
  data.clear_progress()
  hud._toggle_pause()
  hud.get_node("Overlay/Center/Menu/Options").pressed.emit()
  check(hud.get_node("Overlay/Center/Options").visible and paused,"Options opens while paused")
  hud.get_node("Overlay/Center/Options/VolumeRow/Volume").value=30
  hud.get_node("Overlay/Center/Options/CameraZoom").button_pressed=false
  hud.get_node("Overlay/Center/Options/CRT/Preset").select(0)
  hud.get_node("Overlay/Center/Options/CRT/Preset").item_selected.emit(0)
  hud.get_node("Overlay/Center/Options/CameraShake").button_pressed=true
  hud.get_node("Overlay/Center/Options/ShotShake").button_pressed=false
  hud.get_node("Overlay/Center/Options/MineShake").button_pressed=true
  for name in ["Controls","LevelHints","HUD"]:
   hud.get_node("Overlay/Center/Options/"+name).button_pressed=false
  check(not hud.get_node("Bottom").visible and not scene.get_node("Signs").visible and not hud.get_node("Top").visible,"All gameplay text can be hidden")
  if DisplayServer.get_name()!="headless":
   await process_frame
   await RenderingServer.frame_post_draw
   root.get_texture().get_image().save_png("res://docs/options_menu.png")
  hud._toggle_pause()
  check(paused and hud.get_node("Overlay/Center/Menu").visible,"Escape returns to pause menu")
  if DisplayServer.get_name()!="headless":
   await process_frame
   await RenderingServer.frame_post_draw
   root.get_texture().get_image().save_png("res://docs/pause_menu.png")
  hud._toggle_pause()
  check(not paused,"Escape resumes")
  scene.get_node("Checkpoint1")._on_body_entered(player)
  check(data.checkpoint=="Checkpoint1","Checkpoint is saved on contact")
 elif "--read" in args:
  check(is_equal_approx(sound.volume,0.3) and not data.camera_zoom,"Audio and camera preferences survive a new process")
  check(not data.crt_filter and not root.get_node("CRTOverlay/Filter").visible,"CRT off persists across launches")
  check(data.camera_shake and not data.shot_shake and data.mine_shake and not data.camera_zoom,"Independent camera switches persist")
  check(not data.show_controls and not data.show_level_hints and not data.show_hud,"Text preferences survive a new process")
  check(player.spawn_point==scene.get_node("Checkpoint1").position+Vector2(0,-14),"New process restores saved checkpoint")
  check(not hud.get_node("Bottom").visible and not scene.get_node("Signs").visible,"Loaded preferences apply to scene")
  hud._restart()
  await process_frame
  await process_frame
  check(data.checkpoint=="" and current_scene.get_node("Player").spawn_point.x==88,"Restart clears saved checkpoint and starts at beginning")
  check(not data.show_controls and is_equal_approx(sound.volume,0.3),"Restart keeps settings")
 else:
  check(data.checkpoint=="" and player.spawn_point.x==88,"Restart remains cleared after another launch")
  check(not data.show_controls and is_equal_approx(sound.volume,0.3),"Settings remain saved after restart and relaunch")
 print("SAVE TEST FAILURES: ",failures)
 if failures:
  await sound.shutdown(1)
 else:
  hud= current_scene.get_node("HUD")
  hud.get_node("Overlay/Center/Menu/Quit").pressed.emit()
