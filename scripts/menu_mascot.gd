extends Control
## A live mini level behind the title screen. A strip of terrain columns, drawn with the current
## world's tiles, runs along the bottom: a low runway under the menu, then walls, towers, spiked pits
## and mine ledges. The kid, in the player's current wardrobe, traverses it with real shotgun moves
## (hops, pops, double pops, kick dashes, mine launches). Every column he has passed rebuilds into the
## next layout behind him, so the course is new each time he wraps around. Purely decorative.
signal fired(direction: Vector2)
const CATALOG=preload("res://scripts/wardrobe_catalog.gd")
const WORLDS=preload("res://scripts/world_catalog.gd")
const SHOTGUN=preload("res://assets/textures/shotgun.png")
const BLAST=preload("res://assets/textures/blast.png")
const SHELL=preload("res://assets/textures/shell.png")
const MINE=preload("res://assets/textures/mine.png")
const MINE_GLOW=preload("res://assets/textures/mine_glow.png")
const EXPLOSION=preload("res://assets/textures/explosion.png")
const SPIKES=preload("res://assets/textures/spikes.png")
const AMMO_FULL=preload("res://assets/textures/ui_ammo_full.png")
const AMMO_EMPTY=preload("res://assets/textures/ui_ammo_empty.png")
const FRAME := 24
const TILE := 16
# The kid is drawn larger than in play so the moves read from across the title screen.
const S := 1.5
const HALF := 6.0
# Same feel as the player: run 170, jump 310, gravity 900, recoil 390.
const RUN := 150.0
const JUMP := 310.0
const GRAVITY := 900.0
const RECOIL := 390.0
const MINE_LAUNCH := 600.0
# Columns left of this stay a low runway under the menu column.
const RUNWAY := 17
var columns: Array[Dictionary] = []
var next_layout: Array[Dictionary] = []
var world := 0
var tiles: Texture2D
var pos := Vector2.ZERO
var vel := Vector2.ZERO
var facing := 1.0
var on_floor := true
var aim := Vector2.RIGHT
var ammo := 2
var clock := 0.0
var flash := 0.0
var plan := ""
var plan_column := -1
var pops := 0
var boom := -1.0
var boom_at := Vector2.ZERO
var callout := ""
var callout_age := 9.0
var pip_pop := 0.0
var particles: Array[Dictionary] = []
var started := false
# How many times the kid has fallen into a pit (read by tests to keep the show clean).
var falls := 0

func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 tiles=_tiles_for(world)

func set_world(index: int) -> void:
 # Columns pick up the new world's tiles as they rebuild.
 world=index
 tiles=_tiles_for(index)

func _tiles_for(index: int) -> Texture2D:
 var id: String=WORLDS.WORLDS[index].id
 return load("res://assets/textures/terrain_atlas.png") if id=="lantern_ridge" else load("res://assets/textures/%s_terrain.png" % id)

func count() -> int:
 return int(ceil(size.x/TILE))

# --- Layout -----------------------------------------------------------------------------------

## A fresh course: a flat runway, then features the kid can always clear with one trick each.
func _generate() -> Array[Dictionary]:
 var out: Array[Dictionary] = []
 var n := count()
 var h := 2
 while out.size()<n:
  var c := out.size()
  if c<RUNWAY+2 or c>=n-3:
   # Runway and exit: low and flat, with the odd one-tile step.
   if c>=3 and c<RUNWAY-2 and randf()<0.18: h=clampi(h+(1 if h<3 else -1),1,3)
   if c>=n-3: h=mini(h,4)
   out.append(_col(h))
   continue
  var room := n-3-c
  var pick := randf()
  if pick<0.22 and room>=6:
   # Spiked pit: kick dash across it.
   var width := randi_range(3,5)
   for i in width: out.append(_col(0,true))
   # The far side sits at most a tile above the near side, within a kick dash's reach.
   h=clampi(h+randi_range(-1,1),1,7)
   for i in 2: out.append(_col(h))
  elif pick<0.44 and room>=4:
   # Wall: one pop, or two for a tall tower.
   h=clampi(h+randi_range(4,8),2,13)
   for i in randi_range(3,4): out.append(_col(h))
  elif pick<0.6 and room>=5 and h<=4:
   # Mine ledge: a floating mine in front of a wall too tall for shells alone.
   out.append(_col(h))
   var spot := _col(h)
   spot.mine=true
   out.append(spot)
   out.append(_col(h))
   h=mini(h+randi_range(10,11),15)
   for i in 2: out.append(_col(h))
  elif pick<0.8:
   # Drop or small step.
   h=clampi(h+randi_range(-5,2),1,12)
   for i in randi_range(2,3): out.append(_col(h))
  else:
   out.append(_col(h))
 out.resize(n)
 # Keep the first columns past the runway low enough to stay clear of the title.
 for c in range(RUNWAY,mini(RUNWAY+6,n)): out[c].h=mini(out[c].h,10)
 return out

func _col(height: int,spiked := false) -> Dictionary:
 return {"h":height,"shown":float(height),"spikes":spiked,"mine":false,"armed":true,"regrow":0.0,"tex":tiles,"seed":randi()%997,"rebuild":false}

func top(c: int) -> float:
 # Screen y of a column's top surface.
 if c<0 or c>=columns.size(): return size.y-2*TILE
 return size.y-columns[c].shown*TILE
func floor_under(x: float) -> float:
 # Highest surface under the kid's feet (pits read as their spiked floor).
 var best := size.y+40
 for c in range(int((x-HALF)/TILE),int((x+HALF)/TILE)+1):
  if c<0 or c>=columns.size(): continue
  best=minf(best,top(c) if columns[c].h>0 else size.y-4)
 return best

# --- Frame ------------------------------------------------------------------------------------

func _process(delta: float) -> void:
 if size.x<10: return
 if not started:
  started=true
  columns=_generate()
  next_layout=_generate()
  _drop_in()
 delta=minf(delta,1.0/30.0)
 clock+=delta
 flash=maxf(0.0,flash-delta)
 pip_pop=maxf(0.0,pip_pop-delta*3.0)
 callout_age+=delta
 if boom>=0: boom+=delta
 if boom>0.5: boom=-1.0
 _rebuild_behind(delta)
 _think(delta)
 _move(delta)
 _update_particles(delta)
 queue_redraw()

func _rebuild_behind(delta: float) -> void:
 # Columns well behind the kid slide to their next height, like pistons, raising dust as they go.
 var kid_column := int(pos.x/TILE)
 for c in columns.size():
  var col: Dictionary=columns[c]
  if not col.rebuild and c<kid_column-4 and pos.x>0:
   var fresh: Dictionary=next_layout[c]
   col.rebuild=true
   col.h=fresh.h
   col.spikes=fresh.spikes
   col.mine=fresh.mine
   col.armed=true
   col.tex=tiles
   col.seed=fresh.seed
  var goal: float=float(col.h)
  if absf(col.shown-goal)>0.01:
   var before: float=col.shown
   col.shown=move_toward(col.shown,goal,delta*14.0)
   if int(before*3)!=int(col.shown*3):
    _puff(Vector2(c*TILE+randf_range(2,14),top(c)),Vector2(randf_range(-30,30),randf_range(-50,-20)),Color(0.85,0.82,0.75,0.5),randf_range(2,3.5),0.5)
  if not col.armed:
   col.regrow-=delta
   if col.regrow<=0: col.armed=true

func _wrap() -> void:
 # Off the right edge: finish rebuilding the last columns, queue the next layout, re-enter on the left.
 for c in columns.size():
  var col: Dictionary=columns[c]
  if not col.rebuild:
   var fresh: Dictionary=next_layout[c]
   for key in ["h","spikes","mine","seed"]: col[key]=fresh[key]
   col.armed=true
   col.tex=tiles
  col.rebuild=false
 next_layout=_generate()
 _drop_in()

# --- The kid's decisions ------------------------------------------------------------------------

func _think(delta: float) -> void:
 if pos.x>size.x+24:
  _wrap()
  return
 # Coming down toward a spiked pit with a shell left (after a pop, a launch or a drop): kick across.
 if not on_floor and vel.y>0 and ammo>0 and plan in ["","wall","launch","drop"] and _pit_ahead():
  _fire(Vector2(-1,1).normalized())
  _say("KICK DASH!")
  plan="flying"
 if plan=="drop":
  # Dropping in: fall straight, then start the run.
  if on_floor: plan=""
  return
 if plan=="":
  facing=1.0
  if on_floor: vel.x=RUN
  # Steer in the air like the player does, so a pop beside a wall carries on over it.
  else: vel.x=move_toward(vel.x,RUN,700*delta)
  var ahead := _next_obstacle()
  if ahead.is_empty(): return
  var gap: float=ahead.x-(pos.x+HALF)
  match ahead.kind:
   "step":
    if on_floor and gap<10: _jump()
   "wall":
    if on_floor and gap<14:
     _jump()
     plan="wall"
     plan_column=ahead.c
     pops=0
     _say("ROCKET POP!" if ahead.rise<140 else "DOUBLE POP!")
   "pit":
    if on_floor and gap<4:
     _jump()
     plan="dash"
     _say("KICK DASH!")
   "mine":
    plan="mine"
    plan_column=ahead.c
  return
 if plan=="wall" and not on_floor: vel.x=move_toward(vel.x,RUN,700*delta)
 match plan:
  "wall":
   # Pop at the top of each arc until clear of the wall.
   var need: float=top(plan_column)-2
   if pos.y>need and vel.y>-40 and ammo>0 and pops<2:
    _fire(Vector2.DOWN)
    pops+=1
   if pos.y<=need or on_floor and pops>0: plan=""
  "dash":
   if vel.y>-120 and ammo>0:
    _fire(Vector2(-1,1).normalized())
    plan="flying"
  "flying":
   if on_floor: plan=""
  "mine":
   var mine_x: float=plan_column*TILE+TILE*0.5
   var mine_y: float=top(plan_column)-16
   var col: Dictionary=columns[plan_column]
   if on_floor:
    # Line up a short hop that peaks right over the mine.
    var stand: float=mine_x-40
    if absf(pos.x-stand)>4:
     facing=signf(stand-pos.x)
     vel.x=facing*RUN*0.7
    else:
     facing=1.0
     _jump()
     vel.x=120.0
   elif pos.y<mine_y-18 and absf(pos.x-mine_x)<10 and col.armed:
    vel.x=0
    _fire(Vector2.DOWN)
    _detonate(plan_column)
    plan="launch"
   elif absf(pos.x-mine_x)<4: vel.x=0
  "launch":
   vel.x=RUN*0.8
   if on_floor: plan=""

func _pit_ahead() -> bool:
 # Would this fall end in a pit? Looks a little ahead, where the current arc is heading.
 for dx in [0.0,16.0,32.0]:
  var c := int((pos.x+dx)/TILE)
  if c>=0 and c<columns.size() and columns[c].h==0: return true
 return false

## The first column ahead that needs more than running: a step, a wall, a pit or a mine ledge.
func _next_obstacle() -> Dictionary:
 var start := int((pos.x+HALF)/TILE)
 var feet: float=pos.y
 for c in range(maxi(start,0),mini(start+4,columns.size())):
  var col: Dictionary=columns[c]
  if col.mine and col.armed and c+1<columns.size():
   return {"kind":"mine","c":c,"x":c*TILE}
  if col.h==0:
   return {"kind":"pit","c":c,"x":c*TILE}
  var rise: float=feet-top(c)
  if rise>2:
   return {"kind":"step" if rise<=40 else "wall","c":c,"x":c*TILE,"rise":rise}
 return {}

func _jump() -> void:
 vel.y=-JUMP
 on_floor=false
 _dust(6)

func _fire(direction: Vector2) -> void:
 if ammo<=0: return
 ammo-=1
 aim=direction
 flash=0.08
 if direction.y>0.5 and absf(direction.x)<0.1: vel.y=minf(vel.y,0.0)-RECOIL
 else: vel+=-direction*RECOIL
 var muzzle := pos+Vector2(0,-9)+direction*30
 for i in 6: _puff(muzzle+Vector2(randf_range(-4,4),randf_range(-4,4)),direction*randf_range(20,60)+Vector2(randf_range(-20,20),randf_range(-20,20)),Color(0.85,0.85,0.9,0.55),randf_range(3,6),0.5)
 for i in 5: _puff(muzzle,direction.rotated(randf_range(-0.5,0.5))*randf_range(120,220),Color(1,0.8,0.4,1),1.5,0.18)
 # A spent shell flips out the side.
 particles.append({"kind":"casing","p":pos+Vector2(0,-9),"v":Vector2(-facing*randf_range(50,90),randf_range(-160,-110)),"rot":0.0,"spin":randf_range(12,20),"age":0.0,"life":1.4})
 fired.emit(direction)

func _detonate(c: int) -> void:
 var col: Dictionary=columns[c]
 col.armed=false
 col.regrow=4.0
 boom=0.0
 boom_at=Vector2(c*TILE+TILE*0.5,top(c)-16)
 # A real launch would leave the screen; this one peaks inside it.
 vel.y=-MINE_LAUNCH
 _say("MINE LAUNCH!")
 for i in 14:
  _puff(boom_at,Vector2.RIGHT.rotated(randf()*TAU)*randf_range(60,180),Color(1,0.6+randf()*0.3,0.3,1),randf_range(1.5,3),0.4)

func _move(delta: float) -> void:
 if not on_floor:
  vel.y+=GRAVITY*delta
  vel.x=move_toward(vel.x,0,60*delta)
 var old_x := pos.x
 pos.x+=vel.x*delta
 # Walls: a column whose top is above the kid's feet blocks him.
 var front := int((pos.x+HALF)/TILE) if vel.x>=0 else int((pos.x-HALF)/TILE)
 if front>=0 and front<columns.size() and columns[front].h>0 and top(front)<pos.y-3 and front!=int(old_x/TILE):
  pos.x=front*TILE-HALF-0.01 if vel.x>=0 else (front+1)*TILE+HALF+0.01
  vel.x=0
 pos.y+=vel.y*delta
 var ground := floor_under(pos.x)
 if pos.y>=ground and vel.y>=0:
  if not on_floor:
   _dust(8)
   if ammo<2: pip_pop=1.0
  pos.y=ground
  vel.y=0
  on_floor=true
  ammo=2
  if ground>=size.y-6:
   # Landed in a spiked pit: poof back up onto the last ledge.
   _poof()
 elif on_floor and pos.y<ground-1:
  on_floor=false
 elif on_floor:
  # Ride a rising or sinking column.
  pos.y=ground

func _poof() -> void:
 falls+=1
 for i in 10: _puff(pos+Vector2(0,-12),Vector2.RIGHT.rotated(randf()*TAU)*randf_range(40,100),Color(1,1,1,0.7),randf_range(2,4),0.5)
 var c := clampi(int(pos.x/TILE),0,columns.size()-1)
 while c>0 and columns[c].h==0: c-=1
 pos=Vector2(c*TILE+TILE*0.5,top(c))
 vel=Vector2.ZERO
 plan=""

func _say(text: String) -> void:
 callout=text
 callout_age=0.0

func _dust(amount: int) -> void:
 for i in amount:
  _puff(Vector2(pos.x+randf_range(-6,6),pos.y),Vector2(randf_range(-60,60),randf_range(-40,-10)),Color(0.85,0.82,0.75,0.6),randf_range(2,4),0.45)

func _puff(at: Vector2,velocity: Vector2,color: Color,radius: float,life: float) -> void:
 if particles.size()>160: particles.pop_front()
 particles.append({"kind":"puff","p":at,"v":velocity,"c":color,"r":radius,"age":0.0,"life":life})

func _update_particles(delta: float) -> void:
 for part in particles:
  part.age+=delta
  if part.kind=="casing":
   part.v.y+=700*delta
   part.p+=part.v*delta
   part.rot+=part.spin*delta
   var g := floor_under(part.p.x)
   if part.p.y>g and part.v.y>0:
    part.p.y=g
    part.v=Vector2(part.v.x*0.4,-part.v.y*0.35)
    part.spin*=0.5
  else:
   part.v*=1.0-2.5*delta
   part.p+=part.v*delta
 particles=particles.filter(func(part): return part.age<part.life)

# --- Drawing ----------------------------------------------------------------------------------

func _draw() -> void:
 if not started: return
 _draw_terrain()
 for c in columns.size():
  if columns[c].mine and columns[c].h>0: _draw_mine(c)
 if boom>=0:
  var frame := mini(int(boom/0.5*6.0),5)
  draw_texture_rect_region(EXPLOSION,Rect2(boom_at-Vector2(48,48),Vector2(96,96)),Rect2(frame*96,0,96,96))
 for part in particles:
  var t: float=part.age/part.life
  if part.kind=="casing":
   draw_set_transform(part.p,part.rot,Vector2(0.6,0.6))
   draw_texture(SHELL,-Vector2(4,6),Color(1,0.62,0.48,1.0-maxf(0.0,t-0.7)/0.3))
   draw_set_transform(Vector2.ZERO)
  else:
   var c: Color=part.c
   c.a*=1.0-t
   draw_circle(part.p,part.r*(1.0+t*0.8),c)
 var ground := floor_under(pos.x)
 draw_circle(Vector2(pos.x,ground+1),maxf(3.0,10.0-(ground-pos.y)*0.04),Color(0,0,0,0.3))
 _draw_kid()
 for i in 2:
  var tex: Texture2D=AMMO_FULL if i<ammo else AMMO_EMPTY
  var s: float=0.45*(1.0+pip_pop*0.4)
  draw_set_transform(pos+Vector2(-8+i*9,-56),0.0,Vector2(s,s))
  draw_texture(tex,-Vector2(7,11),Color(1,1,1,0.9))
  draw_set_transform(Vector2.ZERO)
 if callout_age<1.1:
  var font: Font=get_theme_default_font()
  var a: float=1.0-maxf(0.0,callout_age-0.7)/0.4
  var pop: float=1.0+maxf(0.0,0.25-callout_age)*2.0
  var w: float=font.get_string_size(callout,HORIZONTAL_ALIGNMENT_LEFT,-1,11).x
  var at := Vector2(clampf(pos.x-w*0.5*pop,4,size.x-w*pop-4),pos.y-72-callout_age*22.0)
  draw_set_transform(at,-0.06,Vector2(pop,pop))
  draw_string_outline(font,Vector2.ZERO,callout,HORIZONTAL_ALIGNMENT_LEFT,-1,11,4,Color(0.05,0.07,0.12,a))
  draw_string(font,Vector2.ZERO,callout,HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color(1,0.82,0.45,a))
  draw_set_transform(Vector2.ZERO)

func _draw_terrain() -> void:
 # Atlas layout (as tools/build_rooms.gd): row 0 tops, row 1 fill; column 0 left edge, 4 right edge.
 for c in columns.size():
  var col: Dictionary=columns[c]
  var x: float=c*TILE
  if col.shown<=0.02:
   if col.spikes: draw_texture(SPIKES,Vector2(x,size.y-TILE))
   continue
  var y_top: float=top(c)
  var rows := int(ceil(col.shown))
  var left_h: float=columns[c-1].shown if c>0 else col.shown
  var right_h: float=columns[c+1].shown if c+1<columns.size() else col.shown
  for r in rows:
   var y: float=y_top+r*TILE
   if y>size.y: break
   var level: float=col.shown-r
   var atlas_x: int=1+(int(col.seed)+r*3)%3
   if left_h<level-0.5: atlas_x=0
   elif right_h<level-0.5: atlas_x=4
   var atlas_y := 0 if r==0 else 1
   draw_texture_rect_region(col.tex,Rect2(x,y,TILE,TILE),Rect2(atlas_x*TILE,atlas_y*TILE,TILE,TILE))
  # Columns still moving glow faintly at the top, so the rebuild reads as deliberate.
  if absf(col.shown-col.h)>0.05:
   draw_rect(Rect2(x,y_top-1,TILE,2),Color(1,0.85,0.6,0.5))

func _draw_mine(c: int) -> void:
 var col: Dictionary=columns[c]
 var spot := Vector2(c*TILE+TILE*0.5,top(c)-16+sin(clock*3.0+c)*2.0)
 if col.armed:
  var glow := 0.5+0.5*sin(clock*6.0)
  draw_texture(MINE_GLOW,spot-Vector2(MINE_GLOW.get_width(),MINE_GLOW.get_height())*0.5,Color(1,1,1,0.35+glow*0.4))
  draw_texture_rect_region(MINE,Rect2(spot-Vector2(16,16),Vector2(32,32)),Rect2(int(clock*8)%4*32,0,32,32))
 else:
  draw_texture_rect_region(MINE,Rect2(spot-Vector2(16,16),Vector2(32,32)),Rect2(0,0,32,32),Color(0.5,0.55,0.65,0.25))

func _draw_kid() -> void:
 # Same sheet layout as the player: idle 0-3, run 4-9, rise 10, apex 11, fall 12-13.
 var frame := int(clock*6.0)%4
 if not on_floor: frame=10 if vel.y<-80 else (11 if vel.y<80 else 12)
 elif absf(vel.x)>20: frame=4+int(clock*12.0)%6
 var region := Rect2(frame*FRAME,0,FRAME,FRAME)
 var body := pos-Vector2(0,FRAME*0.5*S)
 draw_set_transform(body,0.0,Vector2(facing*S,S))
 for category in ["outfits","scarves","hats"]:
  var texture: Texture2D=CATALOG.texture(category,SaveData.appearance[category])
  if texture: draw_texture_rect_region(texture,Rect2(-FRAME*0.5,-FRAME*0.5,FRAME,FRAME),region)
 draw_set_transform(Vector2.ZERO)
 # The shotgun points where the kid aims; it eases back to forward after a shot.
 if flash<=0: aim=aim.lerp(Vector2(facing,0),0.2).normalized()
 draw_set_transform(body+Vector2(0,5*S),aim.angle(),Vector2(S,-S if aim.x<-0.01 else S))
 draw_texture(SHOTGUN,Vector2(-3,-5))
 if flash>0:
  draw_texture(BLAST,Vector2(16,-16),Color(1,1,1,minf(1.0,flash*16.0)))
 draw_set_transform(Vector2.ZERO)

func _drop_in() -> void:
 # Enter by dropping in from above, just right of the menu column, so the kid is never hidden
 # behind the buttons.
 pos=Vector2(RUNWAY*TILE+8,-30)
 vel=Vector2.ZERO
 on_floor=false
 plan="drop"
