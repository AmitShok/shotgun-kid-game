-- Shotgun Kid props redrawn for the CRT: shell pickup (8x12) and spikes (16x16).
--   Aseprite -b --script-param root=<project> --script tools/art_props.lua
-- Sizes match the old exports, so every scene that uses them stays aligned.
local root=app.params['root'] or '.'
local s,im
local cache={}
local function c(h) if not cache[h] then cache[h]=Color{r=tonumber(h:sub(1,2),16),g=tonumber(h:sub(3,4),16),b=tonumber(h:sub(5,6),16),a=255} end return cache[h] end
local function px(x,y,col) if x>=0 and y>=0 and x<im.width and y<im.height then im:drawPixel(x,y,c(col)) end end
local function rect(x,y,w,h,col) for yy=y,y+h-1 do for xx=x,x+w-1 do px(xx,yy,col) end end end
local function start(w,h,name) s=Sprite(w,h);s.layers[1].name=name;im=s.cels[1].image end
local function save(name) s:saveAs(root..'/assets/source/'..name..'.aseprite');s:saveCopyAs(root..'/assets/textures/'..name..'.png');s:close() end
local ink='1c1a30'

-- Shell: ribbed red hull over a brass base. The bright glint and brass rim bloom under the CRT.
start(8,12,'Shell')
rect(1,0,6,8,ink);rect(2,1,4,7,'c9324a');rect(2,1,1,7,'f0697a');rect(5,1,1,7,'8f1f3c')
for y=2,6,2 do rect(3,y,2,1,'a82640') end
rect(2,1,4,1,'f58a8f');px(2,2,'ffd0c8')
rect(0,8,8,4,ink);rect(1,8,6,3,'d9a441');rect(1,8,6,1,'ffe08a');rect(1,10,6,1,'a06d2c')
px(3,9,'7a4d22');px(4,9,'fff2b8')
save('shell')

-- Spikes: three blades, lit on the left face, with a bright tip and a riveted base plate.
start(16,16,'Spikes')
local function blade(cx,top,hw)
 for y=top,13 do
  local t=(y-top)/(13-top);local w=math.floor(hw*t+0.5)
  for x=cx-w,cx+w do px(x,y,x<cx and 'c9d8e6' or (x==cx and 'e9f2fa' or '6f8199')) end
  px(cx-w-1,y,ink);px(cx+w+1,y,ink)
 end
 px(cx,top-1,ink);px(cx,top,'ffffff')
end
blade(3,4,2);blade(8,1,3);blade(13,5,2)
rect(0,14,16,2,ink);rect(1,14,14,1,'5a6880');px(4,14,'a9b6cf');px(11,14,'a9b6cf')
save('spikes')

-- Lantern Ridge dusk sky (moved here from art_lantern_ridge.lua so it can be redrawn alone):
-- a Bayer-dithered gradient the CRT blends smooth, a moon, quiet stars and long wind clouds.
local function layer(name) local l=s:newLayer();l.name=name;local cel=s:newCel(l,1,Image(s.width,s.height));im=cel.image end
local function ellipse(cx,cy,rx,ry,col) for y=-ry,ry do local w=math.floor(rx*math.sqrt(math.max(0,1-y*y/(ry*ry))));rect(cx-w,cy+y,w*2+1,1,col) end end
local BAYER={{0,8,2,10},{12,4,14,6},{3,11,1,9},{15,7,13,5}}
math.randomseed(1907)
start(640,360,'Dusk bands')
for y=0,359 do
 local level=y/359*28;local base=math.floor(level);local frac=level-base
 for x=0,639 do
  local t=math.min(28,frac>(BAYER[y%4+1][x%4+1]+0.5)/16 and base+1 or base)/28
  im:drawPixel(x,y,Color{r=math.floor(36+95*t),g=math.floor(39+67*t),b=math.floor(63+77*t),a=255})
 end
end
layer('Moon and quiet stars');ellipse(472,63,23,23,'cbb3aa');ellipse(472,62,21,21,'f1d7b2');ellipse(466,58,3,2,'d6bba2');ellipse(479,69,4,3,'dfc4a9')
for i=1,80 do local x,y=math.random(0,639),math.random(8,130);px(x,y,({'69708d','a6a0ac','d7c2b5'})[math.random(1,3)]) end
layer('Long wind clouds')
for _,cl in ipairs({{55,60,95},{210,98,145},{450,113,120},{50,153,150},{330,180,160},{570,47,72}}) do
 local x,y,w=cl[1],cl[2],cl[3];rect(x,y,w,3,'8a7389');rect(x+12,y-3,w-28,3,'9c8191');rect(x+23,y-5,w-57,2,'b6969c');rect(x-13,y+3,w+35,2,'655b76');rect(x+14,y+5,w-17,2,'514c68')
end
save('background')

-- Lantern Ridge mountain planes (moved here from art_lantern_ridge.lua), flattened and given
-- the same dithered fog ramp and silhouette rim light as the other worlds' backdrops.
dofile(root..'/tools/art_depth.lua')
local function line(x0,y0,x1,y1,col)
 local steps=math.max(math.abs(x1-x0),math.abs(y1-y0));if steps==0 then px(x0,y0,col);return end
 for i=0,steps do px(math.floor(x0+(x1-x0)*i/steps),math.floor(y0+(y1-y0)*i/steps),col) end
end
local function poly(points,col)
 local lo,hi=10000,-10000
 for _,p in ipairs(points) do lo=math.min(lo,p[2]);hi=math.max(hi,p[2]) end
 for y=math.floor(lo),math.ceil(hi) do
  local crosses={}
  for i=1,#points do local p=points[i];local q=points[i%#points+1]
   if (p[2]<=y and q[2]>y) or (q[2]<=y and p[2]>y) then table.insert(crosses,p[1]+(y-p[2])*(q[1]-p[1])/(q[2]-p[2])) end
  end
  table.sort(crosses);for i=1,#crosses-1,2 do local a=math.ceil(crosses[i]);rect(a,y,math.floor(crosses[i+1])-a+1,1,col) end
 end
end
start(640,400,'Far mountain shapes')
poly({{-90,325},{20,172},{56,197},{154,72},{219,166},{260,132},{340,236},{419,109},{487,203},{552,152},{690,312},{690,360},{-90,360}},'71677f')
poly({{20,172},{-50,321},{-3,290},{44,223},{56,197}},'9d8294');poly({{154,72},{76,183},{111,164},{143,199},{154,167},{193,205}},'bca0ab');poly({{154,72},{165,184},{219,238},{211,169}},'87758e');poly({{419,109},{345,237},{390,220},{410,186},{444,237}},'a28c9f');poly({{552,152},{483,256},{528,225},{570,246}},'9a8095')
poly({{154,72},{117,126},{137,116},{144,140},{154,125},{166,146},{176,136}},'e0c8c3');poly({{419,109},{387,163},{407,150},{418,170},{425,153},{438,166}},'d6c0be');line(154,153,118,238,'645f7b');line(154,167,171,255,'625c78');line(424,184,452,272,'5a5874')
depth(s.layers[1],'5c5574',0.05,0.45,'f2dcd2')
save('mountains_far')
math.randomseed(2203)
start(640,400,'Blue ridge');poly({{0,285},{47,227},{93,246},{162,200},{224,267},{280,246},{350,284},{420,216},{468,242},{528,214},{594,275},{640,285},{640,400},{0,400}},'38465f')
for x=-10,655,13 do local h=math.random(25,65);local y=313+math.floor(math.sin(x/65)*14);rect(x,y-h,2,h,'2c3c55');for n=0,3 do local w=4+n*3;poly({{x+1,y-h+n*10},{x-w,y-h+n*10+16},{x+w+2,y-h+n*10+16}},n%2==0 and '30465d' or '2c4058') end end
rect(0,330,640,70,'2c3c55')
depth(s.layers[1],'24304a',0.0,0.3,'7f97b8')
save('mountains_near')
