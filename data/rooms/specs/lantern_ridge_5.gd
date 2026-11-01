extends RefCounted
## Rectangle specs for data/rooms/lantern_ridge_5.txt (see tools/room_shapes.gd).
## World 1-5: the ridge's finale - a long way down, back and forth across one big room, then up.
static func rooms() -> Array:
 return [
  ["E01",0,0,40,50,[["#",0,0,39,0],["#",0,1,0,49],["#",39,1,39,42],["#",1,8,30,8],["#",9,18,38,18],["^",31,17,38,17],["#",1,28,30,28],["^",1,27,8,27],["#",9,38,38,38],["^",31,37,38,37],["#",1,46,39,49],["^",1,45,8,45],["G",33,28,33,28],["P",3,7,3,7]],
   "The well: drop through each hole and kick back the way you came, so you land clear of the spikes waiting underneath. The golden shell hangs out over the third drop."],
  ["E02",40,4,50,46,[["#",0,0,49,0],["#",0,1,0,38],["#",0,42,49,45],["^",14,41,16,41],["^",28,41,30,41],["m",45,41,45,41],["#",6,28,41,29],["^",20,27,22,27],["s",6,23,6,23],["#",8,14,49,15],["v",8,16,41,16],["#",49,1,49,10],["P",2,41,2,41]],
   "The switchback: run right along the bottom and launch off the mine, run back left along the middle deck, catch the shell to pop up, then run right along the top."],
  ["E03",90,-16,40,46,[["#",0,34,5,45],["#",0,0,0,31],[">",1,8,1,31],["#",6,45,33,45],["^",6,44,33,44],["#",1,0,39,1],["#",34,5,39,45],["<",33,10,33,43],["m",10,37,10,37],["m",18,14,18,14],["#",39,2,39,4],["E",37,4,37,4],["P",2,33,2,33]],
   "The bank shot: blast up off the low mine, drift right, and shoot the high mine down-right as you pass to reach the gate on top of the wall."],
 ]
