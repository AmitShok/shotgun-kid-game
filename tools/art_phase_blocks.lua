-- Shotgun Kid / Copper Cloud. Phase plates and the shot switch: original pixel art authored with Aseprite's Lua API.
-- phase_block.png: four 16x16 frames: 0 copper solid, 1 copper outline (phased out), 2 teal solid, 3 teal outline.
-- phase_switch.png: two 24x24 frames: 0 copper face lit (copper plates solid), 1 teal face lit.
-- aseprite -b --script-param root=. --script tools/art_phase_blocks.lua
local root=app.params['root'] or '.'
local function c(h) return Color{r=tonumber(h:sub(1,2),16),g=tonumber(h:sub(3,4),16),b=tonumber(h:sub(5,6),16)} end
local ink='1b1a26'
local palettes={
 {light='f5c58a',mid='d08a4f',dark='94573a',deep='5e3434',glow='ffe2b0'},
 {light='bdf2e4',mid='6fc2b4',dark='3f8586',deep='2b4f5a',glow='e2fff6'}}

local s=Sprite(64,16);s.layers[1].name='Phase plates'
local im=s.cels[1].image
local function px(x,y,h) if x>=0 and y>=0 and x<64 and y<16 then im:drawPixel(x,y,c(h)) end end
local function rect(x,y,w,h,col) for yy=y,y+h-1 do for xx=x,x+w-1 do px(xx,yy,col) end end end
for i,p in ipairs(palettes) do
 -- Solid plate: inked border, bevelled face, corner rivets and a centre phase mark.
 local x=(i-1)*32
 rect(x,0,16,16,ink)
 rect(x+1,1,14,14,p.mid)
 rect(x+1,1,14,1,p.light);rect(x+1,1,1,14,p.light)
 rect(x+1,14,14,1,p.dark);rect(x+14,1,1,14,p.dark)
 rect(x+3,3,10,10,p.mid);rect(x+3,12,10,1,p.dark);rect(x+12,3,1,10,p.dark)
 for _,r in ipairs({{3,3},{12,3},{3,12},{12,12}}) do px(x+r[1],r[2],p.glow);px(x+r[1]+1,r[2]+1,p.deep) end
 if i==1 then
  -- Copper mark: a diamond.
  for d=0,2 do rect(x+8-d,6+d,1+d*2-1+1,1,p.light);rect(x+8-d,10-d,1+d*2,1,p.dark) end
  px(x+8,8,p.glow)
 else
  -- Teal mark: a ring.
  rect(x+6,6,4,1,p.light);rect(x+6,10,4,1,p.dark);rect(x+5,7,1,3,p.light);rect(x+10,7,1,3,p.dark)
  px(x+8,8,p.glow)
 end
 -- Outline plate (not solid right now): dashed border and a faint mark, mostly transparent.
 x=x+16
 for k=0,15 do
  if k%4<2 then px(x+k,0,p.mid);px(x+k,15,p.dark);px(x,k,p.mid);px(x+15,k,p.dark) end
 end
 px(x+7,7,p.dark);px(x+8,8,p.dark);px(x+7,8,p.mid);px(x+8,7,p.mid)
end
s:saveAs(root..'/assets/source/phase_block.aseprite');s:saveCopyAs(root..'/assets/textures/phase_block.png');s:close()

s=Sprite(48,24);s.layers[1].name='Phase switch'
im=s.cels[1].image
local function px2(x,y,h) if x>=0 and y>=0 and x<48 and y<24 then im:drawPixel(x,y,c(h)) end end
local function disc(cx,cy,r,col)
 for y=-r,r do for x=-r,r do if x*x+y*y<=r*r+r*0.6 then px2(cx+x,cy+y,col) end end end
end
for f=0,1 do
 -- A riveted round housing; the lit half shows which plates are solid.
 local cx,cy=f*24+12,12
 local lit=palettes[f+1];local dim=palettes[2-f]
 disc(cx,cy,10,ink)
 disc(cx,cy,9,'4a4458')
 disc(cx,cy,8,'6e6680')
 disc(cx,cy,6,ink)
 disc(cx,cy,5,lit.mid)
 disc(cx-1,cy-1,3,lit.light)
 px2(cx-2,cy-2,lit.glow);px2(cx-1,cy-2,lit.glow)
 -- Small indicator lamp for the other phase, dark.
 disc(cx+7,cy+7,2,ink);px2(cx+7,cy+7,dim.deep)
 for _,r in ipairs({{-7,-5},{7,-5},{-7,5}}) do px2(cx+r[1],cy+r[2],'a59cb5') end
end
s:saveAs(root..'/assets/source/phase_switch.aseprite');s:saveCopyAs(root..'/assets/textures/phase_switch.png');s:close()
print('Phase plates and switch exported.')
