local root=app.params['root']
local s=app.open(root..'/assets/source/kid.aseprite')
local scarf
for _,l in ipairs(s.layers) do if l.name=='Scarf motion and highlights' then scarf=l end end
if scarf then
 local im=s.cels[#s.cels].image
 for _,cel in ipairs(scarf.cels) do
  cel.image:clear()
  for f=0,7 do local x=f*24;local b=(f==1 or f==3 or f==5) and 1 or 0
   for yy=12+b,13+b do for xx=x+7,x+15 do cel.image:drawPixel(xx,yy,Color{r=114,g=204,b=202}) end end
   for xx=x+7,x+10 do cel.image:drawPixel(xx,14+b,Color{r=67,g=143,b=164}) end
  end
 end
end
s:saveAs(root..'/assets/source/kid_scarf_ready.aseprite');s:saveCopyAs(root..'/assets/textures/kid_scarf_ready.png');s:close()
s=Sprite(5,3);s.layers[1].name='Woven scarf';local im=s.cels[1].image
for x=0,4 do im:drawPixel(x,0,Color{r=164,g=233,b=214});im:drawPixel(x,1,Color{r=114,g=204,b=202});im:drawPixel(x,2,Color{r=55,g=119,b=142}) end
s:saveAs(root..'/assets/source/scarf_segment.aseprite');s:saveCopyAs(root..'/assets/textures/scarf_segment.png');s:close()
s=Sprite(3,3);s.layers[1].name='Dust mask';im=s.cels[1].image
for y=0,2 do for x=0,2 do if not (x==0 and y==0) and not (x==2 and y==2) then im:drawPixel(x,y,Color{r=255,g=255,b=255}) end end end
s:saveAs(root..'/assets/source/traversal_dust.aseprite');s:saveCopyAs(root..'/assets/textures/traversal_dust.png');s:close()
