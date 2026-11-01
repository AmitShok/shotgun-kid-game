extends RefCounted
## Rectangle specs for data/rooms/copper_cloud_3.txt (see tools/room_shapes.gd).
## World 3-3: swap mid-air, again and again, over long falls.
static func rooms() -> Array:
 return [
  ["Q01",0,0,60,23,[["#",0,0,59,1],["#",0,2,0,18],["#",0,19,5,22],["#",6,22,51,22],["^",6,21,51,21],["a",9,17,15,17],["w",10,12,10,12],["b",20,15,24,15],["w",21,10,21,10],["a",31,13,35,13],["w",32,8,32,8],["b",42,11,46,11],["#",52,11,59,22],["P",3,18,3,18]],
   "Turnstile steps: each step only appears after you swap. Jump, shoot the switch behind you, and let the kick carry you onto the step that just appeared."],
  ["Q02",60,0,40,46,[["#",0,0,39,0],["#",0,1,0,7],["#",39,1,39,40],["#",0,11,6,13],["#",0,14,0,45],["a",1,14,38,14],["w",33,12,33,12],["b",1,22,38,22],["w",6,20,6,20],["a",1,30,38,30],["w",33,28,33,28],["b",1,38,38,38],["w",6,36,6,36],["#",1,45,38,45],["#",1,44,38,44],["P",3,10,3,10]],
   "The turnstile drop: each floor is a plate. Shoot the switch across the room to drop through it to the next."],
  ["Q03",100,25,40,23,[["#",0,0,39,1],["#",0,19,7,22],["#",8,22,31,22],["^",8,21,31,21],["m",10,17,10,17],["a",6,8,31,8],["w",3,13,3,13],["#",32,6,34,22],["#",38,6,39,22],["#",35,10,37,22],["b",35,6,37,6],["G",36,8,36,8],["w",31,4,31,4],["P",3,18,3,18]],
   "A copper lid hangs over the mine. Swap to open it, hop off and blast up through it, then kick across to the high ledge. The golden shell is in a pocket under a teal hatch on the ledge: swap back to drop in."],
  ["Q04",140,16,60,23,[["#",0,0,59,1],["#",0,15,5,22],["#",6,22,43,22],["^",6,21,43,21],["w",3,11,3,11],["o",12,14,12,14],["a",16,2,17,20],["w",21,18,21,18],["b",28,2,29,20],["o",36,14,36,14],["#",44,15,59,22],["P",2,14,2,14]],
   "Two gates, two pods: swap to open the copper gate and pull through it, then swap back mid-flight to open the teal gate before the second pod."],
  ["Q05",200,12,40,23,[["#",0,0,39,1],["#",0,19,5,22],["#",6,22,29,22],["^",6,21,29,21],["b",6,19,29,19],["w",3,13,3,13],["#",30,13,39,22],["a",32,2,33,12],["#",39,2,39,12],["E",36,12,36,12],["P",2,18,2,18]],
   "Swap to raise the teal bridge over the spikes and open the copper door, cross, and pop up to the gate."],
 ]
