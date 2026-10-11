local root=app.params['root'];local s=Sprite(9,9);s.layers[1].name='Route chevron';local im=s.cels[1].image
for i=0,3 do im:drawPixel(4-i,2+i,Color{r=150,g=215,b=199});im:drawPixel(4+i,2+i,Color{r=150,g=215,b=199}) end
for y=3,7 do im:drawPixel(4,y,Color{r=109,g=163,b=168}) end
s:saveAs(root..'/assets/source/route_arrow.aseprite');s:saveCopyAs(root..'/assets/textures/route_arrow.png');s:close()
