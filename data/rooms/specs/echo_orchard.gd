extends RefCounted
## Rectangle specs for data/rooms/echo_orchard.txt (see tools/room_shapes.gd).
## The finale: every earlier element (mines, shells, pods, phase plates, crumbling and slippery
## ice) returns alongside wind. "}" "{" "~" are gusts blowing right / left / up, on one rhythm (calm, a
## flickering warning, then the gust), so every wind room is a timing puzzle: catch an updraft,
## wait out a headwind, fight a crosswind. Gaps are sized with tools/reach_map.gd to need the wind
## (or its calm) while keeping a few tiles and several frames of slack: hard, never pixel-perfect.
static func rooms() -> Array:
 return [
  ["E01",0,-23,40,46,[["#",0,0,39,3],["v",1,4,39,4],["#",0,4,0,45],["#",1,42,17,45],["~",9,5,13,41],["#",18,17,39,45],["<",17,18,17,41],["P",3,41,3,41]],
   "Updraft: the ledge is far above anything your shells can reach. Stand under the column and wait for the gust."],
  ["E02",40,-23,40,46,[["#",0,0,39,3],["v",6,4,33,4],["#",0,17,5,45],["#",6,45,33,45],["^",6,44,33,44],["{",6,5,32,43],["<",33,18,33,43],["#",34,17,39,45],["P",2,16,2,16]],
   "Headwind: gusts shove you back over the pit. Go in the calm."],
  ["E03",80,-46,40,46,[["#",0,0,39,3],["v",1,4,39,4],["#",0,4,0,33],["#",0,40,5,45],["#",6,45,39,45],["^",6,44,29,44],["~",6,5,10,43],["#",13,24,18,25],["v",13,26,18,26],["~",19,5,23,43],["#",26,14,39,45],["<",25,15,25,43],["P",2,39,2,39]],
   "Gust ladder: ride one updraft, step off onto the ledge, ride the next. Leave each column before it carries you into the ceiling."],
  ["E04",120,-46,40,23,[["#",0,0,39,1],["v",1,2,30,2],["v",35,2,39,2],["#",0,14,25,22],["#",26,22,36,22],["^",26,21,36,21],["~",27,3,35,20],["#",37,14,39,22],["G",33,2,33,2],["P",2,13,2,13]],
   "Orchard gap: hop the pit, or drop into its updraft and thread the notch in the spikes for the golden shell."],
  ["E05",160,-46,56,23,[["#",0,0,55,1],["v",6,2,49,2],["#",0,14,5,22],["#",6,22,41,22],["^",6,21,41,21],["{",6,3,24,13],["m",16,9,16,9],["s",27,9,27,9],["#",42,14,55,22],["<",41,15,41,20],["P",2,13,2,13]],
   "Blast gale: too far for your shells, against the wind. Grab the floating shell, and shoot the mine behind you to be blown across."],
  ["E06",216,-46,40,23,[["#",0,0,39,1],["v",1,2,29,2],["#",0,14,5,22],["#",6,22,29,22],["^",6,21,29,21],["~",6,3,11,20],["o",20,5,20,5],["#",30,8,39,22],["<",29,9,29,20],["P",2,13,2,13]],
   "Spore gust: ride the updraft, then shoot the spore pod to sling yourself onto the high ledge."],
  ["E07",256,-46,40,23,[["#",0,0,39,1],["#",0,8,5,22],["#",6,22,33,22],["^",6,21,33,21],["}",6,2,33,7],["a",9,8,13,8],["b",16,8,20,8],["a",23,8,27,8],["b",30,8,33,8],["w",18,4,18,4],["w",29,4,29,4],["#",34,8,39,22],["P",2,7,2,7]],
   "Phase storm: a tailwind hurries you along the plates. Shoot the switch above the next plate to make it solid; the kick drops you onto it."],
    ["E08",296,-46,64,23,[["#",0,0,63,1],["v",4,2,53,2],["#",0,14,3,22],["#",4,22,45,22],["^",4,21,45,21],["{",4,3,25,14],["c",9,15,11,15],["c",15,15,17,15],["c",21,15,23,15],["~",27,3,31,20],["i",33,10,38,10],["v",33,11,38,11],["#",46,14,63,22],["<",45,15,45,20],["P",1,13,1,13]],
   "Final gauntlet: hop the crumbles through the headwind calm, ride the updraft clear of the spikes, slide off the black ice onto the last ledge."],
  ["E09",360,-46,16,23,[["#",0,0,15,1],["#",0,14,15,22],["E",10,13,10,13],["P",1,13,1,13]],
   "The orchard gate."],
 ]
