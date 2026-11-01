extends RefCounted
## Rectangle specs for data/rooms/copper_cloud_2.txt (see tools/room_shapes.gd).
## World 3-2: phase swaps that unlock the ridge's and the comet's tools - bridges, pods and mines.
static func rooms() -> Array:
 return [
  ["N01",0,0,40,23,[["#",0,0,39,1],["#",0,2,0,18],["#",0,19,9,22],["#",10,22,31,22],["^",10,21,31,21],["b",13,19,31,19],["#",32,19,39,22],["a",33,2,34,18],["w",5,14,5,14],["P",3,18,3,18]],
   "Jump off the ledge and shoot the switch behind you: the kick carries you on, a teal bridge appears under you and the copper gate opens."],
  ["N02",40,0,40,23,[["#",0,0,39,1],["#",0,19,7,22],["#",8,22,29,22],["^",8,21,29,21],["a",10,2,11,20],["o",16,9,16,9],["#",30,8,39,22],["w",3,12,3,12],["P",2,18,2,18]],
   "The pod is behind a copper wall: shoot the switch overhead to turn the wall hollow, then grab the pod and swing up to the high ledge."],
  ["N03",80,-11,40,34,[["#",0,0,39,1],["#",0,19,7,33],["#",8,30,23,33],["#",24,12,39,33],["a",16,25,20,25],["a",16,26,16,29],["a",20,26,20,29],["m",18,28,18,28],["w",11,23,11,23],["P",3,18,3,18]],
   "The mine is caged in copper. Swap to open the cage, hop over it and shoot the mine from above to launch onto the tall wall."],
  ["N04",120,-18,40,23,[["#",0,0,39,1],["#",0,19,39,22],["a",18,7,22,7],["a",18,8,18,12],["a",22,8,22,12],["a",19,12,21,12],["G",20,10,20,10],["w",11,13,11,13],["#",39,2,39,18],["E",36,18,36,18],["P",3,18,3,18]],
   "A breather before the gate. The golden shell is locked in a copper cage: swap to open it, then jump and pop up into it."],
 ]
