extends RefCounted
## Rectangle specs for data/rooms/copper_cloud.txt (see tools/room_shapes.gd).
## Phase plates: "a" copper (solid in phase 0, every room's starting phase), "b" teal (solid in
## phase 1); "w" switches swap the phase. Full-height plate walls and lids make each swap
## mandatory (a wall cannot be shot around), and switches sit where the shot that hits them also
## kicks the player the useful way: below you for height, behind you for speed.
static func rooms() -> Array:
 return [
  ["C01",0,0,40,23,[["#",0,0,39,1],["#",0,2,0,18],["#",0,19,25,22],["#",36,19,39,22],["#",26,22,35,22],["^",26,21,35,21],["a",22,2,23,18],["b",26,19,35,19],["w",19,10,19,10],["P",3,18,3,18]],
   "Swap intro: a copper gate blocks the way. Shoot the switch above: the gate goes hollow and a teal bridge spans the pit."],
  ["C02",40,0,40,23,[["#",0,0,39,0],["v",6,1,33,1],["#",0,19,5,22],["#",6,22,33,22],["^",6,21,33,21],["a",9,17,11,17],["b",17,15,20,15],["a",30,2,31,20],["#",34,15,39,22],["w",7,13,7,13],["P",2,18,2,18]],
   "Mid-air swap: hop to the copper step, jump on and shoot the switch behind you. The kick carries you to the teal step that just appeared, and the copper gate is open."],
  ["C03",80,-23,40,46,[["#",0,0,0,29],["#",1,0,2,1],["#",15,0,16,1],["#",39,0,39,45],["#",0,38,38,45],["a",1,29,38,29],["b",4,28,16,28],["b",1,19,38,19],["a",27,18,35,18],["a",1,9,38,9],["b",4,8,20,8],["w",20,35,20,35],["w",20,27,20,27],["w",23,17,23,17],["P",3,37,3,37]],
   "Lid climb: each ledge sits under a lid of its own colour. Jump, shoot the switch below you to flip the lid open and boost up, then shoot again to reach the next ledge."],
  ["C04",80,-46,40,23,[["#",0,0,39,0],["#",0,1,0,21],["#",0,22,2,22],["#",15,22,39,22],["a",32,1,33,21],["w",26,5,26,5],["b",10,13,13,13],["a",1,6,6,6],["a",7,1,7,5],["b",2,5,6,5],["G",3,3,3,3],["P",18,21,18,21]],
   "High switch: boost up and shoot the switch overhead to open the gate. The golden shell's cage only opens in teal, via the teal step."],
  ["C05",120,-46,40,23,[["#",0,0,39,0],["v",2,1,37,1],["#",0,22,39,22],["^",5,21,35,21],["a",12,2,12,20],["b",24,2,24,20],["a",34,2,34,20],["w",6,12,6,12],["b",17,16,19,16],["w",15,12,15,12],["a",28,16,30,16],["w",26,12,26,12],["P",2,21,2,21]],
   "Airlocks: every swap opens the wall ahead and seals the one behind. Shoot each switch behind you mid-jump so the kick throws you through."],
  ["C06",160,-46,40,23,[["#",0,0,39,0],["v",6,1,33,1],["#",0,22,39,22],["^",6,21,33,21],["#",39,1,39,11],["a",8,17,10,17],["b",14,2,15,20],["w",17,19,17,19],["b",18,15,20,15],["a",24,2,25,20],["w",27,19,27,19],["a",28,13,30,13],["#",34,12,38,21],["E",37,11,37,11],["P",2,21,2,21]],
   "Double swap: pass the open teal gate, shoot the switch below to boost and raise the teal step; pass the now-open copper gate, shoot the next switch below to land on copper."],
 ]
