extends RefCounted
## Rectangle specs for data/rooms/copper_cloud_5.txt (see tools/room_shapes.gd).
## World 3-5: the great gearwork. Swaps that steer you, swaps that reload a mine, and a launch through
## two lids of different colours.
static func rooms() -> Array:
 return [
  ["W01",0,0,40,46,[["#",0,0,39,0],["#",0,1,0,45],["#",39,1,39,28],["#",39,32,39,45],["#",28,8,38,9],["b",1,20,12,20],["a",26,32,36,32],["#",37,32,38,32],["w",30,18,30,18],["w",10,28,10,28],["#",1,45,38,45],["^",1,44,38,44],["G",23,14,23,14],["P",36,7,36,7]],
   "Swap kicks: the ledge below is the wrong colour until you swap. Each switch sits below you to the side, so one shot swaps the plates and kicks you across to the ledge that just appeared. The golden shell floats above the second drop: spend your last shell on a pop at the top of the kick."],
  ["W02",40,13,60,27,[["#",0,0,59,0],["#",0,19,7,26],["#",8,26,45,26],["^",8,25,45,25],["#",6,1,45,14],["v",6,15,45,15],["m",6,18,6,18],["w",11,17,11,17],["s",17,18,17,18],["a",35,16,35,22],["a",41,16,41,22],["o",38,20,38,20],["#",46,22,59,26],["#",59,1,59,21],["E",55,21,55,21],["P",2,18,2,18]],
   "Cage relay: blast off the mine, shoot the switch behind you to open the copper bars around the pod, catch the shell, then grab the pod through the open bars and swing to the gate."],
 ]
