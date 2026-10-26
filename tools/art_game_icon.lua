-- Two-shell project icon. All raster authoring and resizing is performed by Aseprite.
local root=app.params['root'] or '.'
local sprite=Sprite(64,64)
sprite.layers[1].name='Rear red shell'
local function col(hex) return Color{r=tonumber(hex:sub(1,2),16),g=tonumber(hex:sub(3,4),16),b=tonumber(hex:sub(5,6),16),a=255} end
local colors={}
for _,h in ipairs({'171e30','502435','992b42','d84050','ef5b60','ff9b89','ffe0b2','99603e','c68a49','edba69','845138','bb3b4a'}) do colors[h]=col(h) end
local function shell(image,cx,cy,degrees)
 local a=math.rad(degrees);local cs,sn=math.cos(a),math.sin(a)
 for y=0,63 do for x=0,63 do
  local dx,dy=x-cx,y-cy
  local u=math.floor(dx*cs+dy*sn+.5);local v=math.floor(-dx*sn+dy*cs+.5)
  local h=nil
  -- Squared crimped hull, broad brass head and projecting rim: no bullet tip.
  if math.abs(u)<=9 and v>=-21 and v<=22 then
   if (v>=-19 or math.abs(u)<=7) and (v<=20 or math.abs(u)<=8) then h='171e30' end
  end
  if math.abs(u)<=7 and v>=-19 and v<=11 then
   h='d84050'
   if u<=-5 then h='ff9b89' elseif u<=-3 then h='ef5b60' elseif u>=5 then h='992b42' end
   if v==-19 then h='ff9b89' end
   if v==-17 then h='992b42' end
   if v>=-15 and v<=8 and (u==-1 or u==2) then h='bb3b4a' end
   if v==10 or v==11 then h='502435' end
   -- Short stamped markings on the red casing.
   if v==-4 and u>=-2 and u<=3 then h='ffe0b2' end
   if v==-2 and (u==-2 or u==0 or u==3) then h='ffe0b2' end
  end
  if math.abs(u)<=7 and v>=12 and v<=18 then
   h='c68a49'
   if u<=-4 then h='ffe0b2' elseif u<=-1 then h='edba69' elseif u>=5 then h='99603e' end
   if v==12 then h='edba69' end
   if v==18 then h='845138' end
  end
  if math.abs(u)<=8 and v>=19 and v<=20 then h=v==19 and 'edba69' or '99603e';if u<=-4 then h='ffe0b2' end end
  if h then image:drawPixel(x,y,colors[h]) end
 end end
end
shell(sprite.cels[1].image,22,32,-19)
local front=sprite:newLayer();front.name='Front red shell'
local cel=sprite:newCel(front,1,Image(64,64))
shell(cel.image,43,33,19)
sprite:saveAs(root..'/assets/source/game_icon.aseprite')
sprite:saveCopyAs(root..'/assets/textures/game_icon_64.png')
app.command.SpriteSize{ui=false,width=256,height=256,method='nearest-neighbor'}
sprite:saveCopyAs(root..'/assets/textures/game_icon.png')
print('Two-shell icon exported: editable 64px source, 64px and 256px PNGs.')
