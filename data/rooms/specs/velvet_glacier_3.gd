extends RefCounted
## Rectangle specs for data/rooms/velvet_glacier_3.txt (see tools/room_shapes.gd).
## World 4-3: a long gallery of ice where every landing comes in too fast.
static func rooms() -> Array:
 return [
  ["Y01",0,0,64,18,[["#",0,0,63,0],["#",0,1,0,11],["#",0,12,4,17],["i",5,12,19,12],["#",5,13,19,17],["^",20,16,39,16],["#",20,17,39,17],["o",29,9,29,9],["o",54,5,54,5],["i",40,12,59,12],["#",40,13,63,17],["<",60,8,60,11],["#",61,7,63,12],["#",60,12,60,12],["#",63,1,63,2],["P",2,11,2,11]],
   "Pod brake: the pit is too wide to jump. Pull across on the pod, land sliding on black ice that will not let you stop, and catch the second pod before the spiked wall."],
  ["Y02",64,-24,48,32,[["#",0,0,47,0],["#",0,1,0,4],["#",0,9,0,26],["#",0,31,47,31],["^",4,30,46,30],["P",2,30,2,30],["#",47,1,47,30],["c",8,26,9,26],["m",5,27,5,27],["c",37,18,41,18],["m",44,19,44,19],["#",1,9,12,9],["G",20,2,20,2]],
   "Blast stairs: two crumbling pads over spikes, each with a mine hanging beside it. Land, shoot the mine, and let it throw you across the room to the next pad; the second throws you back the other way, up to the ledge by the door."],
  ["Y03",20,-24,44,24,[["#",0,0,43,0],["#",0,1,0,23],["#",43,1,43,4],["#",1,7,8,7],["#",1,8,9,23],["b",9,1,9,6],["E",4,6,4,6],["w",29,2,29,2],["w",14,5,14,5],["^",10,22,29,22],["#",10,23,29,23],["i",30,9,43,9],["#",30,10,43,23],["m",29,14,29,14],["a",25,11,29,11],["P",41,8,41,8]],
   "Shield: the mine sits under a copper lid, and the gate alcove has a teal one. Swap to open the mine, leap out over the pit and blast off it, then swap back in the air to open the alcove."],
 ]
