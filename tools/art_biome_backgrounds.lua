-- Shotgun Kid / Lantern Ridge. Original pixel art authored by Aseprite's Lua API.
-- Recreates matching source documents. Back up hand-edited sources before running.
local root=app.params['root'] or '.'
local s,im
local wrap_background=true
local palette={}
local function c(h,a)
 local k=h..tostring(a or 255)
 if not palette[k] then palette[k]=Color{r=tonumber(h:sub(1,2),16),g=tonumber(h:sub(3,4),16),b=tonumber(h:sub(5,6),16),a=a or 255} end
 return palette[k]
end
local function start(w,h,name) s=Sprite(w,h);s.layers[1].name=name or 'Silhouette';im=s.cels[1].image end
local function layer(name) local l=s:newLayer();l.name=name;local cel=s:newCel(l,1,Image(s.width,s.height));im=cel.image end
local function px(x,y,color) x=math.floor(x);y=math.floor(y);if wrap_background then x=x%640 end;if x>=0 and y>=0 and x<im.width and y<im.height then im:drawPixel(x,y,type(color)=='string' and c(color) or color) end end
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
-- Background-only art direction. Safe to regenerate without changing tiles or layouts.
local function gradient(top,bottom)
 local a,b=c(top),c(bottom)
 for y=0,399 do local t=math.floor(y/5)*5/399
  rect(0,y,640,1,Color{r=a.red+(b.red-a.red)*t,g=a.green+(b.green-a.green)*t,b=a.blue+(b.blue-a.blue)*t})
 end
end
local function mix(a,b,t)
 local aa,bb=type(a)=='string' and c(a) or a,type(b)=='string' and c(b) or b
 return Color{r=aa.red+(bb.red-aa.red)*t,g=aa.green+(bb.green-aa.green)*t,b=aa.blue+(bb.blue-aa.blue)*t}
end
local function bark(x,base,h,col,hi)
 local shade=mix(col,'172333',.25);local lit=mix(col,hi,.48)
 for j=0,4 do
  local xx=x-5+j*3;local yy=base-12-(j%2)*7
  line(xx,yy,xx-2,yy-h*.27,shade);line(xx-2,yy-h*.27,xx+1,yy-h*.52,lit)
 end
 ellipse(x+3,base-h*.27,3,5,shade);ellipse(x+3,base-h*.27,1,3,lit)
 for j=-1,1 do line(x+j*3,base-16,x+j*16,base,shade) end
end
local function puff(x,y,w,h,base,lit)
 for _,v in ipairs({{-.64,.10,.40,.48},{-.27,-.20,.45,.73},{.20,-.1,.42,.67},{.63,.20,.40,.42}}) do ellipse(x+w*v[1],y+h*v[2],w*v[3],h*v[4],base) end
 if lit then ellipse(x-w*.22,y-h*.48,w*.32,h*.20,lit);ellipse(x+w*.36,y-h*.35,w*.24,h*.16,lit) end
end
local function leaf(x,y,w,h,dir,col,vein)
 poly({{x,y},{x+dir*w*.3,y-h*.75},{x+dir*w,y-h},{x+dir*w*.83,y-h*.26},{x+dir*w*.3,y+2}},col)
 line(x,y,x+dir*w*.9,y-h*.82,vein)
 for j=1,4 do local t=j/5;local xx=x+dir*w*t;local yy=y-h*.82*t
  line(xx,yy,xx+dir*w*.08,yy-h*.19,mix(col,vein,.55))
  line(xx,yy,xx+dir*w*.16,yy+h*.12,mix(col,'152d33',.22))
 end
end
local function canopy(x,y,w,col,hi,fruit)
 puff(x,y,w,w*.45,col,nil)
 -- Clusters follow the crown silhouette, with shade underneath and rim light above.
 for j=0,math.floor(w*1.6) do
  local xx=x+math.random(-math.floor(w*.93),math.floor(w*.93));local yy=y+math.random(-math.floor(w*.40),math.floor(w*.26))
  local ix,iy=math.floor(xx)%640,math.floor(yy)
  if iy>=0 and iy<400 and app.pixelColor.rgbaA(im:getPixel(ix,iy))>0 then
   local radius=math.max(1,math.floor(w/28))+math.random(0,2);local top=yy<y-w*.05
   ellipse(xx,yy,radius+1,2+(j%2),top and mix(col,hi,.6) or mix(col,'152733',.18))
   line(xx-radius,yy-1,xx,yy-2,top and hi or mix(col,hi,.32))
   if j%3==0 then px(xx+1,yy-2,mix(hi,'c4cfac',.17)) end
  end
 end
 if fruit then
  for j=0,math.floor(w/10) do local xx=x+math.random(-math.floor(w*.75),math.floor(w*.75));local yy=y+math.random(0,math.max(3,math.floor(w*.19)))
   local r=math.min(3,math.max(1,math.floor(w/24)))
   ellipse(xx,yy,r,r+1,mix(fruit,'614958',.28));ellipse(xx-1,yy-1,math.max(1,r-1),r,fruit)
   px(xx-1,yy-1,'f3d4a4');line(xx,yy-r-1,xx+1,yy-r-3,mix(col,'273f3e',.4));if w>45 then leaf(xx+1,yy-r-3,5,2,1,col,hi) end
  end
 end
end
local function jungle(x,base,h,col,hi)
 poly({{x-13,base},{x-4,base-h*.74},{x-24,base-h*.93},{x-18,base-h*.96},{x+5,base-h*.78},{x+29,base-h*.98},{x+35,base-h*.95},{x+11,base-h*.69},{x+18,base}},col)
 line(x+1,base-5,x+3,base-h*.72,hi)
 bark(x+3,base,h,col,hi)
 for j=0,5 do local yy=base-h+j*8;leaf(x,yy,42-j*2,20,j%2==0 and 1 or -1,col,hi) end
 canopy(x,base-h,49,col,hi,nil)
end
local function blossom(x,y,r,col,center)
 for k=0,4 do local a=k*math.pi*2/5;local xx=x+math.cos(a)*r*.75;local yy=y+math.sin(a)*r*.65
  ellipse(xx,yy,r*.53,r*.45,mix(col,'705469',.22))
  ellipse(xx-.5,yy-.8,r*.43,r*.32,col)
  if r>=5 then line(xx,yy,x+math.cos(a)*r*.25,y+math.sin(a)*r*.25,mix(col,'f2d5c5',.38)) end
 end
 ellipse(x,y,r*.34,r*.28,center)
 if r>=5 then for k=0,4 do local a=k*math.pi*2/5;px(x+math.cos(a)*r*.23,y+math.sin(a)*r*.18,mix(center,'89634f',.45)) end;px(x-1,y-1,'f8e5b8') end
end
local function orchard(x,base,h,w,col,hi,fruit)
 poly({{x-15,base},{x-7,base-h*.7},{x-38,base-h*.87},{x-34,base-h*.92},{x+1,base-h*.72},{x+36,base-h*.96},{x+41,base-h*.93},{x+10,base-h*.65},{x+18,base}},col)
 line(x-2,base-2,x-1,base-h*.66,hi)
 bark(x,base,h,col,hi)
 canopy(x,base-h,w,col,hi,fruit)
 for j=0,6 do local xx=x-w*.6+j*w*.18;local yy=base-h+(j%3)*8-7;blossom(xx,yy,3,'cbb7b0','e5d7ad') end
end
local function ice_inclusions()
 for j=0,84 do
  local x=30+(j*67)%581;local y=75+(j*43)%263
  if j%3==0 then
   line(x,y,x+4,y+9,'6b7fa0');line(x+4,y+9,x+1,y+15,'617694')
   line(x+4,y+9,x+10,y+10,'6b7fa0')
  else
   ellipse(x,y,1+(j%2),2,'657b99');px(x,y-1,'8b9fb8')
  end
 end
 for _,v in ipairs({{110,181,44},{214,133,34},{432,197,67},{508,272,33}}) do
  local x,y,h=v[1],v[2],v[3]
  poly({{x,y},{x+4,y-4},{x+11,y+h},{x+8,y+h+3}},'8195b1')
  line(x,y,x+7,y+h,'94a7bc')
 end
end
local function export(name)
 s:saveAs(root..'/assets/source/'..name..'_backdrop.aseprite')
 local layers={};for _,l in ipairs(s.layers) do table.insert(layers,l) end
 for _,l in ipairs(layers) do
  for _,o in ipairs(layers) do o.isVisible=(o==l) end
  s:saveCopyAs(root..'/assets/textures/'..name..'_'..l.name..'.png')
 end
 s:close()
end
-- MOSSY COMET: roots cling to a tumbling world; open space is visible between crowns.
math.randomseed(903)
start(640,400,'sky');gradient('100f29','233b45')
-- Wisps of nebula, clustered rather than evenly distributed noise.
for j=0,5 do puff(280+j*21,99-j*7,107,22,'242342',nil) end
for j=0,3 do puff(319+j*17,83-j*5,66,12,'303251',nil) end
for i=1,160 do local x,y=math.random(0,639),math.random(4,306);px(x,y,i%5==0 and 'b5b5c5' or '505879') end
for _,v in ipairs({{156,65},{367,125},{540,34},{278,47},{423,177}}) do line(v[1]-2,v[2],v[1]+2,v[2],'bdd6cf');line(v[1],v[2]-2,v[1],v[2]+2,'bdd6cf') end
-- Ringed planet anchors the cosmic setting through the canopy opening.
ellipse(409,88,55,9,'696288');ellipse(409,88,38,38,'444963')
for yy=-36,36 do local w=math.floor(math.sqrt(38*38-yy*yy));rect(409-w,88+yy,w*2,1,yy< -8 and '77818b' or yy<6 and '647383' or yy<18 and '536477' or '39495f') end
ellipse(393,76,8,4,'879691');ellipse(424,100,11,5,'4b5d74');line(354,94,461,81,'9f96a6');line(356,96,459,83,'777991')
layer('far')
-- Separated fragments with pale comet wake and a root-covered crown.
for _,v in ipairs({{94,171,43},{325,227,30},{558,167,57}}) do local x,y,w=v[1],v[2],v[3]
 poly({{x-w,y},{x+w,y-5},{x+w*.65,y+12},{x+7,y+32},{x-w*.6,y+18}},'3b4359')
 poly({{x-w*.7,y+2},{x,y+5},{x+7,y+28},{x-w*.6,y+18}},'505567')
 puff(x,y-6,w,12,'335e5b','4e7a6b')
 for k=0,3 do line(x-12+k*9,y+8,x-6+k*9,y+29+k*3,'496b67') end
 jungle(x,y,48,'315252','4b7165')
end
layer('middle')
for _,v in ipairs({{15,365,202},{190,382,185},{525,377,235}}) do jungle(v[1],v[2],v[3],'214441','356b53') end
-- Interwoven lower jungle canopy, luminous seed pods and slung lianas.
for x=-20,660,75 do canopy(x,331+(x%3)*4,57,'244c44','387457',nil) end
for _,v in ipairs({{67,120},{232,151},{569,124}}) do
 local x,y=v[1],v[2]
 for yy=y,y+132 do px(x+math.sin((yy-y)/29)*9,yy,'50825e') end
 for k=1,5 do leaf(x+math.sin(k)*7,y+k*20,14,7,k%2==0 and 1 or -1,'427854','699965') end
 ellipse(x+5,y+136,4,6,'5ca68a');ellipse(x+4,y+135,2,3,'9ec6a0')
end
layer('near')
-- Ceiling canopy makes the world feel enclosed by foliage, not by mountains.
for x=-35,680,81 do canopy(x,8+(x%4)*4,61,'173138','28543f',nil) end
for _,x in ipairs({18,610}) do
 poly({{x-12,0},{x+8,0},{x+5,104},{x+19,194},{x+6,271},{x-3,217},{x+2,141}},'172e36')
 for k=0,4 do leaf(x+4,96+k*28,36,15,k%2==0 and 1 or -1,'214b3d','376548') end
end
for x=10,635,86 do for k=0,4 do leaf(x,392,22+k*4,25+k*5,k%2==0 and 1 or -1,'17353a','285844') end end
export('mossy_comet')
-- COPPER CLOUD: a complete skyline of roofs, domes, smokestacks and sky bridges.
math.randomseed(240)
start(640,400,'sky');gradient('545774','e6b58e')
ellipse(467,93,37,37,'d9a28b');ellipse(467,93,30,30,'f1cea1')
for _,v in ipairs({{58,68,93},{269,117,90},{562,150,117}}) do puff(v[1],v[2],v[3],19,'bca0a1','d4b4a9') end
local function tower(x,base,w,h,body,edge,roof,windows,kind)
 rect(x-w*.5,base-h,w,h,body);rect(x-w*.5,base-h,3,h,edge);rect(x+w*.25,base-h,w*.25,h,'665066')
 if kind%3==0 then
  ellipse(x,base-h,w*.57,w*.42,roof)
  for rib=-2,2 do
   for yy=0,math.floor(w*.4) do local f=math.sqrt(math.max(0,1-(yy/(w*.42))^2));px(x+rib*w*.18*f,base-h-yy,mix(roof,edge,.38)) end
  end
  rect(x-w*.58,base-h,w*1.16,4,edge);line(x,base-h-w*.42-11,x,base-h-w*.42,edge)
 elseif kind%3==1 then
  poly({{x-w*.65,base-h},{x,base-h-w*.7},{x+w*.65,base-h}},roof)
  for yy=4,w*.65,5 do local half=yy*.9;line(x-half,base-h-w*.7+yy,x+half,base-h-w*.7+yy,mix(roof,'473949',.21)) end
  line(x-w*.65,base-h,x,base-h-w*.7,edge)
 else
  rect(x-w*.6,base-h-4,w*1.2,5,roof);rect(x-w*.2,base-h-24,w*.4,20,body);rect(x-w*.26,base-h-26,w*.52,3,edge)
 end
 for yy=base-h+12,base-6,17 do
  rect(x-w*.5,yy-4,w,2,roof)
  for xx=x-w*.32,x+w*.25,9 do
   rect(xx-1,yy-1,5,8,mix(body,'302d43',.48));rect(xx,yy,3,6,windows)
   rect(xx,yy+3,3,1,mix(body,roof,.6));rect(xx-1,yy+7,5,1,edge);px(xx,yy,edge)
  end
  for k=0,2 do local xx=x-w*.43+k*w*.25;line(xx,yy+1,xx,yy+5+k,mix(body,'558d81',.3)) end
 end
 rect(x-w*.62,base-4,w*1.24,5,roof)
end
layer('far')
for i=0,16 do local x=i*42-12;local h=45+(i*37)%74;tower(x,281,27+(i%3)*4,h,'927c89','b79898','94727f','c7aba3',i) end
for i=0,6 do puff(i*113,283+(i%2)*9,86,27,'b49aa2','ceb0ad') end
layer('middle')
-- The city has clustered districts with broad spaces between its taller landmarks.
for _,v in ipairs({{47,310,48,156,0},{126,324,34,95,1},{247,318,49,196,1},{305,322,29,100,2},{442,316,60,147,0},{555,323,38,121,2}}) do
 tower(v[1],v[2],v[3],v[4],'886457','d0a07c',v[5]==0 and '598b82' or 'b78360','ecc29b',v[5])
end
-- Copper suspended walkways with rods and repeating railings.
for _,v in ipairs({{65,233,157},{270,252,424},{464,248,541}}) do
 local x,y,xx=v[1],v[2],v[3];rect(x,y,xx-x,4,'9e7b7d');rect(x,y+4,xx-x,3,'674f66');line(x,y-9,xx,y-9,'c29b91')
 for k=x,xx,11 do rect(k,y-9,1,9,'987a81') end
end
for i=0,6 do puff(i*117-8,350+(i%3)*10,85,30,'baa0aa','d9b9b5') end
layer('near')
-- Patinated rooftop silhouettes peek from the lower cloud bank.
for _,x in ipairs({19,375,611}) do tower(x,413,47,58,'55465b','90717a','58847e','bd9e91',2) end
for i=0,6 do puff(i*115,396,89,24,'79697f','a18b99') end
export('copper_cloud')
-- VELVET GLACIER: no sky. A luminous tunnel bored through layered blue/purple ice.
math.randomseed(88)
start(640,400,'sky');gradient('171a3b','383758')
-- Nested, irregular ice vaults pull the eye toward a quiet central glow.
for band=0,5 do
 local cols={'2d2d51','383559','414368','4c527b','58658b','697a9c'}
 local cx,cy=344,218;local rx=302-band*33;local ry=186-band*24
 local points={}
 for j=0,23 do local a=j*math.pi*2/24;local r=1+math.sin(j*7+band*.3)*.045;table.insert(points,{cx+math.cos(a)*rx*r,cy+math.sin(a)*ry*r}) end
 poly(points,cols[band+1])
end
ellipse(347,227,99,72,'768ea8');ellipse(352,238,61,40,'889fb5')
poly({{120,106},{199,73},{239,90},{202,133},{155,154}},'655a87')
poly({{431,133},{494,167},{503,252},{474,217}},'637ea0')
poly({{153,288},{219,315},{273,309},{229,288}},'80739a')
line(125,107,197,76,'8681a8');line(438,142,489,171,'8da9c2')
-- Deep crevasses and pale seams curve around the tunnel wall.
for k=0,8 do local x=45+k*70;line(x,0,x+24,95,'454166');line(x+24,95,x+9,172,'454166');line(x+9,172,x+35,213,'575478') end
ice_inclusions()
layer('far')
local function shard(x,y,w,h,down,base,lit,shade)
 local sign=down and 1 or -1
 poly({{x-w*.5,y},{x+w*.5,y},{x+w*.25,y+sign*h*.64},{x-w*.1,y+sign*h}},base)
 poly({{x-w*.5,y},{x-w*.04,y},{x-w*.1,y+sign*h},{x-w*.25,y+sign*h*.68}},lit)
 poly({{x+w*.17,y},{x+w*.5,y},{x+w*.25,y+sign*h*.64},{x-w*.1,y+sign*h}},shade)
 line(x-w*.22,y+sign*8,x-w*.12,y+sign*h*.65,lit)
 for j=1,4 do local yy=y+sign*h*j*.13;local xx=x-w*.19+j*.3
  line(xx,yy,xx+w*.22,yy+sign*3,mix(base,lit,.32))
 end
 line(x+w*.08,y+sign*h*.17,x+w*.03,y+sign*h*.43,mix(base,lit,.43))
end
for x=-15,675,47 do shard(x,0,50,75+(x*7)%105,true,'55567e','7583a2','3a3c64') end
for x=-15,675,57 do shard(x,400,71,67+(x*3)%71,false,'555b80','778ea8','444667') end
-- A buried blue waterfall of vertical refracted light, not open air.
for k=0,5 do rect(292+k*15,168+(k%3)*5,2,104-k*7,'7188a7') end
layer('middle')
for _,v in ipairs({{20,0,85,247},{147,0,37,128},{524,0,63,157},{624,0,82,267}}) do shard(v[1],v[2],v[3],v[4],true,'3c4168','6b85a3','303054') end
for _,v in ipairs({{78,400,69,164},{179,400,35,102},{474,400,46,134},{592,400,89,174}}) do shard(v[1],v[2],v[3],v[4],false,'45466f','7b86ac','353353') end
-- Fine fractures and little glints imply hard ice rather than rock.
for _,v in ipairs({{35,92},{150,76},{557,106},{605,260},{105,312},{477,326}}) do
 line(v[1]-3,v[2],v[1]+3,v[2],'a0b9cc');line(v[1],v[2]-4,v[1],v[2]+4,'a0b9cc')
end
layer('near')
-- A wrapping ceiling/floor lip encloses the scene at every horizontal scroll position.
poly({{0,0},{640,0},{640,32},{571,28},{522,40},{447,24},{378,31},{311,22},{253,35},{172,26},{96,42},{31,25},{0,32}},'22263f')
for _,v in ipairs({{56,20,28,71},{218,21,17,53},{412,18,27,67},{579,19,20,45}}) do shard(v[1],v[2],v[3],v[4],true,'303c57','4b6b83','202a44') end
poly({{0,378},{93,366},{186,382},{291,368},{375,385},{482,370},{561,384},{640,378},{640,400},{0,400}},'252b48')
export('velvet_glacier')
-- ECHO ORCHARD: bright open country, immense fruit trees and wildflower meadows.
math.randomseed(451)
start(640,400,'sky');gradient('6d94a5','e6d6b2')
ellipse(483,78,28,28,'e4d4ad');ellipse(483,78,22,22,'f3e2b8')
for _,v in ipairs({{94,67,84},{322,113,115},{564,148,76}}) do puff(v[1],v[2],v[3],15,'c5c7b7','e4dcc0') end
layer('far')
-- Long rows recede into warm haze; no mountains or architecture.
poly({{0,243},{95,220},{185,227},{301,212},{408,237},{517,222},{640,243},{640,400},{0,400}},'8eaa98')
for i=0,12 do local x=i*55;orchard(x,262+(i%3)*8,63,25,'7d9b8a','a7b797','cdb994') end
for k=0,5 do
 local yy=277+k*11
 for x=-15,660,34 do ellipse(x+(k%2)*15,yy,20,4,k%2==0 and 'b3bb98' or '95ad8c') end
end
layer('middle')
-- Huge trunks and wide fruit-bearing crowns establish scale against the little player.
for _,v in ipairs({{40,352,219,85},{281,362,233,100},{573,353,206,94}}) do
 orchard(v[1],v[2],v[3],v[4],'577b70','7fa17e','d5a281')
 -- Climbing flower vines on the trunks.
 for k=0,5 do local yy=v[2]-12-k*16;local xx=v[1]+math.sin(k)*8;line(xx,yy,xx+4,yy-16,'94ab82');blossom(xx+5,yy-8,3,'cab3b1','e9d3a5') end
end
-- Giant wildflowers stand between the fruit-tree rows.
for _,v in ipairs({{139,331,102},{393,348,124},{498,339,69}}) do
 local x,y,h=v[1],v[2],v[3]
 poly({{x-3,y},{x-6,y-h*.6},{x-2,y-h},{x+1,y-h},{x-1,y-h*.5},{x+3,y}},'648b73')
 leaf(x,y-h*.32,29,12,1,'7ba381','a7b794');leaf(x-2,y-h*.55,24,10,-1,'7ba381','a7b794')
 blossom(x-2,y-h,14,'c79da8','e7c593');blossom(x-2,y-h,7,'e0b7b4','ecd6a4')
end
poly({{0,334},{79,342},{162,331},{252,344},{367,332},{446,339},{551,329},{640,334},{640,400},{0,400}},'6e947b')
-- Flowers cluster in drifts, with deliberate quiet gaps.
for j=0,74 do local x=(j*79)%640;local y=341+(j*13)%44
 line(x,y+6,x,y,'5c816e');blossom(x,y,2+(j%3)*.5,j%3==0 and 'd2b7bd' or j%3==1 and 'e0c6a0' or 'a9c3b7','e4d2a1')
end
layer('near')
-- Tall garden flowers at the lower edges, never in front of gameplay.
for _,x in ipairs({18,104,365,594}) do
 local y=361+(x%3)*5;line(x,400,x-4,y,'3e665f');leaf(x,390,15,7,1,'527f68','7e9c79');leaf(x,384,17,8,-1,'527f68','7e9c79')
 blossom(x-4,y,9,'b98f9f','e1ba82');blossom(x+12,y+17,6,'d1b5ac','ead4a4')
end
for x=-25,665,61 do leaf(x,404,44,16,1,'456e62','608b6e') end
export('echo_orchard')
