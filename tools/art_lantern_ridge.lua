-- Shotgun Kid / Lantern Ridge. Original pixel art authored by Aseprite's Lua API.
-- Recreates matching source documents. Back up hand-edited sources before running.
local root=app.params['root'] or '.'
local s,im
local palette={}
local function c(h,a)
 local k=h..tostring(a or 255)
 if not palette[k] then palette[k]=Color{r=tonumber(h:sub(1,2),16),g=tonumber(h:sub(3,4),16),b=tonumber(h:sub(5,6),16),a=a or 255} end
 return palette[k]
end
local function start(w,h,name) s=Sprite(w,h);s.layers[1].name=name or 'Silhouette';im=s.cels[1].image end
local function layer(name) local l=s:newLayer();l.name=name;local cel=s:newCel(l,1,Image(s.width,s.height));im=cel.image end
local function px(x,y,color) x=math.floor(x);y=math.floor(y);if x>=0 and y>=0 and x<im.width and y<im.height then im:drawPixel(x,y,type(color)=='string' and c(color) or color) end end
local function rect(x,y,w,h,color) for yy=math.floor(y),math.floor(y+h-1) do for xx=math.floor(x),math.floor(x+w-1) do px(xx,yy,color) end end end
local function line(x0,y0,x1,y1,color)
 local steps=math.max(math.abs(x1-x0),math.abs(y1-y0));if steps==0 then px(x0,y0,color);return end
 for i=0,steps do px(x0+(x1-x0)*i/steps,y0+(y1-y0)*i/steps,color) end
end
local function ellipse(cx,cy,rx,ry,color)
 for y=-ry,ry do local w=math.floor(rx*math.sqrt(math.max(0,1-y*y/(ry*ry))));rect(cx-w,cy+y,w*2+1,1,color) end
end
local function poly(points,color)
 local lo,hi=10000,-10000
 for _,p in ipairs(points) do lo=math.min(lo,p[2]);hi=math.max(hi,p[2]) end
 for y=math.floor(lo),math.ceil(hi) do
  local crosses={}
  for i=1,#points do local p=points[i];local q=points[i%#points+1]
   if (p[2]<=y and q[2]>y) or (q[2]<=y and p[2]>y) then table.insert(crosses,p[1]+(y-p[2])*(q[1]-p[1])/(q[2]-p[2])) end
  end
  table.sort(crosses);for i=1,#crosses-1,2 do rect(math.ceil(crosses[i]),y,math.floor(crosses[i+1])-math.ceil(crosses[i])+1,1,color) end
 end
end
local function ring(cx,cy,r,width,color)
 for y=-r,r do for x=-r,r do local d=x*x+y*y;if d<=r*r and d>=(r-width)*(r-width) then px(cx+x,cy+y,color) end end end
end
local function save(name) s:saveAs(root..'/assets/source/'..name..'.aseprite');s:saveCopyAs(root..'/assets/textures/'..name..'.png');s:close() end
math.randomseed(3817)
local ink='202139'
-- Eight hand-shaped poses, consistent 24px cells; separate costume/detail layers.
start(192,24,'Character silhouette')
for f=0,7 do
 local x=f*24;local b=(f==1 or f==3 or f==5) and 1 or 0
 poly({{x+8,2+b},{x+16,2+b},{x+19,6+b},{x+19,11+b},{x+17,13+b},{x+18,20},{x+15,23},{x+6,23},{x+6,18},{x+5,13+b},{x+7,10+b},{x+5,7+b}},ink)
end
layer('Beanie, face and winter coat')
for f=0,7 do
 local x=f*24;local b=(f==1 or f==3 or f==5) and 1 or 0
 rect(x+8,2+b,8,1,'f4b596');rect(x+6,4+b,11,4,'d75c70');rect(x+8,3+b,8,2,'ef8490');rect(x+6,7+b,13,2,'a63f62')
 rect(x+7,7+b,10,1,'ffae9c');rect(x+9,3+b,1,4,'fbb09f');rect(x+7,9+b,3,3,'443048')
 rect(x+10,9+b,7,4,'efba99');rect(x+16,10+b,3,2,'f8d6af');px(x+15,9+b,ink);px(x+15,10+b,ink)
 rect(x+10,12+b,5,1,'bd7b80');rect(x+7,13+b,9,7,'d39468');rect(x+8,14+b,3,4,'edba82');rect(x+14,14+b,2,6,'94617a')
 rect(x+11,14+b,1,6,'664b68');rect(x+7,19,9,2,'485b73');rect(x+14,15+b,4,3,'efba99');px(x+17,15+b,'ffe2b7')
 local left,right=7,13
 if f>=2 and f<=5 then left=({5,7,9,7})[f-1];right=({15,13,11,13})[f-1] end
 if f==6 then left=6;right=14 end
 rect(x+left,20,4,2,'34465f');rect(x+right,20,4,2,'34465f');rect(x+left-1,22,5,1,ink);rect(x+right,22,5,1,ink)
 px(x+left,21,'94adb4');px(x+right,21,'94adb4')
end
layer('Scarf motion and highlights')
for f=0,7 do local x=f*24;local b=(f==1 or f==3 or f==5) and 1 or 0
 rect(x+7,12+b,9,2,'72ccca');rect(x+6,13+b,5,2,'438fa4');line(x+6,14+b,x+1,12+f%3,'559fb2');line(x+5,13+b,x+1,11+f%3,'a4e9d6')
end
save('kid')
start(24,10,'Double barrel');poly({{1,4},{7,2},{22,2},{23,3},{23,6},{10,6},{7,9},{3,9}},ink)
rect(7,2,14,2,'a8c8d0');rect(8,4,14,2,'5c738e');rect(9,2,11,1,'e0efe2');rect(21,2,2,4,'34455e')
rect(2,5,6,3,'a97561');rect(3,5,4,1,'e6b18a');rect(10,6,2,2,'d2b68d');rect(6,5,3,2,'57677d');save('shotgun')
-- Terrain atlas: 8 columns x 4 rows, all 16px. Corner and hanging-rock cells included.
start(128,64,'Rock tile silhouettes')
for ty=0,3 do for tx=0,7 do
 local x,y=tx*16,ty*16
 rect(x,y,16,16,ink)
 if ty==3 then
  rect(x,y,16,16,c('202139',0))
  poly({{x,y},{x+16,y},{x+14,y+7},{x+11,y+7},{x+9,y+13},{x+7,y+10},{x+3,y+9},{x+2,y+5},{x,y+5}},'303b53')
 else
  rect(x+1,y+1,14,14,'3e4b65');rect(x+1,y+1,14,2,'69778b')
  poly({{x+1,y+4},{x+7,y+2},{x+14,y+5},{x+12,y+12},{x+4,y+15},{x+1,y+12}},'4c5d75')
  line(x+2,y+12,x+6,y+14,'2e374f');line(x+8,y+2,x+14,y+4,'82949e')
  if tx%2==0 then line(x+8,y+5,x+5,y+8,'30384f');line(x+5,y+8,x+7,y+11,'30384f') end
  if tx%3==0 then rect(x+2,y+8,2,1,'758894');rect(x+10,y+11,3,1,'63778a') end
  if ty==2 then rect(x,y+14,16,2,'202c45');line(x+2,y+12,x+6,y+13,'304058') end
 end
end end
layer('Snow caps, seams and moss')
for tx=0,7 do local x=tx*16
 rect(x,0,16,3,'f0f1d8');rect(x,3,16,2,'b3d6d3');rect(x,5,16,1,'678eaa')
 rect(x+1,0,5,1,'ffffff');rect(x+10,1,4,1,'ffffff')
 if tx%2==0 then rect(x+4,4,4,2,'b3d6d3');rect(x+5,6,2,2,'719eb6') else rect(x+11,5,2,4,'93bed0') end
 if tx==0 then rect(x,3,2,9,'a0c8cc');rect(x,0,1,2,c('202139',0)) end
 if tx==4 then rect(x+14,3,2,9,'759bb0');rect(x+15,0,1,2,c('202139',0)) end
 if tx==5 or tx==6 then line(x+3,0,x+2,-2,'99c6ac') end
 for ty=1,2 do local y=ty*16
  if tx%3==1 then rect(x+1,y+2,5,2,'497c80');rect(x+2,y+4,2,2,'54958b') end
  if tx==0 then rect(x,y,1,16,'9aaeb5') end
  if tx==4 then rect(x+15,y,1,16,'202139') end
 end
end
save('terrain_atlas')
-- Legacy modular platform textures follow the same palette.
start(16,16);rect(0,0,16,16,'40546d');rect(0,0,16,3,'edf0d9');rect(0,3,16,2,'a5c9cc');rect(0,5,16,1,'617f99');rect(3,9,9,1,'788f9e');line(7,7,5,13,'28334d');save('tile')
start(16,16);rect(0,0,16,16,'303b53');rect(1,1,14,12,'4c5d75');line(2,2,13,2,'72889b');line(9,6,5,11,'303b53');save('stone')
-- Floating naval mine: six beveled horns, riveted steel, amber eye, four pulse frames.
start(128,32,'Mine shell and spikes')
for f=0,3 do local x=f*32
 for _,v in ipairs({{16,2},{29,9},{29,23},{16,30},{3,23},{3,9}}) do
  local dx,dy=v[1]-16,v[2]-16;local len=math.sqrt(dx*dx+dy*dy);local bx,by=16+dx/len*9,16+dy/len*9
  poly({{x+v[1],v[2]},{x+bx-dy/len*3,by+dx/len*3},{x+bx+dy/len*3,by-dx/len*3}},ink)
  line(x+v[1],v[2],x+bx,by,'94acb9')
 end
 ellipse(x+16,16,11,11,ink);ellipse(x+16,15,9,9,'455e78');ellipse(x+14,13,7,6,'688b9d');ellipse(x+15,15,6,6,'3a506b')
 line(x+10,9,x+17,7,'b4d8d0');line(x+23,15,x+23,19,'24344e');line(x+10,23,x+18,25,'36536c')
 for _,v in ipairs({{10,12},{21,11},{11,21},{21,21}}) do px(x+v[1],v[2],'d8dfc1') end
end
layer('Copper ring and pulse core')
for f=0,3 do local x=f*32;ring(x+16,16,5,2,'c78a67');ellipse(x+16,16,3,3,'754b5c');ellipse(x+16,15,2,2,({'ffd792','fff3c3','f5b568','fff3c3'})[f+1]);px(x+15,14,'fff8e7') end
save('mine')
start(64,64,'Soft amber aureole');ellipse(32,32,31,31,c('f4b078',8));ellipse(32,32,24,24,c('f4b078',12));ellipse(32,32,17,17,c('ffd89c',15));ring(32,32,22,1,c('ffd89c',55));save('mine_glow')
start(576,96,'Six-frame blast ring')
for f=0,5 do local x=f*96+48;local r=8+f*7;local alpha=255-f*35
 if f<2 then ellipse(x,48,r-2,r-2,c('fff5d4',alpha)) end
 ring(x,48,r,math.max(1,5-f),c('ffe6ac',alpha));ring(x,48,r-4,2,c('f49b7c',alpha))
 for n=0,7 do local a=n*math.pi/4+0.15;local d=r+3;line(x+math.cos(a)*d,48+math.sin(a)*d,x+math.cos(a)*(d+6-f),48+math.sin(a)*(d+6-f),c('ffcc8f',alpha)) end
end
save('explosion')
-- Clear item silhouettes and handcrafted fixture detail.
start(8,12);rect(1,0,6,12,ink);rect(2,1,4,8,'a94764');rect(2,1,1,7,'f28b87');rect(3,2,2,5,'d96176');rect(1,8,6,3,'e5b571');rect(1,8,6,1,'ffe4a1');save('shell')
start(16,16);for i=0,1 do local x=i*8;poly({{x,16},{x+3,2+i*2},{x+7,16}},ink);poly({{x+1,15},{x+3,4+i*2},{x+4,15}},'e0ecdf');poly({{x+4,15},{x+3,4+i*2},{x+6,15}},'779fb6') end;rect(0,15,16,1,'384860');save('spikes')
start(24,40,'Checkpoint pole');rect(6,5,3,33,ink);rect(7,5,1,33,'bccac3');ellipse(7,3,2,2,'ffdb9e');rect(2,37,14,3,'35455e');rect(3,37,12,1,'adcbc9')
layer('Hand-stitched pennant');poly({{9,5},{22,7},{19,12},{22,17},{9,15}},'d65e7a');line(10,6,20,8,'ffb9a2');line(10,14,20,16,'9e4769');rect(12,8,2,5,'fbe2b1');rect(11,9,4,2,'fbe2b1');save('flag')
start(40,56,'Stone doorway');poly({{2,56},{2,17},{7,6},{13,1},{27,1},{34,6},{38,17},{38,56}},ink);poly({{5,56},{5,17},{10,8},{15,5},{25,5},{31,9},{35,17},{35,56}},'5b7187');poly({{10,56},{10,18},{15,11},{25,11},{30,18},{30,56}},'26334c')
for y=19,48,10 do line(4,y,9,y,'27334b');line(31,y+4,36,y+4,'27334b') end
rect(12,20,16,34,'477e8d');rect(15,17,10,36,'65b7b3');rect(18,18,5,35,'9fe0c9');line(6,16,10,9,'bbd3d0');line(10,9,15,6,'bbd3d0');rect(0,52,40,4,'bacfca');rect(2,52,35,1,'f1eed6');ring(20,8,3,1,'f3c187');save('door')
start(64,32);poly({{1,12},{11,12},{16,7},{27,11},{44,6},{35,14},{62,16},{36,19},{46,26},{24,22},{15,26},{11,20},{1,20}},'de7483');poly({{2,13},{17,12},{22,10},{27,14},{49,16},{25,19},{19,23},{14,19},{2,19}},'ffc28e');poly({{1,14},{21,14},{36,16},{20,18},{1,18}},'fff4c8');save('blast')
start(5,5);line(2,0,2,4,'fff2c7');line(0,2,4,2,'ffc38d');px(2,2,'ffffff');save('spark')
start(3,3);px(1,0,'ecf5e6');rect(0,1,3,1,'cce6e0');px(1,2,'98bdcc');save('snowflake')
start(32,64,'Lantern glow');ellipse(16,21,15,19,c('ffd39b',12));ellipse(16,21,11,14,c('ffd39b',15));ellipse(16,21,7,10,c('ffd39b',24))
layer('Iron fixture');rect(15,18,3,46,ink);rect(16,30,1,33,'6b798d');rect(10,60,12,4,'283b52');rect(10,60,12,1,'94b2b7');poly({{8,14},{16,8},{24,14}},'34465f');rect(9,14,14,2,'99aeb6');rect(10,16,12,13,ink);rect(12,17,8,10,'edaa73');rect(14,17,4,8,'ffe4a4');rect(11,27,11,2,'748b96');rect(16,16,1,12,'617387');save('lantern')
start(48,32,'Snow heather');for i=0,5 do local x=6+i*7;local h=8+math.random(0,12);line(x,30,x-3,30-h,'30415b');line(x-2,24,x-7,19,'49767c');line(x-1,25,x+4,19,'62948e');ellipse(x-3,30-h,3,2,'c78398');px(x-4,29-h,'edb9b4') end;ellipse(24,30,20,2,'c6ded4');save('heather')
start(64,96,'Spruce silhouette');rect(30,31,5,65,'283148');poly({{32,0},{22,21},{27,20},{14,38},{21,37},{7,60},{17,58},{0,82},{29,80},{32,95},{35,80},{63,82},{48,60},{56,61},{41,39},{49,41},{37,22},{42,22}},'243f54')
layer('Needle boughs');for n=0,4 do local y=17+n*14;local w=8+n*5;poly({{32,y-11},{32-w,y+4},{32-3,y+1},{32+w,y+5}},n%2==0 and '3a6875' or '345c6d');line(32-w+3,y+2,30,y-7,'75a5a4');line(30,y-7,31,y-10,'ceddd1') end;rect(31,82,2,14,'676271');save('spruce')
start(32,48,'Hanging banner');rect(4,0,24,3,'8fa4ae');rect(6,3,2,5,'d6d8bd');rect(24,3,2,5,'d6d8bd');poly({{7,7},{25,7},{25,44},{16,38},{7,44}},'894568');rect(8,8,2,29,'c67687');rect(22,8,2,32,'663650');poly({{16,14},{21,22},{16,30},{11,22}},'f0bd8f');poly({{16,18},{18,22},{16,26},{14,22}},'914e6b');save('banner')
start(32,32,'Wayfinding sign');rect(14,10,3,22,'3c3b51');rect(15,10,1,22,'948080');poly({{2,3},{23,3},{30,10},{23,17},{2,17}},ink);poly({{3,4},{22,4},{28,10},{22,15},{3,15}},'6d687a');line(4,4,21,4,'b5a09a');line(10,9,21,9,'e9d6b4');line(18,6,22,10,'e9d6b4');line(22,10,18,13,'e9d6b4');save('waypost')
-- Layered dusk sky, painted clouds, mountain planes and forest silhouettes.
start(640,360,'Dusk bands')
for y=0,359 do
 local t=math.floor(y/6)/60
 local shade=Color{r=math.floor(36+95*t),g=math.floor(39+67*t),b=math.floor(63+77*t),a=255}
 rect(0,y,640,1,shade)
end
layer('Moon and quiet stars');ellipse(472,63,23,23,'cbb3aa');ellipse(472,62,21,21,'f1d7b2');ellipse(466,58,3,2,'d6bba2');ellipse(479,69,4,3,'dfc4a9')
for i=1,80 do local x,y=math.random(0,639),math.random(8,130);px(x,y,({'69708d','a6a0ac','d7c2b5'})[math.random(1,3)]) end
layer('Long wind clouds')
for _,cl in ipairs({{55,60,95},{210,98,145},{450,113,120},{50,153,150},{330,180,160},{570,47,72}}) do
 local x,y,w=cl[1],cl[2],cl[3];rect(x,y,w,3,'8a7389');rect(x+12,y-3,w-28,3,'9c8191');rect(x+23,y-5,w-57,2,'b6969c');rect(x-13,y+3,w+35,2,'655b76');rect(x+14,y+5,w-17,2,'514c68')
end
save('background')
start(640,400,'Far mountain shapes')
local ridge={{-90,325},{20,172},{56,197},{154,72},{219,166},{260,132},{340,236},{419,109},{487,203},{552,152},{690,312},{690,360},{-90,360}}
poly(ridge,'71677f')
layer('Moonlit planes');poly({{20,172},{-50,321},{-3,290},{44,223},{56,197}},'9d8294');poly({{154,72},{76,183},{111,164},{143,199},{154,167},{193,205}},'bca0ab');poly({{154,72},{165,184},{219,238},{211,169}},'87758e');poly({{419,109},{345,237},{390,220},{410,186},{444,237}},'a28c9f');poly({{552,152},{483,256},{528,225},{570,246}},'9a8095')
layer('Snow caps and ravines');poly({{154,72},{117,126},{137,116},{144,140},{154,125},{166,146},{176,136}},'e0c8c3');poly({{419,109},{387,163},{407,150},{418,170},{425,153},{438,166}},'d6c0be');line(154,153,118,238,'645f7b');line(154,167,171,255,'625c78');line(424,184,452,272,'5a5874');save('mountains_far')
start(640,400,'Blue ridge');poly({{0,285},{47,227},{93,246},{162,200},{224,267},{280,246},{350,284},{420,216},{468,242},{528,214},{594,275},{640,285},{640,400},{0,400}},'38465f')
layer('Pine forest');for x=-10,655,13 do local h=math.random(25,65);local y=313+math.floor(math.sin(x/65)*14);rect(x,y-h,2,h,'2c3c55');for n=0,3 do local w=4+n*3;poly({{x+1,y-h+n*10},{x-w,y-h+n*10+16},{x+w+2,y-h+n*10+16}},n%2==0 and '30465d' or '2c4058') end end
rect(0,330,640,70,'2c3c55');save('mountains_near')
print('Lantern Ridge: layered Aseprite sources and PNGs exported.')
