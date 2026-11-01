extends RefCounted
## Rectangle specs for data/rooms/mossy_comet_4.txt (see tools/room_shapes.gd).
## World 2-4: climbing out of the crater - mines launch you, pods steer you, spiked walls punish drift.
static func rooms() -> Array:
 return [
  ["J01",0,-60,40,46,[["#",0,0,39,0],["#",0,1,0,45],["#",39,1,39,41],[">",1,10,1,40],["<",38,10,38,30],["#",1,7,8,8],["#",16,17,26,18],["u",18,16,18,16],["#",27,17,28,32],["<",26,19,26,32],["#",2,27,12,28],["u",8,26,8,26],["#",16,37,34,38],["u",19,36,19,36],["#",1,45,39,45],["^",1,44,34,44],["P",3,6,3,6]],
   "Into the crater: hop down from ledge to ledge by pulling yourself onto the pod waiting on each one, past the spiked crater walls."],
  ["J02",40,-46,60,46,[["#",0,31,14,45],["#",15,45,43,45],["^",15,44,43,44],["#",15,0,43,9],["v",15,10,43,10],["o",23,20,23,20],["o",39,15,39,15],["#",44,16,59,45],["#",0,0,14,0],["P",3,30,3,30]],
   "Pull up-right, then shoot the far pod flat right before the spiked ceiling catches you."],
  ["J03",100,-46,40,23,[["#",0,16,13,22],["#",14,22,25,22],["^",14,21,25,21],["#",26,16,39,22],["G",16,18,16,18],["P",3,15,3,15]],
   "A breather on the crater rim. The golden shell hangs low in the pit: drop for it and kick back up to the ledge."],
  ["J04",140,-72,40,46,[["#",0,42,25,45],["#",0,8,0,38],[">",1,10,1,38],["#",26,0,39,45],["<",25,4,25,41],["o",12,27,12,27],["o",12,14,12,14],["m",16,3,16,3],["P",3,41,3,41]],
   "Pod into mine: pull straight up through two pods, and at the top of the slingshot shoot the mine below you - the blast throws you up and out over the top-left lip."],
  ["J05",100,-90,40,23,[["#",0,20,39,22],["#",0,0,39,0],["#",0,1,0,19],["#",12,1,22,15],["v",12,16,22,16],["E",3,19,3,19],["P",34,19,34,19]],
   "Out of the crater: run back left under the spiked overhang to the gate."],
 ]
