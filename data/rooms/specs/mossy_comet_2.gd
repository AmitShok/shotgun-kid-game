extends RefCounted
## Rectangle specs for data/rooms/mossy_comet_2.txt (see tools/room_shapes.gd).
## World 2-2: spore pods mixed with the ridge's mines and shells.
static func rooms() -> Array:
 return [
  ["G01",0,0,40,23,[["#",0,0,0,18],["#",0,19,7,22],["#",8,22,33,22],["^",8,21,33,21],["#",34,8,39,22],["o",17,8,17,8],["P",3,18,3,18]],
   "The ledge is too high and too far: shoot the pod up-right from the edge and ride the slingshot."],
  ["G02",40,0,80,23,[["#",0,8,11,22],["#",12,22,63,22],["^",12,21,63,21],["o",22,7,22,7],["o",34,7,34,7],["m",46,13,46,13],["#",64,8,79,22],["P",2,7,2,7]],
   "Chain the two pods straight ahead, then shoot the mine behind you as you pass it for the last stretch."],
  ["G03",120,0,40,30,[["#",0,8,13,29],["#",14,29,34,29],["^",14,28,34,28],["#",20,0,24,11],["v",20,12,24,12],["o",21,16,21,16],["o",32,7,32,7],["#",35,8,39,29],["#",35,0,39,3],["P",2,7,2,7]],
   "The V: pull down-right under the spiked block, then shoot the high pod up-right before the slingshot drops you in the spikes."],
  ["G04",160,-23,40,46,[["#",0,31,13,45],["#",0,23,13,26],["#",14,45,33,45],["^",14,44,33,44],["#",34,1,39,45],["<",33,8,33,43],["m",18,40,18,40],["o",26,7,26,7],["P",2,30,2,30]],
   "Drop to the mine and blast up the shaft, then grab the pod up-right to swing onto the wall."],
  ["G05",200,-36,40,23,[["#",0,14,39,22],["#",0,0,39,0],["#",39,1,39,13],["m",16,13,16,13],["G",16,2,16,2],["E",35,13,35,13],["P",3,13,3,13]],
   "A breather at the gate. For the golden shell, hop the mine and shoot it from above to ride the blast up into it."],
 ]
