extends RefCounted
## Rectangle specs for data/rooms/copper_cloud_4.txt (see tools/room_shapes.gd).
## World 3-4: a tall vault of lids and cages. Every swap opens one door and shuts another.
static func rooms() -> Array:
 return [
  ["T01",0,-23,40,46,[["#",0,0,39,0],["#",0,1,0,45],["#",39,5,39,45],["#",1,40,38,45],["a",1,31,38,31],["b",3,30,13,30],["w",26,39,26,39],["b",1,20,38,20],["a",17,19,27,19],["w",5,29,5,29],["m",23,17,23,17],["#",31,5,38,9],["P",4,39,4,39]],
   "The vault: each ledge waits behind a lid of the other colour. Jump beside the floor switch, shoot it to swap and kick up, pop through the open lid and land on the ledge above. At the top, ride the mine out."],
  ["T02",40,-41,40,46,[["#",0,0,39,0],["#",0,23,5,45],["#",6,45,16,45],["^",6,44,16,44],["b",9,28,15,28],["b",9,29,9,32],["b",15,29,15,32],["m",12,31,12,31],["a",6,8,16,8],["w",3,20,3,20],["#",17,9,39,45],["P",2,22,2,22]],
   "Launch and swap: the mine is open now, the lid above it is not. Blast off the mine, then shoot the switch beside you as you rise - the lid opens, the mine's cage shuts, and the kick throws you toward the high ledge."],
  ["T03",80,-50,40,23,[["#",0,0,39,0],["#",0,18,39,22],["a",18,4,22,4],["a",18,5,18,8],["a",22,5,22,8],["a",19,8,21,8],["G",20,6,20,6],["w",4,12,4,12],["o",14,10,14,10],["^",27,17,29,17],["P",2,17,2,17]],
   "A breather. The golden shell is in a copper cage: swap to open it, then sling up off the pod straight through it."],
  ["T04",120,-50,40,23,[["#",0,0,39,0],["#",0,18,11,22],["a",12,1,13,17],["w",6,10,6,10],["#",14,22,27,22],["^",14,21,27,21],["a",14,18,27,18],["o",20,11,20,11],["w",24,16,24,16],["b",28,1,29,17],["#",28,18,39,22],["#",39,1,39,17],["E",35,17,35,17],["P",2,17,2,17]],
   "The vault door: swap to open the copper gate - and lose the copper bridge behind it. Swing over the pit on the pod, then shoot the switch below to swap back through the teal gate."],
 ]
