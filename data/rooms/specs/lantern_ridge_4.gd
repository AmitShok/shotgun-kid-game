extends RefCounted
## Rectangle specs for data/rooms/lantern_ridge_4.txt (see tools/room_shapes.gd).
## World 1-4: a climb through spike-lined shafts, where mines are the only way up.
static func rooms() -> Array:
 return [
  ["C01",0,-23,40,46,[["#",0,0,0,41],["#",0,42,39,45],["#",8,10,9,38],[">",10,10,10,38],["#",20,10,39,41],["<",19,10,19,41],["m",15,40,15,40],["m",15,22,15,22],["P",3,41,3,41]],
   "The mine ladder: blast up the spiked chimney off the first mine, then shoot the second as you rise past it."],
  ["C02",40,-53,40,46,[["#",0,0,39,0],["#",0,40,9,45],["#",9,1,9,30],[">",10,6,10,30],["#",10,45,22,45],["^",10,44,22,44],["#",23,10,39,45],["<",22,12,22,43],["s",15,33,15,33],["s",16,27,16,27],["s",15,21,15,21],["s",16,15,16,15],["s",17,10,17,10],["P",3,39,3,39]],
   "The shell ladder: no ledges in this shaft, only floating shells. Pop straight up, catch the shell above, pop again - all the way to the top."],
  ["C03",80,-53,40,23,[["#",0,10,5,22],["#",6,22,39,22],["^",6,21,13,21],["^",19,21,33,21],["#",14,17,18,21],["#",34,13,39,22],["#",6,0,33,2],["v",6,3,33,3],["G",24,17,24,17],["P",2,9,2,9]],
   "Jump down to the island, then kick up to the far ledge. The golden shell hangs low over the spikes beyond."],
  ["C04",120,-76,40,46,[["#",0,36,5,45],["#",0,0,0,32],[">",1,8,1,32],["#",6,45,33,45],["^",6,44,33,44],["#",1,0,39,1],["v",8,2,33,2],["#",34,6,39,45],["<",33,10,33,43],["m",10,40,10,40],["s",22,7,22,7],["#",39,2,39,5],["E",37,5,37,5],["P",2,35,2,35]],
   "The spire: blast up off the mine between the spiked walls, then kick across, catching the shell, onto the top of the wall."],
 ]
