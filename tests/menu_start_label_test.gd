extends SceneTree
## The title screen's first button says Play on a fresh or reset save, and Continue once the
## player has entered a level. Run twice with the same fresh profile:
##   godot --headless --path . --script res://tests/menu_start_label_test.gd -- --save-file=user://start_label.cfg
##   godot --headless --path . --script res://tests/menu_start_label_test.gd -- --save-file=user://start_label.cfg --read
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool,label: String) -> void:
 print(("PASS " if ok else "FAIL ")+label)
 if not ok: failures+=1
func frames(n: int) -> void:
 for i in n: await process_frame
func label() -> String:
 return current_scene.get_node("Center/Home/Start").text
func open_menu() -> void:
 change_scene_to_file("res://scenes/ui/main_menu.tscn")
 await frames(4)
func run() -> void:
 var data=root.get_node("SaveData")
 if data.path=="user://settings.cfg":
  quit(1)
  return
 if "--read" in OS.get_cmdline_user_args():
  await open_menu()
  check(label()=="Play","After a reset and a restart the menu still says Play")
  # A save from before the started flag, with cleared levels, counts as started.
  data.completed.append(data.CATALOG.levels[0].scene_path)
  data.started=false
  data.save()
  var legacy := ConfigFile.new()
  legacy.load(data.path)
  legacy.erase_section_key("progress","started")
  legacy.save(data.path)
  data.completed.clear()
  data._ready()
  check(data.started,"An older save with progress counts as started")
  data.reset_progress()
 else:
  data.reset_progress()
  await open_menu()
  check(label()=="Play","A fresh save says Play")
  # Entering the first level, without finishing it, counts as starting.
  change_scene_to_file(data.CATALOG.levels[0].scene_path)
  await frames(6)
  check(data.started,"Entering a level marks the game as started")
  await open_menu()
  check(label()=="Continue","After entering a level the menu says Continue")
  # Reset from the options page: the label flips back straight away.
  current_scene._show_page("Options")
  current_scene.get_node("Center/Options")._reset_progress()
  await frames(2)
  current_scene._show_page("Home")
  await frames(2)
  check(label()=="Play","Resetting progress turns Continue back into Play at once")
 print("START LABEL FAILURES: ",failures)
 quit(1 if failures else 0)
