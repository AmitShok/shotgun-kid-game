extends RefCounted
## Rectangle specs for data/rooms/mossy_comet_3.txt (see tools/room_shapes.gd).
## World 2-3: long pod chains over spikes, with shells and mines bridging the gaps.
static func rooms() -> Array:
 return [
  ["H01",0,0,80,23,[["#",0,0,0,18],["#",0,19,7,22],["#",8,22,69,22],["^",8,21,69,21],["#",6,0,69,9],["v",6,10,69,10],["o",16,17,16,17],["o",28,17,28,17],["o",54,17,54,17],["#",70,20,79,22],["P",3,18,3,18]],
   "The canopy line: chain the pods flat, and when the line breaks, kick on to bring the next pod into range."],
  ["H02",80,-23,40,46,[["#",0,43,25,45],["#",0,0,0,39],[">",1,6,1,39],["#",26,8,39,45],["<",25,10,25,42],["o",16,32,16,32],["o",7,23,7,23],["o",16,14,16,14],["P",3,42,3,42]],
   "Zig-zag up the spiked shaft: pods up-right, up-left, up-right, and out over the top of the wall."],
  ["H03",120,-46,40,46,[["#",0,31,5,45],["#",6,0,15,25],[">",16,4,16,24],["#",6,33,39,45],["^",6,32,23,32],["#",24,6,39,32],["<",23,8,23,31],["#",0,0,39,1],["o",19,28,19,28],["o",19,14,19,14],["o",28,3,28,3],["P",2,30,2,30]],
   "Corner swing: pull flat down the spiked tunnel to the corner pod, shoot the next pod straight up the chimney, then pull right onto the ledge at the top."],
  ["H04",160,-49,40,23,[["#",0,9,9,22],["#",10,22,29,22],["^",10,21,29,21],["#",30,9,39,22],["m",19,15,19,15],["o",14,3,14,3],["G",17,0,17,0],["P",3,8,3,8]],
   "A breather: hop the pit, popping off the mine if you need it. The golden shell floats at the top: swing up to it off the pod, then kick down to the far side."],
  ["H05",200,-49,40,23,[["#",0,9,39,22],["#",0,0,39,0],["^",8,8,10,8],["#",22,6,25,8],["^",22,5,25,5],["<",21,6,21,8],["o",28,3,28,3],["#",39,1,39,8],["E",37,8,37,8],["P",3,7,3,7]],
   "Only a slot under the ceiling gets past the spiked wall: pop up to the ceiling and shoot the pod beyond to pull yourself through."],
 ]
