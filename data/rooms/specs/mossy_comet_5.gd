extends RefCounted
## Rectangle specs for data/rooms/mossy_comet_5.txt (see tools/room_shapes.gd).
## World 2-5: the summit. New tricks for every tool the comet has taught: catching yourself mid-fall,
## blasting into a pod's reach, and pulling backwards against your own momentum.
static func rooms() -> Array:
 return [
  ["K01",0,-23,40,46,[["#",0,0,39,0],["#",0,1,0,45],["#",39,1,39,36],["#",39,40,39,45],["#",1,4,9,5],["#",30,18,38,19],["o",29,16,29,16],["#",1,30,9,31],["o",10,28,10,28],["#",30,40,38,41],["o",29,38,29,38],[">",1,8,1,26],["<",38,22,38,34],["#",1,45,38,45],["^",1,44,38,44],["G",16,40,16,40],["P",3,3,3,3]],
   "The catch: drop down the spiked shaft and catch yourself on the pods at each alcove mouth before the floor gets you. The golden shell sits just above the spikes: fall past the last alcove for it and catch the last pod at the last moment."],
  ["K02",40,-2,40,23,[["#",0,0,39,0],["#",0,19,11,22],["#",12,22,29,22],["^",12,21,29,21],["m",16,20,16,20],["o",24,1,24,1],["#",30,4,39,22],["P",2,18,2,18]],
   "Mine to pod: the pod is out of reach and two pops would leave you empty. Jump off, shoot the mine below to blast up beside the pod, then pull yourself onto the high ledge (a flat kick after the blast is the expert line)."],
  ["K03",80,-15,40,23,[["#",0,0,39,0],["#",0,17,13,22],["#",0,9,13,10],["v",0,11,13,11],["o",16,7,16,7],["#",14,22,39,22],["^",14,21,39,21],["#",39,1,39,21],["#",0,1,0,8],["E",1,8,1,8],["P",2,16,2,16]],
   "The summit gate sits on the slab above you, and its spiked underside stops any climb from below. Jump out over the pit, kick on past the pod, then pull back up-left: the slingshot carries you up and back over the slab to the gate."],
 ]
