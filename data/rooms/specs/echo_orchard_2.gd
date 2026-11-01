extends RefCounted
## Rectangle specs for data/rooms/echo_orchard_2.txt (see tools/room_shapes.gd).
## World 5-2: gusts that carry you across and gusts that try to throw you off.
static func rooms() -> Array:
 return [
  ["O01",0,0,60,22,[["#",0,0,59,0],["#",0,1,0,15],["#",0,16,5,21],["^",6,20,39,20],["#",6,21,39,21],["~",9,1,11,19],["~",24,1,26,19],["~",36,1,39,19],["s",17,9,17,9],["s",32,9,32,9],["G",26,6,26,6],["#",40,7,59,21],["#",59,1,59,2],["P",2,15,2,15]],
   "Thermals: three updrafts rise out of a spike pit too wide to kick across. Ride one up in the gust, kick across in the calm (a shell hangs between each pair), and fly into the cliff at the far side: the last updraft runs up its face to the ledge."],
  ["O02",60,0,14,52,[["#",0,0,13,0],["#",0,1,0,2],["#",0,7,3,7],["#",0,8,0,51],["#",13,1,13,46],["#",13,51,13,51],["#",1,51,12,51],["}",1,10,11,16],["<",12,8,12,18],["{",2,24,12,30],[">",1,22,1,32],["}",1,37,11,43],["<",12,35,12,45],["P",2,6,2,6]],
   "Crosswinds: the shaft is crossed by three gusts, each blowing toward a spiked wall. Drop through a band in the calm, or kick against the gust to hold your line."],
  ["O03",74,30,16,24,[["#",0,0,15,0],["#",0,1,0,16],["#",1,1,5,16],["#",10,4,10,20],["#",10,1,15,1],["#",15,2,15,3],["#",11,4,15,23],["#",0,21,5,23],["c",6,21,9,21],["^",6,22,9,22],["#",6,23,10,23],["#",10,21,10,22],["~",6,2,9,20],["a",6,14,9,14],["b",6,8,9,8],["w",8,17,8,17],["w",9,11,9,11],["E",13,3,13,3],["P",2,20,2,20]],
   "Airlock lift: the updraft rises from a crumbling floor over spikes, through a copper lid and then a teal one. Step on as the gust starts, and swap the lids as you rise."],
 ]
