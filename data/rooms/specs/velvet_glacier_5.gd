extends RefCounted
## Rectangle specs for data/rooms/velvet_glacier_5.txt (see tools/room_shapes.gd).
## World 4-5: the heart of the glacier, where every mechanic of the world has to be used in turn.
static func rooms() -> Array:
 return [
  ["H01",60,0,48,16,_return_trip(),
   "Return trip: the door home is copper and the switch is across a crumbling bridge. Cross, shoot the switch, wait for the bridge to grow back, and walk home under the teal ceiling the switch brings down."],
  ["H02",36,6,24,40,[["#",0,0,23,0],["#",23,5,23,39],["#",18,5,22,5],["#",0,1,0,20],["#",0,25,0,39],["#",1,20,3,20],["#",1,25,3,25],["a",4,20,4,25],["a",1,21,1,24],["o",2,22,2,22],["w",16,10,16,10],["^",1,38,22,38],["#",1,39,22,39],["P",20,4,20,4]],
   "Glass pod: drop down the shaft past a pod sealed behind copper. Shoot the switch as you fall to open the pane, then catch the pod and let it pull you out through the side tunnel."],
  ["H03",0,14,36,24,[["#",0,0,35,0],["#",0,1,0,23],["#",35,1,35,12],["#",35,17,35,23],["#",1,5,5,5],["E",3,4,3,4],["i",26,17,34,17],["#",26,18,34,23],["^",1,22,25,22],["#",1,23,25,23],["c",14,19,19,19],["m",17,21,17,21],["P",32,16,32,16]],
   "Cracked heart: the pod throws you onto a crumbling island in the middle of the pit. Let it break; the mine hidden under it is your way up to the gate."],
 ]

## A bridge of separate two-tile crumbles over spikes, with a teal ceiling that only closes on the way back.
static func _return_trip() -> Array:
 var r: Array = [["#",0,0,47,0],["#",0,1,0,6],["a",0,7,0,10],["#",0,11,5,15],["#",38,11,47,15],["#",47,1,47,10],["^",6,14,37,14],["#",6,15,37,15],["w",45,6,45,6],["G",22,4,22,4],["b",6,8,37,8],["P",3,10,3,10]]
 for x in range(6,38,2): r.append(["c" if x%4==2 else "k",x,11,x+1,11])
 return r
