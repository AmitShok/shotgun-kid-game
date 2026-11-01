extends RefCounted
## Rectangle specs for data/rooms/velvet_glacier.txt (see tools/room_shapes.gd).
## "c" crumbling ice holds 0.4s once stood on, then shatters (and regrows); "i" slippery ice
## barely grips, so the shotgun's kick is your brake. Every room keeps spikes close to the path:
## low spiked ceilings and hanging spike curtains force flat, exact kicks; long pits need a jump plus two kicks. A flat kick
## sinks ~20px over a 64px gap, so crumble corridors step down one row per crumble.
static func rooms() -> Array:
 return [
  ["V01",0,0,40,23,[["#",0,0,17,7],["v",6,8,17,8],["#",18,0,39,9],["v",18,10,33,10],["#",0,8,0,10],["#",0,11,5,22],["#",6,20,33,22],["^",6,19,33,19],["c",10,12,11,12],["c",16,13,17,13],["c",22,14,23,14],["c",28,15,29,15],["#",34,16,39,22],["P",2,10,2,10]],
   "Hairline: a corridor too low to jump in, spikes above and below. Kick flat and backward down the staircase of tiny crumbles, kicking again the moment you land."],
  ["V02",40,0,40,23,[["#",0,0,11,13],["v",4,14,11,14],["#",12,0,17,8],["v",12,9,17,9],["#",18,0,23,13],["v",18,14,23,14],["#",24,0,29,8],["v",24,9,29,9],["#",30,0,39,13],["v",30,14,39,14],["#",0,17,3,22],["i",4,19,39,19],["#",4,20,39,22],["^",14,18,15,18],["^",26,18,27,18],["P",1,16,1,16]],
   "Alcoves: slide down black ice under a spiked ceiling too low to jump. Spikes sit on the ice; jump them only where the ceiling rises."],
  ["V03",80,-23,40,46,[["#",0,0,0,36],["#",39,0,39,45],["#",0,42,38,45],["^",10,41,38,41],[">",1,4,1,36],["<",38,6,38,40],["c",14,37,15,37],["c",24,32,25,32],["v",24,33,25,33],["c",14,27,15,27],["v",14,28,15,28],["c",24,22,25,22],["v",24,23,25,23],["c",14,17,15,17],["v",14,18,15,18],["c",6,12,7,12],["c",14,7,15,7],["P",3,41,3,41]],
   "Spire: a spiked shaft climbed on seven tiny crumbles, spikes hanging beneath them. Never stop, never touch a wall."],
  ["V04",80,-46,40,23,[["#",0,0,39,0],["#",0,1,0,22],["#",1,22,9,22],["#",19,22,39,22],["^",24,21,27,21],["i",29,14,32,14],["i",34,8,37,8],["#",38,16,39,21],["G",36,6,36,6],["P",21,21,21,21]],
   "Breather, then gold: the golden shell waits above two slick ledges that will not let you stand still."],
  ["V05",120,-46,80,23,[["#",0,0,79,3],["v",6,4,73,4],["#",16,4,19,7],["v",16,8,19,8],["#",64,4,67,6],["v",64,7,67,7],["#",0,16,5,22],["#",6,22,73,22],["^",6,21,73,21],["#",48,16,59,17],["v",48,18,59,18],["#",74,13,77,22],["#",78,16,79,22],["<",73,14,73,20],["P",2,15,2,15]],
   "Long dark: a spike pit too wide to see across. Two kicks carry you under the curtain to a lone ledge; steady yourself, then leap and kick under the second curtain onto the exit step."],
  ["V06",200,-46,40,23,[["#",0,0,39,3],["v",4,4,39,4],["#",0,16,3,22],["#",4,22,33,22],["^",4,21,33,21],["#",12,15,14,20],["^",12,14,14,14],["#",22,4,25,8],["v",22,9,25,9],["#",32,16,39,22],["<",31,17,31,20],["E",37,15,37,15],["P",1,15,1,15]],
   "Last breath: one long leap over the spike pillar and under the hanging ice, two kicks, onto the gate ledge."],
 ]
