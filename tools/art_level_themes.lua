-- Shotgun Kid / Lantern Ridge. Original pixel art authored by Aseprite's Lua API.
-- Recreates matching source documents. Back up hand-edited sources before running.
local root=app.params['root'] or '.'
local s,im
local wrap_background=false
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
-- Four biomes, shared ink/value structure and 16px terrain grammar.
-- All drawing and exports run in Aseprite; no external raster renderer.
local themes={
 {id='mossy_comet',sky={'141f32','1c3041','294957','396269'},far='36545f',mid='2a4650',near='20363f',light='88bda7',edge='bfd9a4',stone='425b60',shade='2a3c49',facet='55736b',accent='7cac80'},
 {id='copper_cloud',sky={'30263f','634152','9d6370','cd967f'},far='866b7d',mid='69536a',near='473e57',light='cf9980',edge='f5d6aa',stone='966753',shade='493e51',facet='b38062',accent='73a6a2'},
 {id='velvet_glacier',sky={'1c203c','302b50','494163','766381'},far='695979',mid='4d4768',near='343d5d',light='b3bed5',edge='f0e4e7',stone='627d9f',shade='343d66',facet='8ca8bd',accent='c0bbdd'},
 {id='echo_orchard',sky={'30273e','4a354e','755567','ad7e84'},far='85657c',mid='674c66',near='40394e',light='c49a9c',edge='e3c3a2',stone='776371',shade='423a52',facet='948078',accent='af8298'}
}
local function cloud(x,y,w,col)
 ellipse(x,y,w,7,col);ellipse(x-w*.35,y-6,w*.40,10,col);ellipse(x+w*.3,y-5,w*.34,8,col)
 rect(x-w,y,w*2,5,col)
end
local function mountain(x,y,w,h,col)
 poly({{x-w,y+h},{x-w*.52,y+h*.46},{x-w*.25,y+h*.40},{x,y},{x+w*.18,y+h*.20},{x+w*.28,y+h*.18},{x+w,y+h}},col)
end
local function arch(x,y,w,h,thick,col)
 rect(x,y+h*.35,thick,h*.65,col);rect(x+w-thick,y+h*.35,thick,h*.65,col)
 -- A pixel-stepped lintel with open air beneath it.
 rect(x+thick,y+h*.2,w-2*thick,thick,col);rect(x+thick*.5,y+h*.28,thick,thick,col);rect(x+w-thick*1.5,y+h*.28,thick,thick,col)
end
local function tree(x,y,k,col,highlight,fruit)
 local w=26*k
 poly({{x-4*k,y},{x-2*k,y-46*k},{x-13*k,y-66*k},{x-9*k,y-68*k},{x+2*k,y-50*k},{x+15*k,y-73*k},{x+18*k,y-70*k},{x+4*k,y-42*k},{x+5*k,y}},col)
 for _,v in ipairs({{-18,-67,20,12},{12,-76,23,15},{28,-63,19,12},{-1,-58,28,13}}) do ellipse(x+v[1]*k,y+v[2]*k,v[3]*k,v[4]*k,col) end
 for _,v in ipairs({{-23,-72,12,4},{7,-85,14,4},{29,-69,10,3}}) do ellipse(x+v[1]*k,y+v[2]*k,v[3]*k,v[4]*k,highlight) end
 -- Small overlapping leaf clusters break the elliptical contour.
 for j=0,8 do
  local xx=x+(-31+j*8)*k;local yy=y+(-64-((j*7)%17))*k
  ellipse(xx,yy,6*k,3*k,highlight)
  rect(xx-2*k,yy-1*k,3*k,1*k,highlight)
 end
 line(x-1*k,y-38*k,x-1*k,y-5*k,highlight)
 if fruit then for _,v in ipairs({{-25,-63},{-8,-69},{9,-64},{27,-60},{18,-77}}) do rect(x+v[1]*k,y+v[2]*k,2,3,fruit) end end
end
local function export_background(t)
 wrap_background=false
 -- Each layer is an independent full-width plane, with terrain filling the bottom.
 -- No opaque seams: horizontal ground profiles begin/end at the same height.
 s:saveAs(root..'/assets/source/'..t.id..'_backdrop.aseprite')
 local layers={};for _,l in ipairs(s.layers) do table.insert(layers,l) end
 for _,l in ipairs(layers) do
  for _,other in ipairs(layers) do other.isVisible=(other==l) end
  s:saveCopyAs(root..'/assets/textures/'..t.id..'_'..l.name..'.png')
 end
 s:close()
end
for index,t in ipairs(themes) do
 math.randomseed(731+index*103)
 wrap_background=true
 start(640,400,'sky')
 -- A restrained stepped gradient avoids visible horizon stripes behind the art.
 for y=0,399 do
  local v=math.min(2.999,math.floor(y/10)*10/360*3)
  local seg=math.floor(v)+1;local blend=v-math.floor(v)
  local a,b=c(t.sky[seg]),c(t.sky[seg+1])
  local tone=Color{r=math.floor(a.red+(b.red-a.red)*blend),g=math.floor(a.green+(b.green-a.green)*blend),b=math.floor(a.blue+(b.blue-a.blue)*blend)}
  rect(0,y,640,1,tone)
 end
 if index==1 then
  layer('celestial');
  -- Long tapered comet with a compact luminous head, not a beam across play space.
  poly({{286,76},{471,20},{444,39},{300,91}},'3d6870')
  poly({{286,79},{445,32},{320,84},{290,90}},'659d99')
  poly({{288,82},{389,52},{308,87},{290,88}},'a1cbb3')
  ellipse(290,85,8,7,'6baba1');ellipse(290,85,4,4,'d0e3be');px(288,83,'f1edd4')
  for i=1,43 do local x=math.random(8,630);local y=math.random(12,128);px(x,y,'779b9c');if i%8==0 then rect(x-1,y,3,1,'a1bfb1');rect(x,y-1,1,3,'a1bfb1') end end
  -- Merge celestial into sky for one static composition.
  app.command.MergeDownLayer()
 elseif index==2 then
  ellipse(457,99,35,35,'bc8583');ellipse(457,99,28,28,'edb993')
  rect(421,104,72,3,t.sky[2]);rect(422,113,70,2,t.sky[2])
  for _,v in ipairs({{76,61,62},{254,119,82},{544,155,74},{91,179,93}}) do cloud(v[1],v[2],v[3],'936576');rect(v[1]-v[3]*.7,v[2]-1,v[3]*1.3,1,'b78084') end
 elseif index==3 then
  for ribbon=0,2 do
   local col=({'385968','506979','7a7e99'})[ribbon+1]
   for x=0,639 do local y=48+math.sin(x/108+ribbon*.55)*22+ribbon*12;rect(x,y,1,4+math.sin(x/87)*2,col) end
  end
  for yy=48,82 do for xx=487,521 do if (xx-504)^2+(yy-65)^2<=17^2 and (xx-498)^2+(yy-59)^2>16^2 then px(xx,yy,'afacc5') end end end
  for i=1,65 do px(math.random(5,634),math.random(12,145),i%5==0 and 'd6d3df' or '7e819f') end
 else
  ellipse(401,87,26,26,'b68a99');ellipse(401,87,22,22,'e1b4a8');ellipse(394,81,5,3,'c89da4')
  for _,v in ipairs({{73,91,64},{257,52,49},{540,133,78}}) do cloud(v[1],v[2],v[3],'765369');rect(v[1]-v[3]*.5,v[2],v[3],1,'aa7f8c') end
 end
 layer('far')
 if index==1 then
  for _,v in ipairs({{40,153,98,136},{208,132,100,165},{403,177,105,118},{569,140,93,146}}) do
   mountain(v[1],v[2],v[3],v[4],t.far)
   poly({{v[1],v[2]},{v[1]+22,v[2]+57},{v[1]+v[3]*.7,v[2]+v[4]},{v[1]+6,v[2]+v[4]}},'2e4a57')
  end
  poly({{0,254},{87,250},{172,270},{303,249},{440,266},{542,253},{640,254},{640,400},{0,400}},t.far)
  for x=28,625,86 do arch(x,208,53,99,9,'3d5f65');rect(x+5,224,42,2,'50777a') end
 elseif index==2 then
  -- Horizontal cloud ocean contrasts with tall foundry silhouettes.
  for i=0,7 do cloud(i*103-22,221+(i%3)*14,78,t.far) end
  rect(0,248,640,152,t.far)
  for _,v in ipairs({{64,151,27},{191,116,24},{353,166,32},{570,143,22}}) do
   rect(v[1],v[2],v[3],93,'796178');rect(v[1]-4,v[2],v[3]+8,5,'ab7d86');rect(v[1]+6,v[2]-18,5,18,'796178')
   for yy=v[2]+12,v[2]+65,15 do rect(v[1]+5,yy,v[3]-10,2,'a47b84') end
  end
  for x=0,639 do px(x,270+math.sin(x/53)*3,'a8818b') end
 elseif index==3 then
  for _,v in ipairs({{24,125,95,180},{184,93,108,208},{365,147,88,150},{539,103,119,190}}) do
   mountain(v[1],v[2],v[3],v[4],t.far)
   poly({{v[1],v[2]},{v[1]-v[3]*.26,v[2]+v[4]*.4},{v[1]-4,v[2]+v[4]*.29},{v[1]+v[3]*.23,v[2]+v[4]*.32}},'a299b3')
   poly({{v[1],v[2]},{v[1]+v[3]*.23,v[2]+v[4]*.32},{v[1]+v[3],v[2]+v[4]},{v[1]+9,v[2]+v[4]}},'514d70')
  end
  rect(0,290,640,110,t.far)
 else
  for i=-1,7 do local x=i*110;ellipse(x,264+(i%2)*12,105,69,t.far) end
  rect(0,278,640,122,t.far)
  for i=0,7 do tree(i*89,266+(i%3)*9,.82,'76596f','947285',nil) end
  -- The distant orchard's ruined watercourse.
  for x=18,630,66 do arch(x,244,48,63,7,'a17b89') end
 end
 layer('middle')
 if index==1 then
  poly({{0,304},{70,301},{129,277},{173,289},{244,314},{342,298},{399,274},{459,302},{549,288},{640,304},{640,400},{0,400}},t.mid)
  for _,v in ipairs({{67,299,1.0},{185,310,.72},{462,300,.84},{588,302,1.0}}) do
   local x,y,k=v[1],v[2],v[3]
   rect(x,y-92*k,15*k,92*k,t.mid);rect(x-7*k,y-94*k,28*k,10*k,'3d6261')
   rect(x+2*k,y-76*k,3*k,68*k,'385955');for j=1,4 do rect(x+4*k,y-(12+j*14)*k,9*k,1,'203b45') end;rect(x-8*k,y-95*k,30*k,3*k,'688a72')
   line(x+8*k,y-89*k,x+22*k,y-39*k,'4a7464');ellipse(x+21*k,y-41*k,6*k,3*k,'557f66')
  end
  for i=0,8 do local x=i*80+12;ellipse(x,301,30,11,'335750');ellipse(x-8,294,17,6,'466e5c') end
 elseif index==2 then
  for _,v in ipairs({{80,277,78},{300,294,69},{498,269,82}}) do
   local x,y,w=v[1],v[2],v[3]
   poly({{x-w,y},{x+w,y},{x+w*.7,y+16},{x+14,y+39},{x-19,y+29},{x-w*.7,y+16}},t.mid)
   rect(x-w,y-4,w*2,5,'ab7b78');rect(x-w+7,y+6,w*2-14,2,'80606c')
   rect(x-22,y-56,44,52,t.mid);rect(x-26,y-58,52,5,'ac7d78')
   rect(x-13,y-50,6,35,'886877');rect(x+10,y-50,6,35,'886877')
   rect(x-5,y-78,10,20,t.mid);rect(x-10,y-79,20,3,'bc8e85')
   line(x+27,y-6,x+49,y-64,'7b626f');line(x+49,y-64,x+69,y-64,'ab807d')
  end
  for i=0,5 do cloud(i*130,344+(i%2)*14,94,t.mid) end
  rect(0,360,640,40,t.mid)
 elseif index==3 then
  for _,v in ipairs({{16,233,58,115},{145,214,53,138},{289,251,70,101},{437,212,63,141},{590,245,70,115}}) do
   local x,y,w,h=v[1],v[2],v[3],v[4]
   poly({{x-w,y+24},{x-w*.6,y+8},{x+6,y},{x+w,y+35},{x+w*.8,y+h},{x-w,y+h}},t.mid)
   poly({{x-w,y+24},{x+6,y},{x+6,y+12},{x-w*.6,y+34}},'a098b7')
   poly({{x+6,y+12},{x+w,y+35},{x+w*.8,y+h},{x+19,y+h}},'3e4669')
   line(x-17,y+34,x-9,y+88,'716a91');line(x-9,y+88,x+2,y+95,'716a91')
  end
  rect(0,350,640,50,t.mid)
 else
  poly({{0,311},{105,295},{206,313},{312,289},{419,311},{523,290},{640,311},{640,400},{0,400}},t.mid)
  for i=0,5 do tree(i*123+22,318+(i%2)*9,1.22,t.mid,'936b82','bb9196') end
  -- Layered orchard terraces, interrupted stones instead of a hard full-width stripe.
  for i=0,15 do local x=i*44;rect(x,336+(i%2)*3,32,3,'856477');rect(x+4,342+(i%2)*3,18,1,'4b405a') end
 end
 layer('near')
 -- Darker framing at the bottom stays behind the playable silhouette.
 poly({{0,367},{80,356},{166,370},{257,350},{357,366},{457,355},{546,374},{640,367},{640,400},{0,400}},t.near)
 if index==1 then
  for _,x in ipairs({34,227,518}) do
   poly({{x-7,386},{x-4,312},{x-18,292},{x-14,289},{x+2,307},{x+17,274},{x+20,277},{x+5,315},{x+9,386}},t.near)
   ellipse(x-11,292,23,10,t.near);ellipse(x+16,275,27,13,t.near);ellipse(x+4,282,20,9,'294c48')
  end
  for i=1,15 do local x=(i*43)%640;rect(x,356+(i%3)*6,1,2,'739c78') end
 elseif index==2 then
  for _,x in ipairs({20,392,599}) do
   rect(x,342,9,58,t.near);rect(x-8,340,25,5,'725964');rect(x+3,322,3,18,t.near)
   line(x+4,329,x+23,333,'987376');line(x+4,329,x-13,334,'987376')
  end
  for i=0,5 do cloud(i*139+20,388,83,t.near) end
 elseif index==3 then
  for _,v in ipairs({{44,313,24},{229,333,18},{568,306,29}}) do
   local x,y,w=v[1],v[2],v[3];poly({{x-w,390},{x-6,y},{x+4,y-9},{x+w,390}},t.near)
   poly({{x-6,y},{x+4,y-9},{x+2,384},{x-8,390}},'57738c');line(x-6,y,x-12,y+56,'89a8b6')
  end
 else
  for _,x in ipairs({-8,326,635}) do tree(x,402,.93,t.near,'64465f','b17c86') end
 end
 export_background(t)
 wrap_background=false
 -- Native atlas: preserve source ID 0 and the established 8 x 4 cell coordinates.
 start(128,64,'Stone silhouette')
 for ty=0,3 do for tx=0,7 do
  local x,y=tx*16,ty*16
  if ty==3 then
   poly({{x,y},{x+16,y},{x+14,y+5},{x+11,y+5},{x+9,y+12},{x+6,y+9},{x+2,y+7}},t.shade)
   if index==1 or index==4 then
    line(x+4,y,x+5,y+10,t.accent);line(x+5,y+10,x+8,y+14,t.shade);line(x+12,y,x+11,y+8,t.facet)
   elseif index==2 then
    rect(x+4,y,3,8,t.stone);rect(x+9,y,2,13,t.facet);rect(x+3,y+8,5,2,t.accent)
   else poly({{x+2,y},{x+7,y},{x+5,y+15}},t.facet);line(x+3,y,x+4,y+9,t.edge) end
  else
   rect(x,y,16,16,t.shade);rect(x+1,y+1,14,14,t.stone)
   if index~=2 then rect(x,y,16,16,t.stone) end
   if index==1 then
    local shift=(tx*3+ty*5)%6
    poly({{x,y+3+shift},{x+7,y+1},{x+15,y+5},{x+13,y+11+shift*.5},{x+3,y+15}},t.facet)
    line(x+2,y+3+shift,x+7,y+2,t.light);line(x+12,y+5,x+9,y+9+shift,t.shade);line(x+9,y+9+shift,x+3,y+14,t.shade)
    if tx%3==0 then rect(x+3,y+9,3,2,t.accent) end
   elseif index==2 then
    rect(x+2,y+2,12,1,t.light);rect(x+2,y+3,1,10,t.facet);rect(x+3,y+13,11,1,t.shade)
    px(x+3,y+4,t.edge);px(x+12,y+11,t.edge);px(x+4,y+5,t.shade);px(x+13,y+12,t.shade)
    if tx%3==1 then rect(x+7,y+3,2,10,t.shade);rect(x+8,y+4,1,7,t.accent) else line(x+5,y+7,x+9,y+6,t.facet) end
   elseif index==3 then
    local shift=(tx*5+ty*3)%9
    poly({{x+shift,y},{x+shift+3,y},{x+shift+1,y+16},{x+shift-2,y+16}},'7492ad')
    if tx%3==0 then line(x+shift,y+2,x+shift-1,y+7,t.light);line(x+12,y+7,x+8,y+12,'526d92');line(x+8,y+12,x+9,y+15,'526d92') end
    if tx%4==0 then px(x+11,y+3,t.edge) end
   else
    local shift=tx%3
    rect(x,y+1+shift,15,2,t.facet);line(x+1,y+4,x+1,y+10,t.light);line(x,y+13-shift,x+13,y+13-shift,t.shade)
    if tx%2==0 then line(x+11,y,x+9,y+7,t.shade);line(x+9,y+7,x+15,y+10,t.shade);line(x+10,y,x+8,y+7,'b18f86') end
    rect(x+4,y+7,3,1,t.facet)
   end
   if ty==2 then rect(x,y+14,16,2,t.shade) end
  end
 end end
 layer('Surface and material accents')
 for tx=0,7 do local x=tx*16
  rect(x,0,16,2,t.edge);rect(x,2,16,2,t.accent)
  if index==1 then
   rect(x,4,16,1,'486e57');rect(x+2,3,3,4,t.accent);rect(x+11,3,2,6,'628e6b');rect(x+4,0,5,1,'d6e5af')
  elseif index==2 then
   rect(x,3,16,2,'7e5b57');rect(x+2,4,3,2,t.accent);rect(x+11,4,2,2,'d3a77d');px(x+3,1,'fff0c7')
  elseif index==3 then
   rect(x+2,3,5,2,'d2d6e4');rect(x+11,2,3,4,'9dbace');rect(x+12,5,1,3,t.light);rect(x+2,0,6,1,'fff4ed')
  else
   rect(x,3,16,2,'92757c');rect(x+4,1,3,2,'c7ad94');rect(x+11,3,2,4,'9e9090');if tx%3==0 then px(x+7,1,'f3d6c8') end
  end
 end
 save(t.id..'_terrain')
 -- A second, non-solid atlas for foliage / architectural ornament, 32px cells.
 start(128,64,'Decorations')
 for slot=0,7 do
  local x=(slot%4)*32;local y=math.floor(slot/4)*32;local kind=slot%4
  if index==1 then
   if kind==0 then
    line(x+16,y+30,x+13,y+5,'50765e');for k=0,5 do local yy=y+9+k*3;line(x+14,yy,x+5+k,yy-4,'8bb785');line(x+14,yy+2,x+24-k,yy-2,'638e70') end
   elseif kind==1 then
    rect(x+8,y+12,3,18,'698f81');rect(x+20,y+20,2,10,'698f81');ellipse(x+9,y+12,8,4,'65a9a0');rect(x+3,y+10,9,1,'c2dcaf');ellipse(x+21,y+20,6,3,'598c91')
   elseif kind==2 then
    poly({{x+8,y+30},{x+7,y+12},{x+11,y+8},{x+21,y+10},{x+24,y+30}},t.shade);rect(x+9,y+12,12,16,t.stone);rect(x+10,y+13,3,13,t.light);rect(x+7,y+9,15,3,t.accent)
   else for k=0,3 do line(x+6+k*6,y,x+8+k*6,y+18+k*3,'648d70');ellipse(x+7+k*6,y+8+k*4,3,2,'96b886') end end
  elseif index==2 then
   if kind==0 then
    rect(x+6,y+26,21,4,t.shade);rect(x+9,y+21,15,5,t.stone);rect(x+14,y+7,4,16,t.facet);rect(x+8,y+5,16,4,t.edge);rect(x+10,y+4,12,2,t.accent)
   elseif kind==1 then
    rect(x+8,y+8,5,22,t.stone);rect(x+8,y+8,16,5,t.facet);rect(x+21,y+8,4,11,t.stone);rect(x+7,y+23,7,3,t.accent);rect(x+20,y+16,7,3,t.accent)
   elseif kind==2 then
    rect(x+10,y+28,12,3,t.shade);ring(x+16,y+17,11,4,t.stone);ring(x+16,y+17,7,1,t.edge);for k=0,3 do local a=k*math.pi/2;rect(x+14+math.cos(a)*11,y+15+math.sin(a)*11,4,4,t.facet) end
   else
    rect(x+4,y+25,24,5,t.shade);rect(x+8,y+14,16,11,t.stone);rect(x+10,y+16,12,2,t.accent);rect(x+12,y+4,3,10,t.facet);rect(x+19,y+9,3,5,t.facet)
   end
  elseif index==3 then
   for k=0,2 do local xx=x+5+k*8;local h=12+((slot+k*3)%5)*3
    poly({{xx,y+30},{xx-3,y+30-h},{xx+2,y+26-h},{xx+7,y+30}},t.shade)
    poly({{xx,y+30},{xx-2,y+30-h},{xx+2,y+26-h},{xx+2,y+30}},t.facet);line(xx-1,y+29-h,xx+1,y+27-h,t.edge)
   end
   if kind==3 then rect(x+3,y+28,26,3,t.light);rect(x+6,y+28,19,1,t.edge) end
  else
   if kind==0 then
    for k=0,3 do line(x+7+k*6,y+30,x+5+k*6,y+18-k%2*6,'7f8881');ellipse(x+5+k*6,y+18-k%2*6,3,2,'d4a6ad');px(x+5+k*6,y+17-k%2*6,t.edge) end
   elseif kind==1 then
    ellipse(x+16,y+24,13,7,'6c6e69');ellipse(x+11,y+19,9,6,'969085');ellipse(x+22,y+21,7,5,'847b79');for k=0,2 do ellipse(x+8+k*7,y+22+k%2*4,2,2,'d59391') end
   elseif kind==2 then
    rect(x+6,y+27,20,3,t.shade);rect(x+11,y+10,10,17,t.stone);rect(x+8,y+7,16,4,t.facet);rect(x+11,y+8,10,1,t.edge);rect(x+14,y+15,3,7,t.shade)
   else
    rect(x+5,y+25,23,5,'5e4d60');rect(x+7,y+21,19,4,'a88177');for k=0,3 do ellipse(x+9+k*4,y+21-k%2*3,3,3,'d39794');px(x+9+k*4,y+18-k%2*3,'ead0ab') end
   end
  end
 end
 save(t.id..'_decor')
 start(6,6,'Ambient mote')
 if index==1 then px(2,2,'bbd5a0');px(2,3,'719b83')
 elseif index==2 then line(1,4,3,2,'d7a382');px(3,2,'f5d6aa')
 elseif index==3 then rect(2,1,1,3,'d1d5e3');rect(1,2,3,1,'9bb9ce')
 else poly({{1,2},{3,1},{4,3},{2,4}},'c8a0ae');px(2,2,'edd0c7') end
 save(t.id..'_mote')
end

-- Keep the full art rebuild aligned with the current background direction.
dofile(root.."/tools/art_biome_backgrounds.lua")
