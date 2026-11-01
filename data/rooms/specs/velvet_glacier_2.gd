extends RefCounted
## Rectangle specs for data/rooms/velvet_glacier_2.txt (see tools/room_shapes.gd).
## World 4-2: ice that breaks under you, pods to hop between it, and a gate you slide through.
static func rooms() -> Array:
 return [
  ["X01",0,0,60,23,[["#",0,0,59,0],["#",0,1,0,18],["#",0,19,5,22],["#",6,22,49,22],["^",6,21,49,21],["c",13,19,17,19],["o",15,17,15,17],["c",25,19,29,19],["o",27,17,27,17],["c",37,19,41,19],["o",39,17,39,17],["#",50,19,59,22],["o",52,17,52,17],["P",2,18,2,18]],
   "Crumble hops: each pad of crumbling ice has a pod on it. Pull onto a pad, then pull on to the next before it shatters under you."],
  ["X02",60,2,40,46,_thin_ice(),
   "Thin ice: every floor is loose crumbling tiles. Keep running and they hold; stop, and the tiles under you give way. Stop over the side without spikes below."],
  ["X03",100,38,50,14,[["#",0,0,49,0],["#",0,1,0,5],["#",0,9,3,13],["i",4,9,29,9],["#",4,10,29,13],["a",18,1,18,8],["w",14,4,14,4],["a",30,9,41,9],["^",30,12,41,12],["#",30,13,41,13],["#",42,9,49,13],["#",49,1,49,8],["G",36,2,36,2],["E",46,8,46,8],["P",2,8,2,8]],
   "Slide gate: one switch works both the gate and the bridge. Open the gate and slide through, then shoot the switch behind you to bring the bridge back before the ice carries you into the pit."],
 ]

## Three floors of separate two-tile crumbles; the floor below each has spikes on one half.
static func _thin_ice() -> Array:
 var r: Array = [["#",0,0,39,0],["#",0,1,0,14],["#",0,18,0,45],["#",39,1,39,41],["#",0,17,2,17],["P",1,16,1,16]]
 for x in range(3,39,2): r.append(["c" if x%4==3 else "k",x,17,x+1,17])
 for x in range(1,39,2): r.append(["c" if x%4==1 else "k",x,27,x+1,27])
 r.append(["^",1,26,18,26])
 for x in range(1,39,2): r.append(["c" if x%4==1 else "k",x,37,x+1,37])
 r.append(["^",17,36,38,36])
 r.append_array([["#",1,45,38,45],["^",1,44,14,44]])
 return r
