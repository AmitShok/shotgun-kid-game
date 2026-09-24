-- Original Shotgun Kid artwork. Run inside Aseprite (batch or File > Scripts).
local root=app.params['root'] or '.'
local ink=Color{r=20,g=23,b=43,a=255}
local function col(h) return Color{r=tonumber(h:sub(1,2),16),g=tonumber(h:sub(3,4),16),b=tonumber(h:sub(5,6),16),a=255} end
local s,im
local function start(w,h) s=Sprite(w,h); s.layers[1].name='Pixel artwork'; im=s.cels[1].image end
local function rect(x,y,w,h,c) c=type(c)=='string' and col(c) or c; for yy=y,y+h-1 do for xx=x,x+w-1 do if xx>=0 and yy>=0 and xx<im.width and yy<im.height then im:drawPixel(xx,yy,c) end end end end
local function save(n) s:saveAs(root..'/assets/source/'..n..'.aseprite'); s:saveCopyAs(root..'/assets/textures/'..n..'.png'); s:close() end
start(96,24)
for f=0,3 do local x=f*24; local b=f==1 and 1 or 0
 rect(x+6,3+b,12,15,ink); rect(x+7,2+b,10,5,'e96465'); rect(x+9,1+b,7,2,'ffac7b'); rect(x+6,6+b,12,2,'813e60')
 rect(x+8,8+b,9,6,'f9cba2'); rect(x+15,9+b,2,2,ink); rect(x+7,13+b,10,7,'55c8bc'); rect(x+7,14+b,3,5,'328a9b')
 rect(x+4,12+b,5,3,'e96465'); rect(x+2,14+b,4,2,'bd4a62'); rect(x+15,15+b,4,3,'f9cba2')
 rect(x+7,20,4,3,ink); rect(x+14,20,4,3,ink)
 if f==1 then rect(x+5,21,4,2,'94b8bf') elseif f==2 then rect(x+16,21,4,2,'94b8bf') elseif f==3 then rect(x+7,20,11,2,'517087') end
end
save('kid')
start(24,10); rect(0,3,22,5,ink); rect(6,2,17,4,'9aafbd'); rect(8,3,15,1,'e3eeee'); rect(5,6,13,2,'53667e'); rect(1,5,7,4,'c78665'); rect(22,2,2,6,ink); save('shotgun')
start(16,16); rect(0,0,16,16,'29364e'); rect(0,0,16,3,'7bd4c5'); rect(0,3,16,2,'3f8395'); rect(1,7,13,1,'3c5068'); rect(7,8,1,7,'1c2a41'); rect(1,14,5,1,'47637a'); save('tile')
start(16,16); rect(0,0,16,16,'26344b'); rect(0,0,16,1,'182a40'); rect(7,0,1,8,'182a40'); rect(0,8,16,1,'182a40'); rect(1,2,5,1,'394c62'); rect(10,10,5,1,'394c62'); rect(1,8,1,8,'182a40'); save('stone')
start(24,24); rect(3,6,18,14,ink); rect(5,5,14,14,'705786'); rect(6,7,12,4,'ab7999'); rect(8,10,8,6,ink); rect(10,11,4,3,'ffcb80'); rect(1,10,4,5,'455574'); rect(19,10,4,5,'455574'); rect(6,20,4,2,'e96465'); rect(15,20,4,2,'e96465'); save('drone')
start(8,8); rect(2,0,4,8,'ff765f'); rect(0,2,8,4,'ff765f'); rect(2,2,4,4,'ffe3a1'); save('orb')
start(8,12); rect(1,0,6,12,ink); rect(2,1,4,8,'ef7766'); rect(2,2,1,6,'ffbf92'); rect(1,9,6,2,'ffdb98'); save('shell')
start(16,16); for x=0,15 do local h=7-math.abs(x%8-3); rect(x,15-h,1,h+1,'c6d9e3') end; rect(0,15,16,1,'52667f'); save('spikes')
start(24,40); rect(6,4,3,35,'a9beca'); rect(9,5,14,12,'55c8bc'); rect(9,14,10,3,'338e9d'); rect(2,37,13,3,ink); save('flag')
start(40,56); rect(4,0,32,56,ink); rect(6,2,28,54,'5b6483'); rect(9,5,22,51,'26495e'); rect(12,8,16,48,'46a99f'); rect(15,9,10,47,'8de1bc'); rect(5,0,30,4,'b3ddd4'); rect(2,52,36,4,'b3ddd4'); save('door')
start(64,32); for x=0,63 do local h=math.floor((1-x/64)*13); rect(x,16-h,1,h*2+1,x<12 and 'fff0bf' or (x<34 and 'ffcc7f' or 'e87f6b')) end; save('blast')
start(5,5); rect(2,0,1,5,'ffdda1'); rect(0,2,5,1,'ffdda1'); save('spark')
start(640,360); rect(0,0,640,360,'18233b'); rect(0,120,640,240,'22324c'); rect(0,205,640,155,'2b4159')
math.randomseed(38)
for i=1,100 do rect(math.random(0,639),math.random(0,180),1,1,'8392ac') end
for y=-25,25 do local w=math.floor(math.sqrt(625-y*y)); rect(481-w,61+y,w*2,1,'f4d3aa') end
for x=0,639 do local h=65+math.floor(36*math.sin(x/62)+24*math.sin(x/29)); rect(x,220-h,1,220+h,'31475f') end
for x=0,639 do local h=38+math.floor(28*math.sin(x/46)+16*math.sin(x/17)); rect(x,270-h,1,90+h,'263950') end
for i=0,17 do local x=i*39; local h=math.random(30,100); rect(x,330-h,26,h,'1d2d43'); rect(x+3,327-h,20,3,'3e546a'); for y=336-h,315,13 do rect(x+6,y,3,4,'64817f'); rect(x+17,y,3,4,'4b666f') end end
rect(0,345,640,15,'16263a'); save('background')
print('Aseprite artwork and source documents exported.')
