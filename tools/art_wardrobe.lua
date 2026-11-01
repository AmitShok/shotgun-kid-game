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
-- Sixteen 24x24 frames per row, driven by one pose table shared by body, hats and neck wraps:
-- idle 0-3, run 4-9, rise 10, apex 11, fall 12-13, land 14, skid 15.
-- h: head offset, t: torso offset, b/f: back/front boot top-left, a: back hand, tail: coat tail sway.
local FRAMES=16
local poses={
 {h={0,0},t={0,0},b={8,21},f={13,21},a={9,18},tail=0},
 {h={0,0},t={0,0},b={8,21},f={13,21},a={9,18},tail=0},
 {h={0,1},t={0,1},b={8,21},f={13,21},a={9,19},tail=0},
 {h={0,1},t={0,0},b={8,21},f={13,21},a={9,18},tail=0},
 {h={1,0},t={1,0},b={5,20},f={15,21},a={12,17},tail=-1},
 {h={1,1},t={1,1},b={6,19},f={13,21},a={11,18},tail=-2},
 {h={1,0},t={1,0},b={10,19},f={10,21},a={10,18},tail=-1},
 {h={1,0},t={1,0},b={15,21},f={5,20},a={7,17},tail=-1},
 {h={1,1},t={1,1},b={13,21},f={6,19},a={8,18},tail=-2},
 {h={1,0},t={1,0},b={10,21},f={10,19},a={9,18},tail=-1},
 {h={0,-1},t={0,-1},b={8,19},f={13,20},a={8,13},tail=1},
 {h={0,0},t={0,0},b={7,20},f={14,19},a={7,15},tail=0},
 {h={0,0},t={0,0},b={8,21},f={14,20},a={7,13},tail=-1},
 {h={0,0},t={0,0},b={9,21},f={13,21},a={8,12},tail=-2},
 {h={0,2},t={0,2},b={6,21},f={15,21},a={9,19},tail=1},
 {h={-1,0},t={-1,0},b={8,21},f={16,21},a={6,16},tail=1}}
local skin,skin_shade,blush,hair,hair_hi='efba99','d99a85','f09a8f','443048','6a4a6a'
local long_coats={[0]=true,[2]=true,[3]=true,[8]=true,[10]=true}
-- Outline every transparent pixel touching the drawn silhouette, inside one 24x24 cell.
local function outline(x0,y0)
 local marks={}
 for y=y0,y0+23 do for x=x0,x0+23 do
  if app.pixelColor.rgbaA(im:getPixel(x,y))==0 then
   for _,d in ipairs({{1,0},{-1,0},{0,1},{0,-1}}) do
    local nx,ny=x+d[1],y+d[2]
    if nx>=x0 and ny>=y0 and nx<x0+24 and ny<y0+24 and app.pixelColor.rgbaA(im:getPixel(nx,ny))>0 then table.insert(marks,{x,y});break end
   end
  end
 end end
 for _,m in ipairs(marks) do px(m[1],m[2],ink) end
end
local function leg(x,y,hipx,hipy,foot,pants)
 local fx,fy=x+foot[1],y+foot[2]
 line(x+hipx,y+hipy,fx+1,fy-1,pants);line(x+hipx+1,y+hipy,fx+2,fy-1,pants)
 -- Chunky boots: a toe cap that catches the light and a dark sole.
 rect(fx,fy,5,2,'3b4f6e');rect(fx+1,fy,3,1,'7f98b2');px(fx+4,fy,'5a7090');rect(fx,fy+1,5,1,'263349')
end
local function body(x,y,v,f)
 local p=poses[f+1];local tx,ty=p.t[1],p.t[2];local hx,hy=p.h[1],p.h[2]
 local a,d,h=table.unpack(cloth[v+1])
 local function T(dx,dy,w,hh,col) rect(x+8+tx+dx,y+14+ty+dy,w,hh,col) end
 leg(x,y,10+tx,19+ty,p.b,'2c3a52')
 line(x+9+tx,y+15+ty,x+p.a[1],y+p.a[2],d);px(x+p.a[1],y+p.a[2]+1,skin)
 if long_coats[v] then rect(x+8+tx+math.min(0,p.tail),y+18+ty,2,2+math.max(0,-p.tail)//2,d) end
 T(0,0,8,5,a);T(0,0,1,5,h);T(7,0,1,5,d)
 if v==0 then T(3,0,1,5,'664b68');T(4,2,1,1,'fff0b6')
 elseif v==1 then T(0,0,8,1,'e8c292');T(1,1,1,3,h);T(6,1,1,3,h);T(3,2,2,2,d)
 elseif v==2 then T(4,0,1,5,d);T(0,4,8,1,h);T(5,1,1,1,'fff5ca');T(5,3,1,1,'fff5ca')
 elseif v==3 then T(2,0,4,1,'e1cbaa');T(0,4,8,1,d);T(1,2,2,1,h)
 elseif v==4 then for dy=0,4,2 do T(0,dy,8,1,'bf687e') end
 elseif v==5 then T(3,0,2,5,'e2cba0');T(0,2,2,2,h);T(6,2,2,2,d)
 elseif v==6 then T(3,0,2,5,'eac880');T(0,4,8,1,'eac880');T(4,1,1,1,'fff0bc')
 elseif v==7 then T(3,0,1,5,d);T(5,1,2,2,h)
 elseif v==8 then T(-1,0,10,5,a);T(-1,0,10,1,'ffffff');T(-1,4,10,1,h);T(4,1,1,3,d)
 elseif v==9 then T(2,1,3,3,d);T(3,2,1,1,'72ccca');T(4,1,1,1,'ef8490')
 elseif v==10 then T(-2,1,12,4,a);T(-1,3,10,1,h);T(1,1,6,1,d)
 else T(3,0,1,5,'eee5ce');T(0,1,1,3,'eee5ce');T(0,4,8,1,d) end
 -- Belt, then light from the upper left: a lit front edge and a dithered shade down the back,
 -- which the CRT beam softens into a rounded torso.
 T(0,5,8,1,v==7 and 'd9a45e' or '485b73')
 if v~=10 and v~=8 then for dy=0,4 do if dy%2==0 then T(6,dy,1,1,d) end end;T(1,0,5,1,h) end
 leg(x,y,13+tx,19+ty,p.f,'3e5272')
 -- Head: a rounder, larger head (10 wide, 7 tall) in three-quarter view looking right.
 local X,Y=x+hx,y+hy
 rect(X+9,Y+7,8,1,hair);rect(X+8,Y+8,10,1,hair);rect(X+8,Y+9,3,4,hair);px(X+9,Y+13,hair)
 rect(X+10,Y+7,3,1,hair_hi);px(X+9,Y+8,hair_hi)
 rect(X+11,Y+9,7,4,skin);rect(X+12,Y+13,5,1,skin);px(X+18,Y+11,skin)
 px(X+11,Y+9,hair);px(X+12,Y+9,hair);px(X+13,Y+9,hair)
 px(X+10,Y+11,'e5a58c');px(X+11,Y+12,skin_shade);px(X+12,Y+13,skin_shade)
 -- Eyes with a catchlight, a soft blush and a small mouth.
 px(X+14,Y+10,'fff8ec');px(X+14,Y+11,ink);px(X+17,Y+10,'fff8ec');px(X+17,Y+11,ink)
 px(X+14,Y+12,blush);px(X+18,Y+12,blush);px(X+16,Y+13,'c7787a')
 -- Front hand rests where the shotgun mounts.
 T(6,1,2,1,d);rect(x+15+tx,y+16+ty,2,2,skin);px(x+16+tx,y+17+ty,skin_shade)
 outline(x,y)
end
local function hat(x,y,v,f)
 -- The head now starts a row higher, so hats sit one pixel up (the tall wizard hat keeps its tip in frame).
 local p=poses[f+1];x=x+p.h[1];y=y+p.h[2]-(v==7 and 0 or 1)
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
end
local function neck(x,y,v,f)
 local p=poses[f+1];x=x+p.t[1];y=y+p.t[2];local a,d,h=table.unpack(scarfcols[v+1])
 rect(x+8,y+13,8,2,a);rect(x+8,y+15,3,1,d);rect(x+9,y+13,6,1,h)
 if v==6 or v==7 then for xx=8,15,3 do rect(x+xx,y+13,1,2,d) end end
 if v==10 then px(x+12,y+14,'ffe2a4') end
end
start(24*FRAMES,288,'Body, face and boots')
for v=0,11 do for f=0,FRAMES-1 do body(f*24,v*24,v,f) end end
save('wardrobe_outfits')
start(24*FRAMES,312,'Independent headwear')
for v=0,11 do for f=0,FRAMES-1 do hat(f*24,v*24,v,f) end end
save('wardrobe_hats')
start(24*FRAMES,312,'Scarf neck wraps')
for v=0,11 do for f=0,FRAMES-1 do neck(f*24,v*24,v,f) end end
save('wardrobe_necks')
-- Default look, used as the player scene's base texture before the wardrobe applies.
start(24*FRAMES,24,'Default kid')
for f=0,FRAMES-1 do body(f*24,0,0,f);neck(f*24,0,0,f);hat(f*24,0,0,f) end
save('kid_scarf_ready')
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
-- Shotguns: one 24x10 row each, pointing right, grip around x=8 (the sprite is centred 9px out
-- from the kid's hand and rotates with the aim). Barrels end at x=23 where the blast appears.
local guns={'Trusty Pump','Twin Barrel','Brass Blunderbuss','Frost Pump','Bramble Gun','Copper Riveter','Blossom Popper','Comet Blaster'}
-- wood: dark, mid, light; metal: dark, mid, light; trim
local gunpal={
 {wood={'5e3424','93593a','c98552'},metal={'2c3348','4f5b78','a3b2cc'},trim='d9b26a'},
 {wood={'4a2a20','7a4630','b26f48'},metal={'2a2f40','505a72','b7c3d6'},trim='e8c06e'},
 {wood={'5e3424','8f5638','c5824f'},metal={'7a5121','c08a3a','f2d48a'},trim='fff0b8'},
 {wood={'6d86a8','a9c3df','e8f2fb'},metal={'2c3a6a','4f6aa8','9cc2ec'},trim='ffffff'},
 {wood={'3f4a2c','667a3f','9cb35a'},metal={'2d3533','4f5e57','98ad9e'},trim='e88aa0'},
 {wood={'4f2d22','7d4632','b76b45'},metal={'5a3328','a35a3a','e09a63'},trim='7fc0b0'},
 {wood={'d6a3b6','f0c8d4','fff0f4'},metal={'7d5a78','b685ae','eec3df'},trim='ffd27a'},
 {wood={'2b2347','4c3e7a','7a68b8'},metal={'1f1d36','3f3c6a','8a86c6'},trim='7ff6f0'},
}
local function gun(oy,v)
 local p=gunpal[v+1];local w,m=p.wood,p.metal
 local function R(x,y,ww,hh,col) rect(x,oy+y,ww,hh,col) end
 -- Stock and grip (the wood), shaped so the silhouette reads at a glance.
 R(0,4,6,3,w[2]);R(0,4,6,1,w[3]);R(0,6,6,1,w[1]);R(5,5,3,3,w[2]);px(6,oy+7,w[1])
 if v==1 then R(0,3,4,1,w[2]) end
 -- Receiver.
 R(7,3,6,4,m[2]);R(7,3,6,1,m[3]);R(7,6,6,1,m[1]);px(9,oy+7,m[1]);px(10,oy+8,m[2])
 -- Barrel(s).
 if v==1 then R(12,2,12,2,m[2]);R(12,2,12,1,m[3]);R(12,4,12,2,m[2]);R(12,5,12,1,m[1]);R(16,2,1,4,p.trim);R(21,2,1,4,p.trim)
 elseif v==2 then R(12,3,10,2,m[2]);R(12,3,10,1,m[3]);R(20,2,3,4,m[2]);R(21,1,3,6,m[2]);R(21,1,3,1,m[3]);R(23,2,1,4,m[1]);R(15,3,1,2,p.trim)
 else R(12,3,12,2,m[2]);R(12,3,12,1,m[3]);R(22,3,2,2,m[1]) end
 -- Fore-end / pump under the barrel.
 if v~=1 and v~=2 then R(14,5,6,2,w[2]);R(14,5,6,1,w[3]);for xx=15,19,2 do px(xx,oy+6,w[1]) end end
 -- Per-gun character.
 if v==0 then px(9,oy+4,p.trim);px(11,oy+4,p.trim)
 elseif v==3 then R(8,4,4,1,'ffffff');px(18,oy+2,p.trim);px(14,oy+2,'e8f2fb')
 elseif v==4 then for xx=1,21,4 do px(xx,oy+(xx%8==1 and 3 or 7),'5f9c4a');px(xx+1,oy+(xx%8==1 and 2 or 8),'8bc55a') end;px(19,oy+2,p.trim);px(20,oy+1,'f6c2d0')
 elseif v==5 then for xx=8,12,2 do px(xx,oy+4,p.trim) end;px(13,oy+3,'e09a63');R(18,2,2,1,p.trim)
 elseif v==6 then px(2,oy+5,p.trim);px(3,oy+4,'ffffff');px(3,oy+6,'ffffff');px(4,oy+5,'ffffff');px(19,oy+2,'ffd27a')
 elseif v==7 then R(13,2,8,1,p.trim);px(14,oy+5,p.trim);px(16,oy+5,p.trim);px(18,oy+5,p.trim);R(22,2,2,4,m[2]);px(23,oy+3,p.trim);px(23,oy+4,p.trim) end
 -- Ink outline around the whole gun.
 local marks={}
 for y=oy,oy+9 do for x=0,23 do
  if app.pixelColor.rgbaA(im:getPixel(x,y))==0 then
   for _,d in ipairs({{1,0},{-1,0},{0,1},{0,-1}}) do
    local nx,ny=x+d[1],y+d[2]
    if nx>=0 and nx<24 and ny>=oy and ny<oy+10 and app.pixelColor.rgbaA(im:getPixel(nx,ny))>0 then table.insert(marks,{x,y});break end
   end
  end
 end end
 for _,mk in ipairs(marks) do px(mk[1],mk[2],ink) end
end
start(24,10*#guns,'Shotguns')
for v=0,#guns-1 do gun(v*10,v) end
save('wardrobe_guns')
-- The default gun doubles as the player scene's base gun texture.
start(24,10,'Shotgun');gun(0,0);save('shotgun')
-- One stable catalogue accompanies the art exports.
local cat={hats={},scarves={},outfits={},guns={}}
for i,name in ipairs(guns) do table.insert(cat.guns,{id=name:lower():gsub(' ','_'),name=name,row=i-1}) end
local function slug(name) return name:lower():gsub(' ','_') end
for i,name in ipairs(hats) do table.insert(cat.hats,{id=slug(name),name=name,row=i-1}) end
for i,name in ipairs(scarves) do table.insert(cat.scarves,{id=slug(name),name=name,row=i-1,length=({2.7,2.5,2.8,3.0,2.4,2.7,3.1,2.5,2.6,3.0,2.9,2.8,0})[i]}) end
for i,name in ipairs(outfits) do table.insert(cat.outfits,{id=slug(name),name=name,row=i-1}) end
local file=io.open(root..'/data/wardrobe.json','w');file:write(json.encode(cat));file:close()
print('Wardrobe: 12 hats + bareheaded, 12 scarves + none, 12 outfits; all Aseprite sources exported.')

local gd=io.open(root..'/data/wardrobe_items.gd','w');gd:write('extends RefCounted\nconst ITEMS = '..json.encode(cat)..'\n');gd:close()
