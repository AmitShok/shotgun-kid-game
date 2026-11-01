extends RefCounted
## Rectangle specs for data/rooms/lantern_ridge_2.txt (see tools/room_shapes.gd).
## World 1-2: the ridge's moves — pop, kick, refill, mine — strung two at a time.
static func rooms() -> Array:
 return [
  ["A01",0,0,40,23,[["#",0,0,0,18],["#",0,19,13,22],["#",14,22,23,22],["^",14,21,23,21],["#",24,19,39,22],["#",30,13,33,18],["P",3,18,3,18]],
   "Kick over the pit, then jump and pop down over the tall step."],
  ["A02",40,0,80,23,[["#",0,19,5,22],["#",6,22,79,22],["^",6,21,79,21],["#",8,0,79,9],["v",8,10,79,10],["s",22,13,22,13],["#",61,19,79,22],["P",2,18,2,18]],
   "A long pit: kick out, catch the floating shell mid-air, and kick again to reach the far ledge."],
  ["A03",120,0,60,23,[["#",0,19,7,22],["#",8,22,33,22],["^",8,21,33,21],["#",6,0,33,14],["v",6,15,33,15],["m",6,18,6,18],["#",34,20,59,22],["P",2,18,2,18]],
   "The sideways blast: a low spiked ceiling stops every jump. Stand just past the mine and shoot it behind you - the blast throws you flat across the gap."],
  ["A04",180,14,40,23,[["#",0,6,7,22],["#",8,22,31,22],["^",8,21,31,21],["#",32,6,39,22],["#",15,0,27,9],["v",15,10,27,10],["m",29,18,29,18],["#",0,0,14,0],["#",28,0,39,0],["G",20,17,20,17],["E",36,5,36,5],["#",39,1,39,5],["P",3,5,3,5]],
   "Drop under the spiked slab and kick low across the pit, then blast off the mine to climb onto the far ledge. The golden shell hides low in the corridor."],
 ]
