-- Atmospheric depth for backdrop layers, drawn for the CRT (see docs/CRT_ART.md).
-- Loaded with dofile() by tools/art_biome_backgrounds.lua and tools/art_props.lua.
--   depth(layer, fog, top, bottom, rim)
-- fog: hex colour the layer fades toward; top/bottom: how far it fades at the top and bottom
-- of the image. The fade is quantised to eighths and ordered-dithered between them, so on
-- the CRT it reads as a smooth mist. rim: hex colour (or nil) for a lit edge along the top of
-- every silhouette, so distant shapes separate cleanly under the scanlines.
local BAYER={{0,8,2,10},{12,4,14,6},{3,11,1,9},{15,7,13,5}}
local function hex(h) return tonumber(h:sub(1,2),16),tonumber(h:sub(3,4),16),tonumber(h:sub(5,6),16) end
function depth(l,fog,top,bottom,rim)
 local pc=app.pixelColor
 local fr,fg,fb=hex(fog)
 local rr,rg,rb
 if rim then rr,rg,rb=hex(rim) end
 for _,cel in ipairs(l.cels) do
  local src=cel.image;local img=src:clone()
  local ox,oy=cel.position.x,cel.position.y
  local H=l.sprite.height
  local function alpha(x,y)
   if x<0 or y<0 or x>=src.width or y>=src.height then return 0 end
   return pc.rgbaA(src:getPixel(x,y))
  end
  for y=0,src.height-1 do for x=0,src.width-1 do
   local v=src:getPixel(x,y);local a=pc.rgbaA(v)
   if a>0 then
    local r,g,b=pc.rgbaR(v),pc.rgbaG(v),pc.rgbaB(v)
    if rim then
     local k=alpha(x,y-1)==0 and 0.45 or (alpha(x,y-2)==0 and 0.18 or 0)
     r,g,b=r+(rr-r)*k,g+(rg-g)*k,b+(rb-b)*k
    end
    local t=top+(bottom-top)*((y+oy)/H)
    local level=math.max(0,math.min(1,t))*8
    local q=math.floor(level);if level-q>(BAYER[(y+oy)%4+1][(x+ox)%4+1]+0.5)/16 then q=q+1 end
    local f=q/8
    img:drawPixel(x,y,pc.rgba(math.floor(r+(fr-r)*f+.5),math.floor(g+(fg-g)*f+.5),math.floor(b+(fb-b)*f+.5),a))
   end
  end end
  cel.image=img
 end
end
