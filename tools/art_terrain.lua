-- Shotgun Kid terrain atlases for all five worlds, authored with Aseprite's Lua API.
--   Aseprite -b --script-param root=<project> --script tools/art_terrain.lua
-- Writes assets/source/<name>.aseprite and assets/textures/<name>.png (128x128, 16px cells):
--   row 0  surface tops      c0 top-left corner, c1-3 c6-7 tops, c4 top-right corner, c5 pillar top
--   row 1  sides / near fill c0 left edge, c1-3 c6-7 fill, c4 right edge, c5 pillar middle
--   row 2  undersides        c0 bottom-left corner, c1-3 c6-7 bottoms, c4 bottom-right, c5 pillar bottom
--   row 3  hanging details   (not solid) eight variants
--   row 4  deep fill         c0-3 two tiles in, c4-7 three or more tiles in (darker, calmer)
--   row 5  one-tile slabs    c0 left end, c1-2 middles, c3 right end, c4 single block
--   row 6  inner corners     c0 top-left, c1 top-right, c2 bottom-left, c3 bottom-right
-- Every material pattern repeats every 16px, so neighbouring tiles always meet seamlessly.
local root=app.params['root'] or '.'
local s,im
local cache={}
local function c(h)
 if not cache[h] then cache[h]=Color{r=tonumber(h:sub(1,2),16),g=tonumber(h:sub(3,4),16),b=tonumber(h:sub(5,6),16),a=255} end
 return cache[h]
end
local CLEAR=Color{r=0,g=0,b=0,a=0}
local function px(x,y,col) if x>=0 and y>=0 and x<im.width and y<im.height then im:drawPixel(x,y,type(col)=='string' and c(col) or col) end end
local function hash(a,b,k) local h=(a*73856093+b*19349663+(k or 0)*83492791)%1000003;return h end

-- Material ramps run dark to light: ramp[1] outline ... ramp[6] highlight.
local worlds={
 {name='terrain_atlas',kind='bricks',
  body={'161a2e','222842','2d3556','3a4669','4c5b84','64769f'},
  cap={'2d3556','7c97b7','b4cde2','e4f0f8'},accent={'3f7a66','62a684'},drip='b4cde2'},
 {name='mossy_comet_terrain',kind='stones',
  body={'0e1719','18262a','23363a','314a49','43605a','5b7a6b'},
  cap={'1d3b24','3f7337','6fa548','b0d86a'},accent={'4c3a2a','6a5238'},drip='6fa548'},
 {name='copper_cloud_terrain',kind='plates',
  body={'25161d','3d2328','62362f','8a4f3b','b06c48','d39360'},
  cap={'5a3a2a','a87843','e0b46c','f7e1a4'},accent={'4f8f84','7fc0b0'},drip='e0b46c'},
 {name='velvet_glacier_terrain',kind='ice',
  body={'181c45','262d62','36468a','5069ad','7294cf','a6c4ea'},
  cap={'6c84b8','bcd2ec','e6f0fb','ffffff'},accent={'d8e8ff','ffffff'},drip='e6f0fb'},
 {name='echo_orchard_terrain',kind='earth',
  body={'1f1318','30202a','482f35','664640','865d4c','a77b5f'},
  cap={'2c4a2a','4f7d36','7fae4a','bcd977'},accent={'3a2620','c3a27e'},drip='4f7d36',flower={'e89ab2','f6e08a'}},
}

-- Pattern: returns a ramp index (2..6) for body pixel (x,y) in a 16px period, variant v.
local patterns={}
function patterns.bricks(x,y,v)
 local row=y//4;local off=(row%2)*4;local bx=(x+off)%16;local brick=(bx//8)+row*2
 if y%4==3 or bx%8==7 then return 2 end
 local tone=4+((hash(brick,v)%3)==0 and -1 or 0)
 if y%4==0 then tone=tone+1 end
 if bx%8==6 then tone=tone-1 end
 return tone
end
local stone_seeds={{3,4,11,3,7,11,13,12},{2,10,9,2,13,8,6,13},{5,2,12,6,4,11,10,14},{8,5,2,12,13,11,6,9}}
function patterns.stones(x,y,v)
 local pts=stone_seeds[v%4+1];local best,second,bi=99,99,1
 for i=1,#pts,2 do
  local dx=math.abs(x-pts[i]);dx=math.min(dx,16-dx);local dy=math.abs(y-pts[i+1]);dy=math.min(dy,16-dy)
  local d=math.sqrt(dx*dx+dy*dy)
  if d<best then second=best;best=d;bi=i elseif d<second then second=d end
 end
 if second-best<1.1 then return 2 end
 local px0,py0=pts[bi],pts[bi+1]
 local dx=x-px0;local dy=y-py0
 if dx>8 then dx=dx-16 elseif dx<-8 then dx=dx+16 end
 if dy>8 then dy=dy-16 elseif dy<-8 then dy=dy+16 end
 local tone=4+(bi%3==1 and 0 or (bi%3==2 and -1 or 0))
 if dx+dy<-3 then tone=tone+1 elseif dx+dy>3 then tone=tone-1 end
 return tone
end
function patterns.plates(x,y,v)
 if x==0 or y==0 then return 2 end
 if x==1 or y==1 then return 5 end
 if (x==3 or x==12) and (y==3 or y==12) then return 6 end
 if (x==4 or x==13) and (y==4 or y==13) then return 2 end
 local tone=4
 if (y+v)%5==0 and x>2 and x<14 then tone=5 end
 if x==15 or y==15 then tone=3 end
 return tone
end
function patterns.ice(x,y,v)
 -- Calm ice: two facets half a tone apart (one is a checker the CRT blends), a faint
 -- fracture line now and then, and a rare glint. Strong stripes would dominate big walls.
 local d=(x+y)%16
 local tone=4
 if d<8 and (x+y)%2==0 then tone=5 end
 if (x-2*y)%16==0 and d>9 then tone=3 end
 if x==5 and y==11 then tone=6 end
 return tone
end
function patterns.earth(x,y,v)
 local layer=((y+((x+v*3)//6)%2)//4)%4
 local tone=({4,3,4,5})[layer+1]
 if (x*7+y*11+v*13)%29==0 then tone=6 end
 if (x*5+y*3+v*11)%31==0 then tone=2 end
 return tone
end

-- Per-variant decoration over the body (cracks, moss, rivets, roots), kept 2px clear of tile edges.
local function decorate(w,ox,oy,v,depth)
 local k=w.kind;local a=w.accent
 if depth>=3 and v%3~=0 then return end
 local r=hash(v,depth,7)
 if k=='bricks' and v%2==0 then
  local x,y=ox+3+r%9,oy+3+(r//9)%9;px(x,y,a[2]);px(x+1,y,a[1]);px(x,y+1,a[1])
 elseif k=='stones' and v%3~=2 then
  local x=ox+2+r%11;for i=0,2+r%3 do px(x+(i%2),oy+3+i,a[1]) end
 elseif k=='plates' and v%2==1 then
  local x,y=ox+4+r%7,oy+5+(r//7)%6;px(x,y,a[1]);px(x+1,y,a[2]);px(x,y+1,a[2]);px(x+1,y+1,a[1]);px(x+2,y+1,a[1])
 elseif k=='ice' then
  local x,y=ox+3+r%9,oy+3+(r//9)%8
  for i=0,3 do px(x+i,y+(i%2)+i//2,w.body[3]) end
  if v%2==0 then px(ox+4+(r%7),oy+10,a[1]) end
 elseif k=='earth' then
  if v%2==0 then local x=ox+3+r%8;for i=0,4 do px(x+i//2,oy+5+i,w.body[2]) end;px(x+3,oy+10,w.body[2]) end
  if v%3==1 then px(ox+5+r%6,oy+8,a[2]);px(ox+6+r%6,oy+8,w.body[5]) end
 end
end

-- Draws one 16x16 tile into cell (cx,cy). open = {u,d,l,r,ul,ur,dl,dr} booleans; depth 1..3.
local function tile(w,cx,cy,open,v,depth)
 local ox,oy=cx*16,cy*16;local b=w.body
 -- Depth darkens in half steps: two tiles in, a checkerboard of the tone and the one below it
 -- (which the CRT beam blends into an in-between colour); three or more in, a full step down.
 for y=0,15 do for x=0,15 do
  local t=patterns[w.kind](x,y,0)
  if depth>=3 then t=t-1;if t>4 then t=4 end
  elseif depth==2 and (x+y)%2==0 then t=t-1 end
  t=math.max(2,math.min(6,t))
  px(ox+x,oy+y,b[t])
 end end
 decorate(w,ox,oy,v,depth)
 -- Side rims: light on the left (the light comes from above-left), shade on the right.
 if open.l then for y=0,15 do px(ox,oy+y,b[1]);px(ox+1,oy+y,b[5]);if y%5==2 then px(ox+2,oy+y,b[4]) end end end
 if open.r then for y=0,15 do px(ox+15,oy+y,b[1]);px(ox+14,oy+y,b[2]);px(ox+13,oy+y,b[3]) end end
 -- Underside: a dark lip with a shadow band above it.
 if open.d then
  for x=0,15 do px(ox+x,oy+15,b[1]);px(ox+x,oy+14,b[2]);if (x+v)%3~=0 then px(ox+x,oy+13,b[3]) end end
 end
 -- Surface cap: outline, bright edge, cap body, and drips that vary per variant.
 if open.u then
  local cap=w.cap
  for x=0,15 do
   px(ox+x,oy,b[1]);px(ox+x,oy+1,cap[4]);px(ox+x,oy+2,(x+v)%4==0 and cap[4] or cap[3]);px(ox+x,oy+3,cap[3]);px(ox+x,oy+4,(x%2==0) and cap[2] or cap[3])
   local drip=(hash(x,v,3)%5==0) and 2 or ((hash(x,v,5)%3==0) and 1 or 0)
   for i=1,drip do px(ox+x,oy+4+i,i==drip and cap[1] or cap[2]) end
   if drip==0 then px(ox+x,oy+5,cap[1]) end
   if (x+v*3)%7==0 then px(ox+x,oy+2,cap[4]) end
  end
  if w.flower and v%2==0 then local fx=ox+3+hash(v,1,9)%10;px(fx,oy+1,w.flower[v%4==0 and 1 or 2]) end
 end
 -- Outer corners are rounded by one pixel.
 if open.u and open.l then px(ox,oy,CLEAR);px(ox,oy+1,b[1]);px(ox+1,oy,b[1]) end
 if open.u and open.r then px(ox+15,oy,CLEAR);px(ox+15,oy+1,b[1]);px(ox+14,oy,b[1]) end
 if open.d and open.l then px(ox,oy+15,CLEAR);px(ox+1,oy+15,b[1]);px(ox,oy+14,b[1]) end
 if open.d and open.r then px(ox+15,oy+15,CLEAR);px(ox+14,oy+15,b[1]);px(ox+15,oy+14,b[1]) end
 -- Inner corners: the neighbouring cap or rim wraps a few pixels into this tile.
 if open.ul then px(ox,oy,b[1]);px(ox+1,oy,w.cap[3]);px(ox,oy+1,b[5]);px(ox+1,oy+1,w.cap[2]) end
 if open.ur then px(ox+15,oy,b[1]);px(ox+14,oy,w.cap[3]);px(ox+15,oy+1,b[2]);px(ox+14,oy+1,w.cap[2]) end
 if open.dl then px(ox,oy+15,b[1]);px(ox+1,oy+15,b[2]);px(ox,oy+14,b[5]) end
 if open.dr then px(ox+15,oy+15,b[1]);px(ox+14,oy+15,b[2]);px(ox+15,oy+14,b[2]) end
end

local function hanging(w,cx,v)
 local ox,oy=cx*16,3*16;local b=w.body
 local kind=w.kind
 if kind=='ice' or kind=='bricks' then
  -- Icicles: a few tapered spikes of different lengths.
  for i=0,2 do
   local x=ox+2+((v*5+i*6)%13);local len=4+hash(v,i,2)%9
   for y=0,len do local wdt=y<len*0.4 and 1 or 0
    px(x,oy+y,y==len and w.drip or (kind=='ice' and w.cap[3] or w.cap[2]));if wdt==1 then px(x+1,oy+y,w.cap[2]) end end
  end
 elseif kind=='plates' then
  -- Pipe stubs and a hanging chain.
  local x=ox+3+v%8;for y=0,5+v%5 do px(x,oy+y,b[y%2==0 and 4 or 3]) end;px(x,oy+6+v%5,w.cap[3])
  if v%2==0 then for y=0,4 do px(ox+11,oy+y,b[5]);px(ox+12,oy+y,b[3]) end;px(ox+10,oy+5,b[2]);px(ox+11,oy+5,w.accent[2]);px(ox+12,oy+5,w.accent[1]) end
 else
  -- Roots and vines.
  local x=ox+2+v%10;local col=kind=='earth' and w.accent[1] or w.cap[2]
  for y=0,6+v%8 do px(x+((y//3)%2),oy+y,col) end
  if v%2==1 then for y=0,4+v%4 do px(ox+12,oy+y,w.cap[3]) end;px(ox+11,oy+5+v%4,w.cap[4]);px(ox+13,oy+3+v%4,w.cap[2]) end
 end
end

local function build(w)
 s=Sprite(128,128);s.layers[1].name='terrain';im=s.cels[1].image
 local function o(t) return {u=t.u,d=t.d,l=t.l,r=t.r,ul=t.ul,ur=t.ur,dl=t.dl,dr=t.dr} end
 for c0=0,7 do
  -- Row 0 tops.
  local lo=(c0==0 or c0==5);local ro=(c0==4 or c0==5)
  tile(w,c0,0,o{u=true,l=lo,r=ro},c0,1)
  tile(w,c0,1,o{l=lo,r=ro},c0+8,1)
  tile(w,c0,2,o{d=true,l=lo,r=ro},c0+16,1)
  hanging(w,c0,c0)
  tile(w,c0,4,o{},c0+24,c0<4 and 2 or 3)
 end
 tile(w,0,5,o{u=true,d=true,l=true},40,1);tile(w,1,5,o{u=true,d=true},41,1);tile(w,2,5,o{u=true,d=true},42,1)
 tile(w,3,5,o{u=true,d=true,r=true},43,1);tile(w,4,5,o{u=true,d=true,l=true,r=true},44,1)
 tile(w,0,6,o{ul=true},48,1);tile(w,1,6,o{ur=true},49,1);tile(w,2,6,o{dl=true},50,1);tile(w,3,6,o{dr=true},51,1)
 s:saveAs(root..'/assets/source/'..w.name..'.aseprite');s:saveCopyAs(root..'/assets/textures/'..w.name..'.png');s:close()
end
for _,w in ipairs(worlds) do build(w) end
