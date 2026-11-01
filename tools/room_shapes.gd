extends SceneTree
## Helper for authoring room text: turns rectangle specs into exact-width rows.
##   godot --headless --script res://tools/room_shapes.gd -- <spec.gd>
## A spec script defines `static func rooms() -> Array` returning
## [name, col, row, width, height, [[char, x0, y0, x1, y1], ...], comment].
func _initialize() -> void:
 var spec_path := ""
 for arg in OS.get_cmdline_user_args(): spec_path=arg
 var spec: Script=load(spec_path)
 var out := ""
 for room in spec.rooms():
  var g: Array = []
  for y in room[4]:
   var row := PackedStringArray()
   for x in room[3]: row.append(".")
   g.append(row)
  for f in room[5]:
   for y in range(f[2],f[4]+1):
    for x in range(f[1],f[3]+1): g[y][x]=f[0]
  out+="; %s — %s\n@room %s %d %d\n" % [room[0],room[6],room[0],room[1],room[2]]
  for row in g: out+="".join(row)+"\n"
  out+="\n"
 print(out)
 quit()
