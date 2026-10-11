extends SceneTree
const C=preload("res://scripts/wardrobe_catalog.gd")
var failures=0
func _initialize(): call_deferred("run")
func check(ok,label):
 print(("PASS " if ok else "FAIL ")+label)
 if not ok: failures+=1
func frames(n=5):
 for i in range(n): await process_frame
func fits(node):
 var r=node.get_global_rect()
 return r.position.x>=0 and r.position.y>=0 and r.end.x<=641 and r.end.y<=361
func shot(name):
 if DisplayServer.get_name()=="headless": return
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/wardrobe_"+name+".png")
func run():
 var save=root.get_node("SaveData")
 if save.path=="user://settings.cfg": quit(1);return
 save.crt_mode=0
 if "--read" in OS.get_cmdline_user_args():
  check(save.appearance=={"hats":"moon_wizard","scarves":"violet","outfits":"comet_suit"},"Appearance restored in fresh process")
  await root.get_node("Sfx").shutdown(failures);return
 save.set_appearance(C.DEFAULTS)
 var menu=load("res://scenes/ui/main_menu.tscn").instantiate();root.add_child(menu);current_scene=menu
 await frames(20)
 check(fits(menu.get_node("Center/Home")),"Home menu fits screen")
 menu._show_page("Wardrobe");await frames(20)
 var w=menu.get_node("Center/Wardrobe")
 check(fits(w),"Wardrobe fits screen")
 check(not w.preview.is_physics_processing() and not w.preview.is_processing_input(),"Preview ignores gameplay movement and input")
 check(get_nodes_in_group("player").is_empty(),"Preview excluded from gameplay player group")
 for category in C.DEFAULTS:
  w._select_category(category,false);await frames()
  check(w.cards.size()==(12 if category=="outfits" else 13),category+" card count")
  check(fits(w.cards.back()),category+" last card fits")
  w.cards[7].pressed.emit()
  check(save.appearance[category]==C.entries(category)[7].id,category+" equip from UI")
  await shot(category)
 var before=save.appearance.duplicate();save.equip("hats","invalid")
 check(before==save.appearance,"Invalid item rejected")
 var aligned=true
 var a=w.preview.get_node("Appearance")
 for category in C.DEFAULTS:
  for entry in C.entries(category):
   save.equip(category,entry.id)
   for frame in range(8):
    a.body.frame=frame;a.body.flip_h=frame%2==1;a._process(0)
    aligned=aligned and a.hat.frame==frame and a.neck.frame==frame and a.hat.flip_h==a.body.flip_h
 check(aligned,"Every cosmetic supports all animation frames and facings")
 check(not w.preview.get_node("Scarf").visible,"No scarf hides animated tail")
 save.set_appearance({"hats":"moon_wizard","scarves":"violet","outfits":"comet_suit"})
 menu.queue_free();await frames()
 var level=load("res://scenes/levels/training_yard.tscn").instantiate();root.add_child(level);current_scene=level
 await frames(20)
 check(get_nodes_in_group("player").size()==1,"Level has exactly one gameplay player")
 var player=level.get_node("Player")
 check(player.get_node("Sprite2D").texture==C.texture("outfits","comet_suit"),"Saved outfit applied in level")
 var hud=level.get_node("HUD")
 hud._toggle_pause();await frames(10)
 check(fits(hud.get_node("Overlay/Center/Menu")),"Pause menu fits screen")
 hud._open_wardrobe();await frames(15)
 check(paused and hud.get_node("Overlay/Center/Wardrobe").visible,"Wardrobe opens while paused")
 await shot("pause")
 hud._toggle_pause();check(paused,"Escape returns to pause")
 hud._toggle_pause();check(not paused,"Second escape resumes gameplay")
 save.clear_progress();check(save.appearance.hats=="moon_wizard","Restart keeps outfit")
 save.complete_level(level.scene_file_path)
 hud.show_completion(32,0);await frames(10)
 check(fits(hud.get_node("Overlay/Center/Menu")),"Completion menu fits screen")
 await shot("completion")
 print("WARDROBE FAILURES: ",failures)
 await root.get_node("Sfx").shutdown(failures)
