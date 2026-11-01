-- Shotgun Kid / Mossy Comet. Spore pod: original pixel art authored with Aseprite's Lua API.
-- Two 24x24 frames facing up: 0 ripe (glowing, ready to burst), 1 spent (shrivelled husk).
-- aseprite -b --script-param root=. --script tools/art_spore_pod.lua
local root=app.params['root'] or '.'
local s=Sprite(48,24);s.layers[1].name='Spore pod'
local im=s.cels[1].image
local function c(h) return Color{r=tonumber(h:sub(1,2),16),g=tonumber(h:sub(3,4),16),b=tonumber(h:sub(5,6),16)} end
local function px(x,y,h) if x>=0 and y>=0 and x<48 and y<24 then im:drawPixel(x,y,c(h)) end end
local function rect(x,y,w,h,col) for yy=y,y+h-1 do for xx=x,x+w-1 do px(xx,yy,col) end end end
local function ellipse(cx,cy,rx,ry,col)
 for y=-ry,ry do local w=math.floor(rx*math.sqrt(math.max(0,1-(y*y)/(ry*ry)))+0.5);rect(cx-w,cy+y,w*2+1,1,col) end
end
local ink='1b2430'
-- Frame 0: ripe pod. Root cup at the bottom (attaches to the surface), bulb above, opening on top.
local x=0
rect(x+7,20,10,4,ink);rect(x+8,20,8,3,'3d5a49');rect(x+9,20,6,1,'5c7d5e')
ellipse(x+12,13,7,7,ink);ellipse(x+12,13,6,6,'4f8a6a');ellipse(x+11,12,4,4,'72b98a');ellipse(x+10,10,2,2,'a9e4b5')
rect(x+9,5,7,2,ink);rect(x+10,4,5,2,'d9f7c4');px(x+12,3,'ffffff')
for _,p in ipairs({{8,14},{15,11},{14,16},{10,17},{16,15}}) do px(x+p[1],p[2],'d9f7c4') end
px(x+6,13,'2f5543');px(x+18,13,'2f5543')
-- Frame 1: spent husk, collapsed and dull.
x=24
rect(x+7,20,10,4,ink);rect(x+8,20,8,3,'3d5a49')
ellipse(x+12,17,6,4,ink);ellipse(x+12,17,5,3,'3f5a4c');rect(x+10,14,5,1,'2a3d36');px(x+11,16,'567565');px(x+14,18,'567565')
s:saveAs(root..'/assets/source/spore_pod.aseprite');s:saveCopyAs(root..'/assets/textures/spore_pod.png');s:close()
print('Spore pod exported.')
