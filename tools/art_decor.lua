-- Scenery ornaments for four worlds: eight distinct 32x32 props each, in a 128x64 sheet
-- (four columns, two rows). Props stand on the bottom row of their cell; the builder places
-- the cell's centre 16px above the ground (tools/build_rooms.gd, _decorate).
--   Aseprite -b --script-param root=<project> --script tools/art_decor.lua
-- Drawn for the CRT (docs/CRT_ART.md): volumes are lit from the upper left with dithered
-- transitions between tones, outlines are a darker shade of the prop's own colour rather than
-- hard ink (so scenery stays behind the gameplay), and glowing things get one bright glint.
local root=app.params['root'] or '.'
local s,im
local cache={}
local CLEAR=Color{r=0,g=0,b=0,a=0}
local function c(h) if not cache[h] then cache[h]=Color{r=tonumber(h:sub(1,2),16),g=tonumber(h:sub(3,4),16),b=tonumber(h:sub(5,6),16),a=255} end return cache[h] end
local ox,oy=0,0
local function px(x,y,col) x=math.floor(x+ox);y=math.floor(y+oy);if x>=ox and y>=oy and x<ox+32 and y<oy+32 then im:drawPixel(x,y,c(col)) end end
local function rect(x,y,w,h,col) for yy=y,y+h-1 do for xx=x,x+w-1 do px(xx,yy,col) end end end
local function line(x0,y0,x1,y1,col)
 local n=math.max(math.abs(x1-x0),math.abs(y1-y0));if n==0 then px(x0,y0,col) return end
 for i=0,n do px(x0+(x1-x0)*i/n+0.5,y0+(y1-y0)*i/n+0.5,col) end
end
-- A shaded ellipse: ramp = {dark, mid, light}; the light comes from the upper left and the
-- band between tones is a 50% checker the CRT blends.
local function blob(cx,cy,rx,ry,ramp)
 for y=-ry,ry do for x=-rx,rx do
  local d=(x*x)/(rx*rx+0.01)+(y*y)/(ry*ry+0.01)
  if d<=1 then
   local l=(x/rx+y/ry)
   local col=ramp[2]
   if l<-0.55 then col=ramp[3] elseif l<-0.35 then col=((x+y)%2==0) and ramp[3] or ramp[2]
   elseif l>0.6 then col=ramp[1] elseif l>0.4 then col=((x+y)%2==0) and ramp[1] or ramp[2] end
   px(cx+x,cy+y,col)
  end
 end end
end
-- A shaded upright column: lit left edge, shaded right edge.
local function post(x,y,w,h,ramp)
 rect(x,y,w,h,ramp[2]);rect(x,y,1,h,ramp[3]);rect(x+w-1,y,1,h,ramp[1])
 for yy=y,y+h-1,2 do px(x+w-2,yy,ramp[1]) end
end
-- Outline each cell's silhouette with a darkened copy of the neighbouring colour.
local function outline(cx0,cy0)
 local pc=app.pixelColor;local marks={}
 for y=cy0,cy0+31 do for x=cx0,cx0+31 do
  if pc.rgbaA(im:getPixel(x,y))==0 then
   local best=nil
   for _,d in ipairs({{0,1},{1,0},{-1,0},{0,-1}}) do
    local nx,ny=x+d[1],y+d[2]
    if nx>=cx0 and ny>=cy0 and nx<cx0+32 and ny<cy0+32 then local v=im:getPixel(nx,ny);if pc.rgbaA(v)>0 then best=v;break end end
   end
   if best then table.insert(marks,{x,y,pc.rgba(math.floor(pc.rgbaR(best)*0.42),math.floor(pc.rgbaG(best)*0.40),math.floor(pc.rgbaB(best)*0.48),255)}) end
  end
 end end
 for _,m in ipairs(marks) do im:drawPixel(m[1],m[2],m[3]) end
end

local sheets={}
-- Mossy Comet: jungle on a comet fragment.
sheets.mossy_comet_decor={
 function() -- fern
  for i=0,4 do local a=-1.1+i*0.55;line(16,31,16+math.sin(a)*12,31-math.cos(a)*15,'3f7337')
   for k=3,12,3 do local x=16+math.sin(a)*k;local y=31-math.cos(a)*k*1.25;px(x-1,y,'6fa548');px(x+1,y-1,'b0d86a') end end
 end,
 function() -- glowing mushrooms
  post(10,22,2,10,{'7a8c86','c8d6cf','eef6f2'});post(19,18,3,14,{'7a8c86','c8d6cf','eef6f2'})
  blob(11,21,5,3,{'1f6f7a','3fb3b8','8ff0ea'});blob(20,17,7,4,{'1f6f7a','3fb3b8','8ff0ea'})
  px(17,15,'ffffff');px(9,20,'e9fffb')
 end,
 function() -- old waystone with a glowing glyph
  rect(9,10,14,20,'33484c');post(9,10,14,20,{'23363a','43605a','5b7a6b'});rect(8,29,16,3,'23363a')
  rect(11,8,10,3,'43605a');line(14,14,18,14,'86f0c0');line(16,13,16,22,'86f0c0');line(14,22,18,18,'86f0c0');px(16,13,'e9fff4')
  rect(9,10,5,2,'6fa548');px(20,12,'6fa548')
 end,
 function() -- spore puffballs
  blob(12,26,6,5,{'4c3a5c','8a6aa0','c6a9dc'});blob(22,28,4,3,{'4c3a5c','8a6aa0','c6a9dc'})
  for _,p in ipairs({{12,18},{16,14},{10,12},{19,9}}) do px(p[1],p[2],'e8d9ff') end;px(10,23,'f6eeff')
 end,
 function() -- comet crystal shard
  for y=0,20 do local w=math.floor((20-y)/4);rect(16-w,10+y,w*2+1,1,y<8 and '7ad8d0' or '3f9f9e');px(16-w,10+y,'b8fff4') end
  line(16,10,16,30,'d8fffa');px(16,11,'ffffff');rect(9,28,15,4,'23363a')
 end,
 function() -- grass tuft
  for i=0,8 do local x=6+i*2.4;local h=8+(i*7)%9;line(x,31,x+((i%3)-1)*2,31-h,i%2==0 and '3f7337' or '6fa548');px(x+((i%3)-1)*2,31-h,'b0d86a') end
 end,
 function() -- root arch
  for a=0,30 do local t=a/30*math.pi;local x=16-math.cos(t)*11;local y=31-math.sin(t)*15;rect(x-1,y,3,2,'4c3a2a');px(x-1,y,'6a5238') end
  line(6,16,4,26,'3f7337');line(26,18,28,27,'3f7337');px(16,15,'b0d86a')
 end,
 function() -- vine stump
  post(11,18,10,14,{'2f2219','4c3a2a','6a5238'});rect(10,17,12,2,'6a5238');px(15,17,'8c7050')
  for y=8,26,3 do px(9+(y%2),y,'6fa548');px(22-(y%2),y+1,'3f7337') end;line(13,18,9,6,'3f7337')
 end,
}
-- Copper Cloud: brass, pipes and gauges above the clouds.
sheets.copper_cloud_decor={
 function() -- lamp post
  post(15,10,3,20,{'5a3328','a35a3a','e09a63'});rect(11,29,11,3,'3d2328');blob(16,8,4,4,{'c48a3a','f2d48a','fff6d0'});px(15,6,'ffffff')
  rect(12,12,9,1,'e0b46c')
 end,
 function() -- pipe elbow with valve wheel
  rect(6,12,5,20,'8a4f3b');rect(6,12,1,20,'d39360');rect(6,10,18,5,'8a4f3b');rect(6,10,18,1,'d39360');rect(24,8,3,9,'b06c48')
  rect(5,20,7,2,'7fc0b0');rect(5,27,7,2,'7fc0b0')
  for a=0,11 do local t=a/12*math.pi*2;px(15+math.cos(t)*4,20+math.sin(t)*4,'e0b46c') end;line(11,20,19,20,'e0b46c');line(15,16,15,24,'e0b46c');px(13,17,'fff0b8')
 end,
 function() -- porthole on a stand
  for r=7,9 do for a=0,47 do local t=a/48*math.pi*2;px(16+math.cos(t)*r,15+math.sin(t)*r,r==9 and '62362f' or (r==8 and 'b06c48' or 'd39360')) end end
  blob(16,15,6,6,{'4f8f84','7fc0b0','d4f2ea'});px(13,12,'ffffff');rect(14,24,5,6,'8a4f3b');rect(10,29,13,3,'3d2328')
 end,
 function() -- chimney stack and smoke
  post(9,14,7,18,{'62362f','8a4f3b','b06c48'});post(19,19,5,13,{'62362f','8a4f3b','b06c48'});rect(8,13,9,2,'e0b46c');rect(18,18,7,2,'e0b46c')
  blob(12,9,3,2,{'9d8c96','c9b8bf','efe2e6'});blob(15,5,4,2,{'9d8c96','c9b8bf','efe2e6'})
 end,
 function() -- pressure gauge
  post(15,18,3,12,{'5a3328','a35a3a','e09a63'});rect(10,29,13,3,'3d2328');blob(16,13,7,7,{'8a4f3b','e0b46c','f7e1a4'});blob(16,13,5,5,{'d8d0c0','f4efe4','ffffff'})
  line(16,13,19,10,'c9324a');px(16,13,'3d2328');for _,a in ipairs({-2.4,-1.6,-0.8,0}) do px(16+math.cos(a)*4,13+math.sin(a)*4,'62362f') end
 end,
 function() -- riveted crate
  rect(7,17,18,15,'8a4f3b');rect(7,17,18,1,'d39360');rect(7,17,1,15,'b06c48');rect(24,17,1,15,'62362f')
  line(8,18,24,30,'62362f');line(8,30,24,18,'62362f');for _,p in ipairs({{9,19},{22,19},{9,29},{22,29}}) do px(p[1],p[2],'f7e1a4') end
 end,
 function() -- mooring bollard
  post(11,16,10,14,{'5a3328','a35a3a','e09a63'});rect(9,14,14,3,'b06c48');rect(9,14,14,1,'f2d48a');rect(8,29,16,3,'3d2328');rect(11,22,10,2,'7fc0b0')
 end,
 function() -- weathervane
  post(15,8,2,22,{'5a3328','a35a3a','e09a63'});rect(11,29,10,3,'3d2328');line(8,9,24,9,'e0b46c');rect(22,7,3,5,'e0b46c');line(8,7,10,11,'e0b46c');px(16,5,'fff0b8');px(16,6,'e0b46c')
 end,
}
-- Velvet Glacier: crystals, snow and frozen light.
local ice={'3e4f8a','84a6d4','e6f2ff'}
sheets.velvet_glacier_decor={
 function() -- tall crystal cluster
  for _,k in ipairs({{16,4,4},{10,12,3},{22,14,3}}) do local cx,top,w=k[1],k[2],k[3]
   for y=top,29 do local ww=math.min(w,math.floor((y-top)/2));rect(cx-ww,y,ww*2+1,1,'84a6d4');px(cx-ww,y,'e6f2ff');px(cx+ww,y,'3e4f8a') end;px(cx,top,'ffffff') end
  rect(7,29,19,3,'c7d8ee')
 end,
 function() -- small crystals in snow
  for _,k in ipairs({{12,20,2},{18,17,3},{23,23,2}}) do local cx,top,w=k[1],k[2],k[3]
   for y=top,29 do local ww=math.min(w,math.floor((y-top)/2));rect(cx-ww,y,ww*2+1,1,'a6c4ea');px(cx-ww,y,'ffffff') end end
  blob(16,30,11,2,{'aac0e0','d8e6f6','ffffff'})
 end,
 function() -- snow mound with a shard
  blob(16,28,12,5,{'aac0e0','d8e6f6','ffffff'});for y=10,26 do local w=math.floor((y-10)/5);rect(19-w,y,w*2+1,1,'84a6d4');px(19-w,y,'e6f2ff') end;px(19,10,'ffffff')
 end,
 function() -- stalagmite
  for y=6,31 do local w=math.floor((y-6)/4);rect(16-w,y,w*2+1,1,'5069ad');px(16-w,y,'a6c4ea');px(16+w,y,'262d62') end
  for y=10,28,6 do px(15,y,'e6f2ff') end
 end,
 function() -- ice lantern
  post(15,14,2,16,ice);rect(10,29,12,3,'36468a');rect(11,6,10,9,'36468a');rect(12,7,8,7,'a6c4ea');blob(16,10,2,2,{'f6e3a0','fff2c0','ffffff'});px(15,9,'ffffff')
  rect(10,5,12,2,'e6f2ff')
 end,
 function() -- frost fern
  for i=0,4 do local a=-1.0+i*0.5;line(16,31,16+math.sin(a)*11,31-math.cos(a)*14,'84a6d4')
   for k=4,12,4 do px(16+math.sin(a)*k-1,31-math.cos(a)*k*1.2,'e6f2ff') end end
 end,
 function() -- ice block with a bubble
  rect(8,14,16,18,'5069ad');rect(8,14,16,1,'e6f2ff');rect(8,14,1,18,'a6c4ea');rect(23,14,1,18,'262d62')
  line(10,28,18,16,'84a6d4');blob(19,24,2,2,{'84a6d4','c8daf2','ffffff'});px(18,23,'ffffff')
 end,
 function() -- snowdrift
  blob(14,27,10,5,{'aac0e0','d8e6f6','ffffff'});blob(22,29,6,3,{'aac0e0','d8e6f6','ffffff'});px(9,23,'ffffff');px(20,26,'ffffff')
 end,
}
-- Echo Orchard: flowers, fruit and carved wood in warm light.
sheets.echo_orchard_decor={
 function() -- flower bunch
  for i=0,4 do local x=8+i*4;local h=12+(i*5)%9;line(x,31,x+((i%2)*2-1),31-h,'4f7d36')
   blob(x+((i%2)*2-1),31-h,2,2,{'b05a7a','e89ab2','ffd8e4'});px(x+((i%2)*2-1),31-h,'f6e08a') end
 end,
 function() -- fruit bush
  blob(16,24,12,8,{'2c4a2a','4f7d36','7fae4a'});for _,p in ipairs({{10,22},{19,20},{15,27},{23,25}}) do blob(p[1],p[2],1,1,{'b8502a','f08a3c','ffd08a'}) end;px(18,19,'fff2c0')
 end,
 function() -- carved post with a bell
  post(13,8,6,24,{'3a2620','664640','a77b5f'});rect(12,6,8,3,'865d4c');rect(12,6,8,1,'c3a27e');line(15,12,17,12,'3a2620');line(15,16,17,16,'3a2620')
  rect(19,10,4,1,'865d4c');blob(22,14,2,3,{'a06d2c','d9a441','ffe08a'});px(21,12,'fff2b8')
 end,
 function() -- fruit basket
  rect(7,22,18,10,'865d4c');for x=8,24,2 do px(x,23,'a77b5f');px(x+1,26,'664640') end;rect(7,22,18,1,'c3a27e')
  for _,p in ipairs({{11,20},{16,19},{21,20},{13,17},{19,17}}) do blob(p[1],p[2],2,2,{'b8502a','f08a3c','ffd08a'}) end;px(15,17,'fff2c0')
 end,
 function() -- sunflower
  line(16,31,16,12,'4f7d36');rect(12,22,4,2,'7fae4a');rect(17,18,4,2,'7fae4a')
  for a=0,11 do local t=a/12*math.pi*2;blob(16+math.cos(t)*5,10+math.sin(t)*5,1,1,{'d9a441','f6e08a','fffbd0'}) end
  blob(16,10,3,3,{'3a2620','664640','865d4c'})
 end,
 function() -- mushroom ring
  for _,m in ipairs({{8,26,3},{15,23,4},{23,27,3}}) do post(m[1]-1,m[2],2,32-m[2],{'c3a27e','efe2cc','fff8ea'});blob(m[1],m[2],m[3],2,{'8f2f3c','e05a5a','ff9c8a'});px(m[1]-1,m[2]-1,'ffffff') end
 end,
 function() -- sapling
  post(15,16,2,16,{'3a2620','664640','a77b5f'});blob(16,11,8,7,{'2c4a2a','4f7d36','7fae4a'});blob(13,9,2,2,{'b05a7a','e89ab2','ffd8e4'});blob(20,13,1,1,{'b8502a','f08a3c','ffd08a'})
 end,
 function() -- wind chime post
  post(10,6,3,26,{'3a2620','664640','a77b5f'});rect(10,6,14,2,'865d4c');rect(10,6,14,1,'c3a27e')
  for i=0,3 do local x=14+i*3;line(x,8,x,12+i*2,'c3a27e');rect(x,13+i*2,1,4,'9ecfe0');px(x,13+i*2,'ffffff') end
 end,
}

for name,props in pairs(sheets) do
 s=Sprite(128,64);s.layers[1].name='ornaments';im=s.cels[1].image
 for i,draw in ipairs(props) do
  ox=((i-1)%4)*32;oy=((i-1)//4)*32
  draw()
  outline(ox,oy)
 end
 s:saveAs(root..'/assets/source/'..name..'.aseprite');s:saveCopyAs(root..'/assets/textures/'..name..'.png');s:close()
end
