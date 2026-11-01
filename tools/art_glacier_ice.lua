-- Shotgun Kid / Velvet Glacier. Slippery ice and crumbling ice: original pixel art authored with Aseprite's Lua API.
-- slick_ice.png: two 16x16 frames: 0 glossy top tile, 1 body tile.
-- crumble_ice.png: three 16x16 frames: 0 solid (snow-crusted), 1 cracked, 2 outline of where it regrows.
-- aseprite -b --script-param root=. --script tools/art_glacier_ice.lua
local root=app.params['root'] or '.'
local function c(h) return Color{r=tonumber(h:sub(1,2),16),g=tonumber(h:sub(3,4),16),b=tonumber(h:sub(5,6),16)} end
local ink='1c203c'
local function sheet(w)
 local s=Sprite(w,16)
 local im=s.cels[1].image
 local function px(x,y,h) if x>=0 and y>=0 and x<w and y<16 then im:drawPixel(x,y,c(h)) end end
 local function rect(x,y,ww,hh,col) for yy=y,y+hh-1 do for xx=x,x+ww-1 do px(xx,yy,col) end end end
 return s,px,rect
end

-- Slick ice: clear blue-white with a long specular streak, so it reads as polished, not as rock.
local s,px,rect=sheet(32)
s.layers[1].name='Slick ice'
for f=0,1 do
 local x=f*16
 rect(x,0,16,16,'86a7c8')
 rect(x,0,16,1,f==0 and 'ffffff' or 'b4d0e3')
 if f==0 then rect(x,1,16,2,'e2eef6');rect(x,3,16,1,'b4d0e3') end
 -- Diagonal gloss streaks and deep cool shadow at the bottom.
 for k=0,5 do px(x+3+k,12-k,'d6e2f2');px(x+10+k,15-k,'b4d0e3') end
 rect(x,15,16,1,'5d6f98')
 px(x+2,6,'ffffff');px(x+12,9,'e2eef6')
end
s:saveAs(root..'/assets/source/slick_ice.aseprite');s:saveCopyAs(root..'/assets/textures/slick_ice.png');s:close()

-- Crumbling ice: frosted, snow-crusted blocks with visible fracture lines.
s,px,rect=sheet(48)
s.layers[1].name='Crumble ice'
local function block(x,cracked)
 rect(x,0,16,16,ink)
 rect(x+1,1,14,14,'94afd0')
 rect(x+1,1,14,3,'f4f8fc');rect(x+2,4,3,1,'f4f8fc');rect(x+9,4,4,1,'f4f8fc')
 rect(x+1,14,14,1,'5d6f98');rect(x+14,4,1,10,'6f84ad')
 px(x+4,8,'d6e2f2');px(x+10,10,'d6e2f2');px(x+7,12,'b4d0e3')
 -- Fracture lines; the cracked frame splits them wide open.
 local crack=cracked and ink or '6f84ad'
 for _,p in ipairs({{7,5},{8,6},{8,7},{9,8},{9,9},{8,10},{5,9},{6,9},{11,7},{12,6}}) do px(x+p[1],p[2],crack) end
 if cracked then
  for _,p in ipairs({{3,6},{4,7},{4,11},{5,12},{12,11},{13,12},{10,13},{8,11}}) do px(x+p[1],p[2],ink) end
 end
end
block(0,false)
block(16,true)
-- Outline: a dashed frosty border only.
for k=0,15 do
 if k%4<2 then px(32+k,0,'d6e2f2');px(32+k,15,'86a7c8');px(32,k,'d6e2f2');px(47,k,'86a7c8') end
end
s:saveAs(root..'/assets/source/crumble_ice.aseprite');s:saveCopyAs(root..'/assets/textures/crumble_ice.png');s:close()
print('Glacier ice exported.')
