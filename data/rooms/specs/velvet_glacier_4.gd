extends RefCounted
## Rectangle specs for data/rooms/velvet_glacier_4.txt (see tools/room_shapes.gd).
## World 4-4: a climb where nothing you stand on lets you stay.
static func rooms() -> Array:
 return [
  ["Z01",0,0,44,30,[["#",0,0,37,0],["#",43,0,43,0],["#",0,1,0,28],["#",43,1,43,28],["#",0,29,43,29],["^",5,28,42,28],["#",1,26,4,28],["i",8,23,11,23],["i",13,20,16,20],["i",18,17,21,17],["i",23,14,26,14],["i",28,11,31,11],["i",33,8,36,8],["#",38,5,42,5],["G",41,13,41,13],["P",2,25,2,25]],
   "Ice stairs: a staircase of slick steps over spikes. You land sliding and cannot stop, so every step is a jump straight into the next."],
  ["Z02",33,-36,18,36,_collapse_lift(),
   "Collapse lift: floor after floor of crumbling ice, each with a hole and a pod above it. Pull up through the hole and land beside it; the floor starts to go the moment you touch it."],
  ["Z03",33,-54,30,18,[["#",0,0,29,0],["#",0,1,0,17],["#",29,1,29,17],["#",1,17,9,17],["#",14,17,17,17],["#",18,17,28,17],["^",18,16,28,16],["#",1,5,7,5],["E",3,4,3,4],["c",19,13,21,13],["w",20,8,20,8],["a",22,9,22,14],["m",25,14,25,14],["P",15,16,15,16]],
   "Perch: a crumbling perch over spikes, with the mine behind a copper shield. Two shots before the perch goes: the switch above you, then the mine, which throws you back across the room to the gate."],
 ]

## Whole-width crumble floors (separate two-tile segments) with wide holes. Each
## pod hangs beyond the next hole, so the pull runs diagonally through it.
static func _collapse_lift() -> Array:
 var r: Array = [["#",0,0,9,0],["#",14,0,17,0],["#",0,1,0,35],["#",17,1,17,35],["#",0,35,4,35],["#",10,35,17,35],["o",11,1,11,1],["P",12,34,12,34]]
 # [row, first hole column, pod column, pod height above the floor, hole width]
 for f in [[26,3,2,2,4],[18,7,11,2,5],[10,5,5,2,5]]:
  var y: int=f[0]
  var hole: int=f[1]
  var x := 1
  var flip := false
  while x<17:
   if x>=hole and x<hole+f[4]:
    x+=1
    continue
   var w := 1 if x+1==hole or x+1>=17 else 2
   r.append(["c" if flip else "k",x,y,x+w-1,y])
   flip=not flip
   x+=w
  r.append(["o",f[2],y-f[3],f[2],y-f[3]])
 return r
