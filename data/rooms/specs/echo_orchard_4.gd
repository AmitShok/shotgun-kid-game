extends RefCounted
## Rectangle specs for data/rooms/echo_orchard_4.txt (see tools/room_shapes.gd).
## World 5-4: up the inside of a hollow tree, riding and fighting the draughts.
static func rooms() -> Array:
 return [
  ["K01",0,0,50,14,[["~",6,2,43,10],["#",0,0,49,0],["v",6,1,43,1],["#",0,1,0,6],["#",0,7,0,13],["#",0,11,13,13],["^",14,12,16,12],["#",14,13,16,13],["#",17,11,25,13],["^",26,12,28,12],["#",26,13,28,13],["#",29,11,35,13],["^",36,12,38,12],["#",36,13,38,13],["#",39,11,49,13],["#",49,1,49,6],["G",22,3,22,3],["P",2,10,2,10]],
   "Fight the lift: a low hall where every gust tries to carry you into the spikes overhead. Shoot upward to drive yourself back to the floor (each landing reloads you), but never over the pits: cross those in the calm."],
  ["K02",50,-28,20,40,_draught_steps(),
   "Draught steps: climb the trunk on slick ice ledges. Every ledge has a gust blowing toward the spiked bark beside it. The bark ledges hold you; the ice ones do not, so cross each ice ledge in a single calm. At the top a draught lifts you out."],
  ["K03",50,-50,20,22,[["~",12,4,15,21],["}",1,1,17,3],["#",0,0,19,0],["<",18,1,18,3],["#",0,1,0,21],["#",19,1,19,21],["#",1,4,10,4],["E",3,3,3,3],["#",1,21,11,21],["#",16,21,18,21],["P",17,20,17,20]],
   "Crown gate: the draught lifts you into the crown, where a crosswind blows everything onto the spiked bark. Step into the draught as the gust starts: it lifts you to the top just as it dies, and the gate is a kick away in the calm. Linger at the top and the next gust blows you onto the bark."],
 ]

## Ledges on alternating sides, three rows apart, each under a gust toward its own wall. The
## right-hand ledges are ice (the gust blows you off), the left-hand ones are solid bark to rest on.
static func _draught_steps() -> Array:
 var r: Array = [["~",12,1,15,12],["#",0,0,11,0],["#",16,0,19,0],["#",0,1,0,34],["#",19,1,19,39],["#",0,39,18,39],["P",3,38,3,38]]
 var row := 36
 var right := true
 # The first ledge (right) is ice; sides alternate, so every ice ledge is on the right.
 var ice_right := true
 while row>=15:
  if right:
   r.append_array([["}",8,row-2,17,row-1],["<",18,row-2,18,row-1],["i" if right==ice_right else "#",11,row,14,row]])
  else:
   r.append_array([["{",2,row-2,11,row-1],[">",1,row-2,1,row-1],["i" if right==ice_right else "#",4,row,8,row]])
  right=not right
  row-=3
 return r
