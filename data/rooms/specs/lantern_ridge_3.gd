extends RefCounted
## Rectangle specs for data/rooms/lantern_ridge_3.txt (see tools/room_shapes.gd).
## World 1-3: spiked ceilings cap every arc, so shells have to be spent flat, low and in order.
static func rooms() -> Array:
 return [
  ["B01",0,0,60,23,[["#",0,0,0,18],["#",0,19,7,22],["#",8,22,49,22],["^",8,21,49,21],["#",6,0,49,13],["v",6,14,49,14],["#",50,19,59,22],["s",31,16,31,16],["P",3,18,3,18]],
   "A spiked ceiling hangs low over the pit: no jumping high. Jump off the edge, kick flat at once, then kick low twice, catching the shell."],
  ["B02",60,-23,40,46,[["#",0,0,0,38],["#",1,0,33,4],["v",1,5,33,5],["#",0,42,33,45],["#",34,13,39,45],["#",18,32,25,33],["v",18,34,25,34],["#",4,23,11,24],["v",4,25,11,25],["s",19,16,19,16],["P",3,41,3,41]],
   "Climb the eaved shaft: each ledge is just beyond a jump and one shot, and spikes hang under them. Kick across to the top of the wall."],
  ["B04",100,-19,40,23,[["#",0,9,39,22],["#",14,0,19,3],["#",22,0,26,3],["#",20,0,21,0],["v",14,4,19,4],["v",22,4,26,4],["G",20,2,20,2],["^",28,8,31,8],["P",3,8,3,8]],
   "A breather. The golden shell sits in a notch in the spiked ceiling: jump and pop straight up into it."],
  ["B05",140,-37,40,46,[["#",0,27,5,45],["#",6,45,39,45],["^",6,44,29,44],["#",30,8,39,44],["#",6,0,39,1],["m",9,30,9,30],["s",20,4,20,4],["#",39,2,39,7],["E",35,7,35,7],["P",2,26,2,26]],
   "Mine elevator: blast straight up off the mine, then kick across to the top of the wall. The shell makes it easy; a flat kick before the mine is the expert line."],
 ]
