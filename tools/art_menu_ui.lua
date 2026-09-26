-- Shotgun Kid: nine-slice UI artwork authored/exported inside Aseprite.
local root=app.params['root']
local function color(h) return Color{r=tonumber(h:sub(1,2),16),g=tonumber(h:sub(3,4),16),b=tonumber(h:sub(5,6),16)} end
local s,im
local function start(w,h) s=Sprite(w,h);s.layers[1].name='Silhouette';im=s.cels[1].image end
local function layer(name) local l=s:newLayer();l.name=name;im=s:newCel(l,1,Image(s.width,s.height)).image end
local function rect(x,y,w,h,c) for yy=y,y+h-1 do for xx=x,x+w-1 do im:drawPixel(xx,yy,color(c)) end end end
local function px(x,y,c) rect(x,y,1,1,c) end
local function slab(x,y,w,h,c)
 rect(x+2,y,w-4,h,c);rect(x+1,y+1,w-2,h-2,c);rect(x,y+2,w,h-4,c)
end
local function save(name)
 s:saveAs(root..'/assets/source/ui_'..name..'.aseprite')
 s:saveCopyAs(root..'/assets/textures/ui_'..name..'.png');s:close()
end
for _,state in ipairs({'normal','hover','pressed','disabled'}) do
 start(48,24)
 local face=state=='hover' and '314b60' or (state=='disabled' and '202b3b' or '263b50')
 local rim=state=='hover' and 'b5d7ca' or (state=='disabled' and '354357' or '617c8b')
 local accent=state=='hover' and 'f1c182' or (state=='disabled' and '47566a' or '83b9b6')
 slab(1,3,46,21,'101a2b')
 layer('Cut metal rim')
 slab(0,0,48,22,'111c2e');slab(1,1,46,20,rim);slab(2,2,44,18,face)
 layer('Light and depth')
 rect(4,2,40,1,state=='pressed' and '18283a' or '76959c')
 rect(3,18,42,2,state=='pressed' and '18283a' or '1a2c40')
 rect(4,20,40,1,'111e31')
 if state=='pressed' then rect(3,3,42,2,'18283a') end
 layer('Endcap details')
 -- Small inset metal fasteners, retained by the nine-slice margins.
 rect(6,9,3,3,'162739');px(7,9,accent);px(7,10,accent)
 rect(39,9,3,3,'162739');px(40,9,accent);px(40,10,accent)
 if state=='hover' then px(10,10,'f1c182');px(11,11,'f1c182');px(10,12,'f1c182') end
 save('button_'..state)
end
start(24,24);s.layers[1].name='Keyboard focus corners'
for _,x in ipairs({1,18}) do for _,y in ipairs({1,18}) do rect(x,y==1 and 1 or 22,5,1,'9acbc8');rect(x==1 and 1 or 22,y,1,5,'9acbc8') end end
save('focus')
for _,state in ipairs({'off','on','off_hover','on_hover'}) do
 start(24,12)
 local on=state=='on' or state=='on_hover'; local hover=string.find(state,'hover')
 slab(0,1,24,10,'101d30');slab(1,2,22,8,on and '367575' or '354456')
 layer('Switch slider')
 local x=on and 14 or 2
 slab(x,0,8,11,hover and 'f1c182' or (on and 'c5e3d5' or '899bab'))
 rect(x+2,2,4,1,'e5ebd9');rect(x+2,8,4,1,on and '699e9e' or '536a80')
 save('switch_'..state)
end
start(7,5);s.layers[1].name='Dropdown chevron'
for i=0,2 do rect(i,1+i,7-i*2,1,'b6d6cf') end
save('arrow')
for _,state in ipairs({'normal','hover'}) do
 start(8,12);slab(0,0,8,12,'101d30');slab(1,1,6,10,state=='hover' and 'f1c182' or 'a5d1c8');rect(3,3,2,6,'ecedce');save('slider_'..state)
end
start(16,8);slab(0,1,16,6,'101b2c');rect(2,3,12,2,'344b60');save('slider_track')
start(16,8);slab(0,1,16,6,'101b2c');rect(2,3,12,2,'6db4af');save('slider_fill')
start(24,24);slab(0,0,24,24,'101b2c');slab(1,1,22,22,'526e80');slab(2,2,20,20,'1b2d41');rect(4,2,16,1,'789399');save('panel')

for _,on in ipairs({false,true}) do
 start(10,10);slab(0,0,10,10,'101d30');slab(1,1,8,8,'617c8b');slab(2,2,6,6,'203749')
 if on then slab(3,3,4,4,'b6d6cf') end
 save(on and 'radio_on' or 'radio_off')
end
start(9,9);s.layers[1].name='Close mark'
for i=1,7 do px(i,i,'b6d6cf');px(8-i,i,'b6d6cf') end
save('close')

-- Gameplay UI: quieter frames and readable ammunition silhouettes.
start(24,24);slab(0,1,24,23,'101a2b');slab(0,0,24,23,'405f73');slab(1,1,22,21,'182a3c')
layer('Edge highlights');rect(4,1,16,1,'678d98');rect(4,21,16,1,'101d30');save('hud_panel')
start(24,24);slab(0,0,24,24,'101d30');slab(1,1,22,22,'344f63');slab(2,2,20,20,'182a3c')
layer('Trail marker');rect(2,5,2,14,'83b9b6');save('sign_panel')
start(16,16);slab(0,1,16,15,'101b2c');slab(0,0,16,14,'607e8d');slab(1,1,14,12,'2a4155');rect(3,1,10,1,'86a8ae');save('keycap')
for _,full in ipairs({true,false}) do
 start(14,22);slab(0,0,14,22,'101b2c');slab(1,1,12,20,'344f63');slab(2,2,10,18,'172839')
 layer('Shell')
 if full then
  rect(4,4,6,12,'b85a62');rect(4,4,2,11,'df8990');rect(9,5,1,10,'813e52')
  rect(3,16,8,3,'c59358');rect(3,16,8,1,'f3d598');rect(4,19,6,1,'6c5460');rect(6,6,2,6,'e7b99b')
 else
  rect(4,4,6,1,'496071');rect(4,5,1,11,'3a5164');rect(9,5,1,11,'3a5164');rect(3,16,8,3,'3a5164');rect(4,19,6,1,'273e52')
 end
 save(full and 'ammo_full' or 'ammo_empty')
end
start(20,20);s.layers[1].name='Summit emblem'
for y=3,15 do local half=math.floor((y-3)*0.6);rect(10-half,y,half*2+1,1,'83b9b6') end
rect(4,16,13,2,'405f73');rect(10,2,1,7,'f3d598');rect(11,2,5,3,'e6b780');save('summit')
