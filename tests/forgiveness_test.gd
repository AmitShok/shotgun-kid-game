extends SceneTree
# Corner correction and ledge assist on purpose-built geometry, with each assist disabled as a control.
var failures := 0
var checks := 0
func _initialize() -> void: call_deferred("run")
func frames(count: int) -> void:
 for i in count: await physics_frame
func key(code: int, pressed: bool) -> void:
 var event := InputEventKey.new()
 event.device=0
 event.physical_keycode=code
 event.keycode=code
 event.pressed=pressed
 Input.parse_input_event(event)
 Input.flush_buffered_events()
func check(ok: bool, label: String) -> void:
 checks+=1
 if not ok:
  failures+=1
  push_error("Forgiveness failed: "+label)
func block(parent: Node, rect: Rect2) -> void:
 var body := StaticBody2D.new()
 var shape := CollisionShape2D.new()
 var box := RectangleShape2D.new()
 box.size=rect.size
 shape.shape=box
 body.position=rect.get_center()
 body.add_child(shape)
 parent.add_child(body)
func stage(build: Callable) -> CharacterBody2D:
 var world := Node2D.new()
 root.add_child(world)
 current_scene=world
 build.call(world)
 var player: CharacterBody2D=load("res://scenes/actors/player.tscn").instantiate()
 world.add_child(player)
 player.invincible=999
 return player
func ceiling(world: Node) -> void:
 block(world,Rect2(0,-50,100,20))
func ledge(world: Node) -> void:
 block(world,Rect2(20,0,100,100))
func run() -> void:
 # Head overlaps the ceiling's left corner by 2px (body is 12px wide, centred).
 for enabled in [true,false]:
  var player := stage(ceiling)
  player.corner_correction=4 if enabled else 0
  player.position=Vector2(-4,0)
  await frames(1)
  player.velocity=Vector2(0,-310)
  await frames(20)
  var cleared: bool = player.position.y< -45
  check(cleared==enabled,"ceiling corner clearance=%s with correction=%s" % [cleared,enabled])
  if enabled: check(player.position.x>-7.5,"nudge stays minimal (x=%.2f)" % player.position.x)
  current_scene.free()
 # Feet 3px below the ledge top while holding toward it.
 for enabled in [true,false]:
  var player := stage(ledge)
  player.ledge_assist=5 if enabled else 0
  player.position=Vector2(10,-7.5)
  await frames(1)
  key(KEY_D,true)
  player.velocity=Vector2(170,20)
  await frames(20)
  key(KEY_D,false)
  var on_top: bool = player.position.x>24 and player.position.y<0
  check(on_top==enabled,"ledge mount=%s with assist=%s" % [on_top,enabled])
  current_scene.free()
 print("FORGIVENESS RESULT: %d checks, %d failures" % [checks,failures])
 await root.get_node("Sfx").shutdown(1 if failures else 0)
