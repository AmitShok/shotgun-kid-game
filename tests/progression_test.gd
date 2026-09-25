extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool,label: String) -> void:
 print(("PASS " if ok else "FAIL ")+label)
 if not ok: failures+=1
func frames(n: int) -> void:
 for i in n: await physics_frame
func capture(name: String) -> void:
 if DisplayServer.get_name()=="headless": return
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/"+name+".png")
func open_scene(path: String) -> void:
 change_scene_to_file(path)
 await scene_changed
 await frames(4)
func run() -> void:
 var data=root.get_node("SaveData")
 if data.path=="user://settings.cfg":
  quit(1)
  return
 var args=OS.get_cmdline_user_args()
 if "--read" in args:
  check(data.completed_count==5,"All five completions survive a new process")
  check(data.is_level_unlocked(data.CATALOG.levels[4].scene_path),"Last level remains unlocked after relaunch")
  await open_scene(data.CATALOG.levels[2].scene_path)
  current_scene.get_node("Checkpoint0")._on_body_entered(current_scene.get_node("Player"))
  current_scene.get_node("HUD")._restart()
  await scene_changed
  check(data.completed_count==5 and data.checkpoint=="","Restart clears only checkpoint, keeping unlocks")
  current_scene.get_node("Checkpoint0")._on_body_entered(current_scene.get_node("Player"))
  var panel=current_scene.get_node("HUD/Overlay/Center/Options")
  current_scene.get_node("HUD")._toggle_pause()
  current_scene.get_node("HUD")._open_options()
  panel.get_node("ResetProgress").pressed.emit()
  check(panel.get_node("ResetConfirmation").visible,"Reset offers an explicit confirmation")
  panel.get_node("ResetConfirmation").hide()
  check(data.completed_count==5,"Cancelling reset preserves progress")
  panel.get_node("ResetConfirmation").confirmed.emit()
  await scene_changed
  check(current_scene.has_node("Center/Home") and not paused,"Reset during play returns to main menu")
  check(data.completed_count==0 and data.checkpoint=="","Reset clears completion and checkpoint progress")
  check(not data.crt_filter,"Reset preserves preferences")
 elif "--reset-read" in args:
  check(data.completed_count==0 and not data.is_level_unlocked(data.CATALOG.levels[1].scene_path),"Reset remains locked after another launch")
  check(not data.crt_filter,"Preferences survive reset and relaunch")
 else:
  data.reset_progress()
  data.set_preference("crt_filter",false)
  await open_scene("res://scenes/ui/main_menu.tscn")
  var menu=current_scene
  menu._show_page("Levels")
  check(menu.levels.size()==5,"Five levels registered in one shared catalog")
  check(not menu.get_node("Center/Levels/List").get_child(0).disabled,"First level starts unlocked")
  for i in range(1,5): check(menu.get_node("Center/Levels/List").get_child(i).disabled,"Level %d starts locked" % (i+1))
  menu._start_level(data.CATALOG.levels[4].scene_path)
  await process_frame
  check(current_scene==menu,"Direct menu request cannot bypass the lock")
  data.complete_level(data.CATALOG.levels[4].scene_path)
  check(data.completed_count==0,"Out-of-order finishes cannot skip progression")
  await capture("level_select_progression")
  menu._show_page("Options")
  await process_frame
  check(menu.get_node("Center/Options").size.y<=360,"Options including Reset fit the viewport")
  await capture("options_progression")
  menu._start_level(data.CATALOG.levels[0].scene_path)
  await scene_changed
  for i in range(5):
   var level=current_scene
   var player=level.get_node("Player")
   await frames(20)
   check(player.is_on_floor(),"Level %d has safe playable spawn" % (i+1))
   if i>0:
    check(level.has_node("Backdrop/Snow") and level.has_node("Backdrop/Far/Plane2"),"Placeholder keeps complete ridge background")
    check(level.has_node("Terrain/Ground") and level.has_node("Checkpoint0") and level.has_node("Exit") and level.has_node("Mines") and level.has_node("Hazards"),"Placeholder has required editable structure")
    check(level.get_node("Scenery").get_child_count()==0 and level.get_node("Terrain").get_child_count()==1,"Placeholder leaves level design empty except test floor")
   if i==1: await capture("level_template")
   player.position=level.get_node("Exit").position-Vector2(0,10)
   player.velocity=Vector2.ZERO
   await frames(6)
   check(level.complete and paused,"Reaching level %d door completes it" % (i+1))
   check(data.completed_count==i+1,"Exit saves exactly one campaign step")
   data.complete_level(level.scene_file_path)
   check(data.completed_count==i+1,"Repeated completion does not skip levels")
   var next=level.get_node("HUD/Overlay/Center/Menu/NextLevel")
   if i<4:
    check(next.visible and data.is_level_unlocked(data.CATALOG.levels[i+1].scene_path),"Next level unlocks and continuation appears")
    next.pressed.emit()
    await scene_changed
   else:
    check(not next.visible,"Last level offers no nonexistent next level")
  paused=false
 print("PROGRESSION FAILURES: ",failures)
 await root.get_node("Sfx").shutdown(1 if failures else 0)
