extends RefCounted
## Reads data/rooms/<map>.txt: room tile grids for tools/build_rooms.gd and verified input
## routes for tests/room_routes_test.gd.
##
## "@room NAME COL ROW" starts a room whose top-left tile is (COL, ROW); its rows follow.
## "@route FROM TO" starts an input route that must carry the player from FROM's respawn point
## into room TO (or "exit"). Each route line is "FRAMES action action ...", holding those
## actions for that many physics frames. Actions: left right jump fire aim_left aim_right
## aim_up aim_down. Lines starting with ";" are comments.
## "@skipcheck FROM TO without=shells,mines [dir=left] [jump=timed]" declares that FROM must NOT be clearable into TO
## (jump=timed also tries jumps at fixed delays, for rooms that start against a wall, not a ledge edge)
## once those items are removed; tests/room_routes_test.gd brute-forces jump and shot timings
## and aims to prove it, so a required pickup or mine can never quietly become optional.
const LEVELS := {
 "lantern_ridge":"res://scenes/levels/training_yard.tscn",
 "mossy_comet":"res://scenes/levels/mossy_comet.tscn",
 "copper_cloud":"res://scenes/levels/copper_cloud.tscn",
 "velvet_glacier":"res://scenes/levels/velvet_glacier.tscn",
 "echo_orchard":"res://scenes/levels/echo_orchard.tscn"}
# Later levels of a world live at scenes/levels/<map>.tscn, e.g. "mossy_comet_3".
static func scene_for(map_name: String) -> String:
 return LEVELS.get(map_name,"res://scenes/levels/%s.tscn" % map_name)
# The biome a map belongs to: "mossy_comet_3" -> "mossy_comet".
static func biome(map_name: String) -> String:
 var parts := map_name.split("_")
 return "_".join(parts.slice(0,-1)) if parts[-1].is_valid_int() else map_name
static func load_map(map_name: String) -> Dictionary:
 var rooms: Array = []
 var routes: Array = []
 var skipchecks: Array = []
 var current: Dictionary = {}
 var kind := ""
 for raw in FileAccess.get_file_as_string("res://data/rooms/%s.txt" % map_name).split("\n"):
  var line := raw.strip_edges(false,true)
  if line.begins_with(";"): continue
  if line.begins_with("@"):
   var parts := line.split(" ",false)
   kind=parts[0]
   if kind=="@room":
    current={"name":parts[1],"origin":Vector2i(int(parts[2]),int(parts[3])),"rows":[]}
    rooms.append(current)
   elif kind=="@route":
    current={"from":parts[1],"to":parts[2],"steps":[]}
    routes.append(current)
   elif kind=="@skipcheck":
    var without: Array = []
    var direction := "right"
    for part in parts.slice(3):
     if part.begins_with("without="): without=Array(part.trim_prefix("without=").split(","))
     if part.begins_with("dir="): direction=part.trim_prefix("dir=")
    skipchecks.append({"from":parts[1],"to":parts[2],"without":without,"dir":direction,"timed":"jump=timed" in parts})
   continue
  if line.strip_edges().is_empty(): continue
  if kind=="@room": current.rows.append(line)
  elif kind=="@route":
   var parts := line.strip_edges().split(" ",false)
   current.steps.append({"frames":int(parts[0]),"actions":parts.slice(1)})
 for room in rooms:
  var width := 0
  for row in room.rows: width=maxi(width,row.length())
  room["size"]=Vector2i(width,room.rows.size())
 return {"rooms":rooms,"routes":routes,"skipchecks":skipchecks}
