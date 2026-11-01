extends RefCounted
## Rectangle specs for data/rooms/echo_orchard_3.txt (see tools/room_shapes.gd).
## World 5-3: wind against ice, crumbles and pods.
static func rooms() -> Array:
 return [
  ["T01",0,0,56,18,[["#",0,0,55,0],["#",0,1,0,11],["#",0,12,7,17],["P",2,11,2,11],["m",9,11,9,11],["^",8,16,15,16],["#",8,17,15,17],["i",16,12,54,12],["#",16,13,55,17],["<",54,7,54,11],["#",55,7,55,12],["{",30,8,53,11],["#",55,1,55,2]],
   "Wind brake: the mine throws you onto black ice heading for a spiked wall, and the ice will never stop you. Only the headwind can: time the blast so you land as the gust starts."],
  ["T02",56,0,56,18,[["#",0,0,55,0],["#",0,1,0,2],["#",0,7,3,17],["v",4,1,45,1],["~",4,2,45,15],["^",4,16,45,16],["#",4,17,45,17],["o",10,7,10,7],["o",19,7,19,7],["o",28,7,28,7],["o",37,7,37,7],["G",21,12,21,12],["#",46,7,55,17],["#",55,1,55,2],["P",2,6,2,6]],
   "Gale relay: the whole pit is one updraft, with spikes above and below. Pull from pod to pod and keep moving: linger in a gust and it lifts you into the ceiling, linger in the calm and you fall."],
  ["T03",112,0,50,30,[["}",1,2,48,27],["#",0,0,49,0],["#",0,1,0,2],["#",0,7,3,7],["#",0,8,0,29],["#",49,1,49,29],["i",6,11,13,11],["i",19,15,24,15],["i",30,19,34,19],["#",42,23,48,23],["<",47,17,47,22],["#",48,17,48,23],["E",44,22,44,22],["^",1,28,48,28],["#",1,29,48,29],["P",2,6,2,6]],
   "Ice terraces: slick terraces step down to the gate with a tailwind behind you. You cannot stop on the ice, so every slide ends in a jump, and a gust carries each jump further than you expect."],
 ]
