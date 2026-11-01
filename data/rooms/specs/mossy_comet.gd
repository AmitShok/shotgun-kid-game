extends RefCounted
## Rectangle specs for data/rooms/mossy_comet.txt (see tools/room_shapes.gd).
## Spore pods are grapples: they sit on clean 8-way aim lines from natural standing/falling spots,
## and free-floating pods ("o") are used wherever the player flies through the pod.
static func rooms() -> Array:
 return [
  ["M01",0,0,40,23,[["#",0,19,39,22],["#",22,4,39,18],["l",21,8,21,8],["P",3,18,3,18]],
   "Grapple intro: the wall is too tall for any jump and two shots. Shoot the pod 45 degrees up and ride the pull over."],
  ["M02",40,0,80,23,[["#",0,6,6,22],["#",7,0,71,0],["o",19,5,19,5],["o",33,5,33,5],["o",47,5,47,5],["#",55,8,79,22],["P",2,5,2,5]],
   "Flat pulls: chain three floating pods straight ahead to cross the long gap."],
  ["M03",120,-23,40,46,[["#",0,31,7,45],["#",0,0,0,27],["#",8,45,38,45],["^",8,44,38,44],["#",39,0,39,45],["<",38,8,38,42],["o",14,21,14,21],["o",5,12,5,12],["o",14,3,14,3],["#",13,0,13,0],["#",25,0,26,0],["P",3,30,3,30]],
   "Zig-zag chain: pull up-right, up-left, up-right through three floating pods and slingshot out the top."],
  ["M04",120,-46,40,23,[["#",0,0,0,16],["#",0,21,13,22],["#",25,21,39,22],["#",39,0,39,20],["o",19,14,19,14],["G",2,3,2,3],["P",26,20,26,20]],
   "Burst up through the floor gap, then pull up-left off the floating pod to cross back; shooting down too early grabs the pod below, so wait, then shoot down to reach the golden shell."],
  ["M05",40,-46,80,23,[["#",0,0,0,18],["#",73,21,79,22],["#",8,0,72,10],["v",8,11,72,11],["#",0,22,72,22],["^",8,21,72,21],["#",0,19,7,22],["o",66,20,66,20],["o",54,19,54,19],["o",42,18,42,18],["o",30,17,30,17],["o",18,16,18,16],["o",4,6,4,6],["P",76,20,76,20]],
   "Pull gauntlet: between spiked floor and ceiling, chain pulls pod to pod leftward, firing at the next as you slingshot past. The last pod launches you up."],
  ["M06",40,-69,40,23,[["#",0,0,39,0],["#",0,1,0,21],["#",21,0,25,12],["v",21,13,25,13],["#",8,22,39,22],["^",16,21,32,21],["#",39,0,39,21],["#",33,10,38,21],["o",21,19,21,19],["o",30,10,30,10],["E",37,9,37,9],["P",12,21,12,21]],
   "The dip: a spiked overhang blocks the way. Pull down-right under it, then straight away up-right onto the gate ledge."],
 ]
