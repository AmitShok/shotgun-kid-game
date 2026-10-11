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

local ink='202139'
local hats={'Rose Beanie','Trail Cap','Forest Beret','Copper Crown','Sun Hat','Aviator','Miner Helmet','Moon Wizard','Cat Hood','Headphones','Flower Crown','Snow Pom','Bareheaded'}
local outfits={'Trail Coat','Denim Overalls','Rain Slicker','Flight Jacket','Striped Tee','Explorer Vest','Royal Tunic','Mechanic','Snow Parka','Comet Suit','Poncho','Track Jacket'}
local scarves={'Lagoon','Ember','Sunflower','Violet','Cloud','Moss','Candy Stripe','Checkered','Copper','Midnight Stars','Orchard Bloom','Glacier','No Scarf'}
local cloth={
 {'d39468','94617a','edba82'}, {'517aa5','344b73','92c7cc'}, {'ecc65e','ba804b','fff2a3'}, {'7c665b','494753','bca186'},
 {'e9d9b6','9f8d94','fff3da'}, {'779267','465b65','bccb83'}, {'9972ad','594d85','e0b4cc'}, {'5c969b','325c75','98d5c6'},
 {'ece6d3','8babc0','fff4dc'}, {'a59abf','60618e','dfe0f2'}, {'c16f69','7f425b','f3ad87'}, {'c36f99','754874','f6b0ba'} }
local scarfcols={
 {'72ccca','438fa4','a4e9d6'}, {'e57469','934963','ffbd8b'}, {'efcb68','a7834e','fff0ab'}, {'aa86cf','615789','e5b7ee'},
 {'e4e9d7','8aa6b1','ffffff'}, {'83ad77','466c68','c5df92'}, {'df8495','894d77','ffdfc6'}, {'ddd6b4','466277','fff1d2'},
 {'c99263','805b61','efcf94'}, {'647db2','394c76','b6ceee'}, {'d99fc3','976585','ffdeea'}, {'9ecfe0','638cad','def8f4'} }
-- Outfit atlas: twelve separately detailed garments, eight movement frames each.
start(192,288,'Body, face and boots')
for v=0,11 do for f=0,7 do
 local x,y=f*24,v*24;local b=(f==1 or f==3 or f==5) and 1 or 0
 rect(x+7,y+7+b,11,7,ink);rect(x+7,y+7+b,10,4,'443048');rect(x+9,y+9+b,8,4,'efba99');rect(x+16,y+10+b,3,2,'f8d6af');px(x+15,y+9+b,ink);px(x+15,y+10+b,ink);rect(x+10,y+12+b,5,1,'bd7b80')
 rect(x+6,y+13+b,11,8-b,ink)
 local a,d,h=table.unpack(cloth[v+1]);rect(x+7,y+13+b,9,7-b,a);rect(x+7,y+14+b,2,5-b,h);rect(x+14,y+14+b,2,6-b,d)
 if v==0 then rect(x+11,y+14+b,1,6-b,'664b68');px(x+12,y+16,'fff0b6')
 elseif v==1 then rect(x+7,y+13+b,9,2,'e8c292');rect(x+9,y+14+b,1,4,h);rect(x+13,y+14+b,1,4,h);rect(x+10,y+16,3,2,d)
 elseif v==2 then rect(x+11,y+14+b,1,6-b,d);rect(x+7,y+19,9,2,h);px(x+12,y+16,'fff5ca');px(x+12,y+18,'fff5ca')
 elseif v==3 then rect(x+10,y+14+b,3,5,'e1cbaa');rect(x+7,y+19,9,2,d);rect(x+8,y+16,2,2,h)
 elseif v==4 then for yy=14+b,19,2 do rect(x+7,y+yy,9,1,'bf687e') end
 elseif v==5 then rect(x+10,y+13+b,3,7,'e2cba0');rect(x+7,y+16,2,2,d);rect(x+14,y+16,2,2,h)
 elseif v==6 then rect(x+10,y+13+b,2,7,'eac880');rect(x+7,y+18,9,1,'eac880');px(x+12,y+15,'fff0bc')
 elseif v==7 then rect(x+10,y+14+b,1,6,d);rect(x+12,y+15,2,2,h);rect(x+7,y+19,9,1,'d9a45e')
 elseif v==8 then rect(x+7,y+13+b,9,2,'ffffff');rect(x+7,y+19,9,2,h);rect(x+11,y+15,1,4,d)
 elseif v==9 then rect(x+10,y+14+b,4,4,d);rect(x+11,y+15,2,1,'72ccca');px(x+12,y+17,'ef8490');rect(x+7,y+19,9,1,h)
 elseif v==10 then rect(x+5,y+15,13,5,a);rect(x+6,y+18,11,1,h);rect(x+8,y+16,7,1,d);px(x+11,y+17,h)
 else rect(x+11,y+14+b,1,6,'eee5ce');rect(x+7,y+14+b,2,1,'eee5ce');rect(x+7,y+18,9,1,d) end
 rect(x+7,y+20,9,1,'485b73');rect(x+14,y+15+b,4,3,'efba99');px(x+17,y+15+b,'ffe2b7')
 local left,right=7,13
 if f>=2 and f<=5 then left=({5,7,9,7})[f-1];right=({15,13,11,13})[f-1] end
 if f==6 then left=6;right=14 end
 rect(x+left,y+20,4,2,'34465f');rect(x+right,y+20,4,2,'34465f');rect(x+left-1,y+22,5,1,ink);rect(x+right,y+22,5,1,ink);px(x+left,y+21,'94adb4');px(x+right,y+21,'94adb4')
end end
save('wardrobe_outfits')
start(192,312,'Independent headwear')
for v=0,11 do for f=0,7 do
 local x,y=f*24,v*24;local b=(f==1 or f==3 or f==5) and 1 or 0;y=y+b
 if v==0 then
  rect(x+6,y+3,12,6,ink);rect(x+8,y+2,8,1,'f4b596');rect(x+6,y+4,11,4,'d75c70');rect(x+8,y+3,8,2,'ef8490');rect(x+6,y+7,13,2,'a63f62');rect(x+7,y+7,10,1,'ffae9c');rect(x+9,y+3,1,4,'fbb09f')
 elseif v==1 then
  rect(x+7,y+3,11,5,ink);rect(x+8,y+3,8,4,'689592');rect(x+9,y+3,4,1,'a3cbc0');rect(x+7,y+7,15,2,ink);rect(x+11,y+7,10,1,'9ebdad');px(x+15,y+5,'e6c481')
 elseif v==2 then
  ellipse(x+11,y+5,7,3,ink);ellipse(x+11,y+4,6,2,'648568');rect(x+8,y+6,9,2,'47646a');rect(x+9,y+2,4,1,'afbe84');px(x+12,y+1,'c7d597')
 elseif v==3 then
  rect(x+6,y+3,13,6,ink);rect(x+7,y+4,11,4,'c78c60');rect(x+7,y+2,2,3,'f1d48b');rect(x+12,y+1,2,4,'f1d48b');rect(x+17,y+2,2,3,'f1d48b');rect(x+7,y+7,11,1,'f1d48b');px(x+12,y+6,'8bd7c7');px(x+16,y+6,'d87787')
 elseif v==4 then
  rect(x+7,y+3,10,5,ink);rect(x+8,y+3,8,4,'d8b377');rect(x+8,y+6,9,2,'92627c');rect(x+3,y+8,19,2,ink);rect(x+4,y+8,17,1,'f1d29a');rect(x+9,y+3,5,1,'fff0bc')
 elseif v==5 then
  rect(x+6,y+3,13,6,ink);rect(x+7,y+4,11,4,'886964');rect(x+6,y+7,3,6,ink);rect(x+7,y+8,2,4,'ba936f');rect(x+8,y+5,10,3,'ead6a6');rect(x+9,y+5,3,2,'72aab7');rect(x+14,y+5,3,2,'72aab7');px(x+10,y+5,'c0e7de');px(x+15,y+5,'c0e7de')
 elseif v==6 then
  ellipse(x+12,y+6,6,4,ink);ellipse(x+12,y+5,5,3,'d5b360');rect(x+6,y+7,14,2,'81627b');rect(x+7,y+7,12,1,'eacd80');rect(x+14,y+3,4,4,ink);rect(x+15,y+4,2,2,'d7f3dc')
 elseif v==7 then
  poly({{x+5,y+7},{x+10,y},{x+14,y+2},{x+18,y+8}},ink);poly({{x+7,y+6},{x+11,y+1},{x+15,y+4},{x+17,y+7}},'8875b7');rect(x+4,y+8,18,2,ink);rect(x+5,y+8,16,1,'b49acd');px(x+11,y+4,'eed893');px(x+13,y+6,'eed893')
 elseif v==8 then
  rect(x+6,y+3,13,6,ink);poly({{x+6,y+5},{x+5,y},{x+10,y+3}},ink);poly({{x+14,y+3},{x+19,y},{x+19,y+6}},ink);rect(x+7,y+4,11,4,'697e9b');px(x+7,y+2,'d6a0b5');px(x+17,y+2,'d6a0b5');rect(x+6,y+8,3,4,'697e9b')
 elseif v==9 then
  rect(x+6,y+4,13,2,ink);rect(x+7,y+3,10,2,'ba87ab');rect(x+6,y+6,3,6,ink);rect(x+7,y+7,3,4,'a776ab');rect(x+7,y+7,1,3,'e2bad3');rect(x+17,y+6,3,4,ink);rect(x+18,y+7,1,2,'d79ab4')
 elseif v==10 then
  rect(x+6,y+6,13,2,'628b76');for xx=7,17,5 do rect(x+xx,y+4,3,3,'efadc0');px(x+xx+1,y+5,'ffe6a2');px(x+xx,y+3,'f4cede') end
 elseif v==11 then
  ellipse(x+12,y+3,3,2,'e6eddf');rect(x+6,y+5,12,4,ink);rect(x+7,y+5,10,3,'81bac6');rect(x+6,y+8,13,2,'dbe6da');rect(x+9,y+5,1,3,'c3e2de');rect(x+13,y+5,1,3,'c3e2de')
 end
end end
save('wardrobe_hats')
start(192,312,'Scarf neck wraps')
for v=0,11 do for f=0,7 do
 local x,y=f*24,v*24;local b=(f==1 or f==3 or f==5) and 1 or 0;local a,d,h=table.unpack(scarfcols[v+1])
 rect(x+7,y+12+b,9,2,a);rect(x+7,y+14+b,4,1,d);rect(x+8,y+12+b,7,1,h)
 if v==6 or v==7 then for xx=7,15,3 do rect(x+xx,y+12+b,1,2,d) end end
 if v==10 then px(x+12,y+13+b,'ffe2a4') end
end end
save('wardrobe_necks')
start(5,36,'Woven trailing scarf patterns')
for v=0,11 do
 local a,d,h=table.unpack(scarfcols[v+1]);rect(0,v*3,5,1,h);rect(0,v*3+1,5,1,a);rect(0,v*3+2,5,1,d)
 if v==6 then rect(2,v*3,1,3,'ffe5cc') elseif v==7 then px(1,v*3+1,d);px(3,v*3+1,d);px(2,v*3,d) elseif v==9 then px(2,v*3+1,'fff1bd') elseif v==10 then px(3,v*3+1,'ffe2a4') end
end
save('wardrobe_tails')
start(64,64,'Dressing room backdrop')
rect(0,0,64,64,'172638');rect(1,1,62,62,'263c50');rect(3,3,58,58,'1d3043')
for yy=7,43,8 do rect(6,yy,52,1,'23384b') end
rect(8,49,48,3,ink);rect(10,47,44,2,'94bfb9');rect(11,49,42,6,'3c596b');rect(13,54,38,2,'172638');rect(28,58,8,1,'547a89');rect(6,8,1,35,'3c596b');rect(57,8,1,35,'3c596b')
save('wardrobe_stage')
start(7,7,'Equipped marker');line(1,3,3,5,'a4e9d6');line(3,5,6,1,'a4e9d6');save('wardrobe_check')
-- One stable catalogue accompanies the art exports.
local cat={hats={},scarves={},outfits={}}
local function slug(name) return name:lower():gsub(' ','_') end
for i,name in ipairs(hats) do table.insert(cat.hats,{id=slug(name),name=name,row=i-1}) end
for i,name in ipairs(scarves) do table.insert(cat.scarves,{id=slug(name),name=name,row=i-1,length=({2.7,2.5,2.8,3.0,2.4,2.7,3.1,2.5,2.6,3.0,2.9,2.8,0})[i]}) end
for i,name in ipairs(outfits) do table.insert(cat.outfits,{id=slug(name),name=name,row=i-1}) end
local file=io.open(root..'/data/wardrobe.json','w');file:write(json.encode(cat));file:close()
print('Wardrobe: 12 hats + bareheaded, 12 scarves + none, 12 outfits; all Aseprite sources exported.')

local gd=io.open(root..'/data/wardrobe_items.gd','w');gd:write('extends RefCounted\nconst ITEMS = '..json.encode(cat)..'\n');gd:close()
