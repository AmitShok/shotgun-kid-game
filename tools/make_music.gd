extends SceneTree
## Composes and synthesizes the original looping music tracks into assets/music/*.wav.
## Every melody comes from a seeded walk over the track's own scale; no samples or reference
## material are used. Rerun after editing TRACKS:
##   godot --headless --path . --script res://tools/make_music.gd
## then `godot --headless --path . --import` so Godot picks up the files (loops are set in .import).
const RATE := 22050
const SCALES := {
 "major":[0,2,4,5,7,9,11],"minor":[0,2,3,5,7,8,10],"dorian":[0,2,3,5,7,9,10],
 "lydian":[0,2,4,6,7,9,11],"mixolydian":[0,2,4,5,7,9,10]}
# prog: scale degree of each two-bar chord. drums: 0 none, 1 light, 2 full.
const TRACKS := {
 "menu":{"bpm":80,"root":57,"scale":"major","prog":[0,5,3,4],"drums":0,"seed":7,"lead":0.5,"pad":0.20},
 "lantern_ridge":{"bpm":100,"root":50,"scale":"dorian","prog":[0,3,6,4],"drums":1,"seed":21,"lead":0.7,"pad":0.16},
 "mossy_comet":{"bpm":112,"root":55,"scale":"mixolydian","prog":[0,6,3,0],"drums":2,"seed":34,"lead":0.75,"pad":0.12},
 "copper_cloud":{"bpm":126,"root":52,"scale":"minor","prog":[0,5,2,6],"drums":2,"seed":55,"lead":0.85,"pad":0.10},
 "velvet_glacier":{"bpm":88,"root":53,"scale":"lydian","prog":[0,1,4,0],"drums":0,"seed":89,"lead":0.45,"pad":0.24},
 "echo_orchard":{"bpm":134,"root":48,"scale":"dorian","prog":[0,6,5,3],"drums":2,"seed":144,"lead":0.9,"pad":0.12}}
const BARS := 16
func _initialize() -> void:
 DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets/music"))
 for name in TRACKS:
  var started := Time.get_ticks_msec()
  var samples := render(TRACKS[name])
  var path := "res://assets/music/%s.wav" % name
  write_wav(samples,ProjectSettings.globalize_path(path))
  print("%s: %.1fs in %dms" % [path,samples.size()/float(RATE),Time.get_ticks_msec()-started])
 quit()

func render(track: Dictionary) -> PackedFloat32Array:
 var rng := RandomNumberGenerator.new()
 rng.seed=track.seed
 var beat: float=60.0/track.bpm
 var eighth := beat*0.5
 var bar := beat*4.0
 var length := int(bar*BARS*RATE)
 var out := PackedFloat32Array()
 out.resize(length)
 var scale: Array=SCALES[track.scale]
 var root: int=track.root
 var prog: Array=track.prog
 # Two motifs: A for bars 1-8, a mutated B for bars 9-16. Each is 16 eighths of (degree or -1 rest).
 var motif_a := make_motif(rng)
 var motif_b := mutate(motif_a,rng)
 for bar_index in BARS:
  var chord: int=prog[(bar_index/2)%prog.size()]
  var t0 := bar_index*bar
  var tones := [chord,chord+2,chord+4]
  # Pad: soft sustained triad across each two-bar chord.
  if bar_index%2==0:
   for degree in tones: add_note(out,t0,bar*2.0,midi(root,scale,degree),"pad",track.pad)
  # Bass: root on beats 1 and 3, fifth pickups in fuller arrangements.
  for b in 4:
   var bass_degree: int=chord-7 if b%2==0 else chord-3
   if b%2==1 and track.drums<2: continue
   add_note(out,t0+b*beat,beat*0.9,midi(root,scale,bass_degree),"bass",0.30)
  # Arpeggio: eighth-note chord tones an octave up.
  for e in 8:
   var degree: int=tones[[0,1,2,1,0,2,1,2][e]]+7
   add_note(out,t0+e*eighth,eighth*0.9,midi(root,scale,degree),"arp",0.07)
  # Lead: motif notes snapped to chord tones on strong beats; the last bar of each phrase cadences.
  var motif: Array=motif_a if bar_index<8 else motif_b
  var half: int=(bar_index%2)*8
  for e in 8:
   var degree: int=motif[half+e]
   if degree<0: continue
   if bar_index%8==7 and e>=4:
    if e==4: add_note(out,t0+e*eighth,eighth*4.0,midi(root,scale,chord+7),"lead",track.lead*0.16)
    continue
   if e%4==0: degree=nearest_tone(degree,tones)
   var span := 1
   while half+e+span<16 and e+span<8 and motif[half+e+span]==-2: span+=1
   add_note(out,t0+e*eighth,eighth*span*0.92,midi(root,scale,degree+7),"lead",track.lead*0.16)
  # Drums
  if track.drums>0:
   for e in 8:
    var t := t0+e*eighth
    if e%4==0: add_note(out,t,0.18,0,"kick",0.5)
    if track.drums>1 and e%4==2: add_note(out,t,0.12,0,"snare",0.16)
    add_note(out,t,0.04,0,"hat",0.05 if e%2==0 else 0.03)
 # Gentle saturation keeps peaks controlled without hard clipping.
 for i in length: out[i]=tanh(out[i]*1.3)*0.8
 return out

func make_motif(rng: RandomNumberGenerator) -> Array:
 var motif := []
 var degree := rng.randi_range(0,4)
 for e in 16:
  if e>0 and rng.randf()<0.18: motif.append(-1) # rest
  elif e>0 and e%2==1 and rng.randf()<0.3: motif.append(-2) # hold previous
  else:
   degree=clampi(degree+[-2,-1,-1,1,1,2,0].pick_random() if rng.randf()<0.9 else degree+rng.randi_range(-4,4),-1,9)
   motif.append(degree)
 motif[0]=maxi(motif[0],0)
 return motif
func mutate(source: Array,rng: RandomNumberGenerator) -> Array:
 var motif := source.duplicate()
 for e in range(8,16):
  if motif[e]>=0 and rng.randf()<0.5: motif[e]=clampi(motif[e]+[-2,-1,1,2,3].pick_random(),-1,10)
 return motif
func nearest_tone(degree: int,tones: Array) -> int:
 var best: int=degree
 var distance := 99
 for tone in tones:
  for octave in [-7,0,7]:
   var candidate: int=tone+octave
   if absi(candidate-degree)<distance:
    distance=absi(candidate-degree)
    best=candidate
 return best
func midi(root: int,scale: Array,degree: int) -> int:
 return root+12*floori(degree/7.0)+int(scale[posmod(degree,7)])

func add_note(out: PackedFloat32Array,start: float,duration: float,note: int,voice: String,gain: float) -> void:
 var length := out.size()
 var freq := 440.0*pow(2.0,(note-69)/12.0)
 var release := 0.5 if voice=="pad" else 0.06
 var count := int((duration+release)*RATE)
 var begin := int(start*RATE)
 var phase := 0.0
 var noise := 0.0
 for i in count:
  var t := i/float(RATE)
  var env := 0.0
  var s := 0.0
  match voice:
   "pad":
    env=minf(1.0,t/0.35)*(1.0 if t<duration else maxf(0.0,1.0-(t-duration)/release))
    s=sin(TAU*phase)*0.7+sin(TAU*phase*2.0+0.3)*0.15+sin(TAU*phase*1.003)*0.3
   "bass":
    env=minf(1.0,t/0.005)*exp(-t*3.0)*(1.0 if t<duration else maxf(0.0,1.0-(t-duration)/release))
    s=4.0*absf(fposmod(phase,1.0)-0.5)-1.0
   "arp":
    env=minf(1.0,t/0.003)*exp(-t*14.0)
    s=(1.0 if fposmod(phase,1.0)<0.25 else -1.0)*0.5+sin(TAU*phase)*0.5
   "lead":
    env=minf(1.0,t/0.01)*(0.75+0.25*exp(-t*6.0))*(1.0 if t<duration else maxf(0.0,1.0-(t-duration)/release))
    var vibrato := 1.0+0.004*sin(TAU*5.5*t)*minf(1.0,t/0.25)
    phase+=freq*(vibrato-1.0)/RATE
    s=(1.0 if fposmod(phase,1.0)<0.5 else -1.0)*0.35+(4.0*absf(fposmod(phase,1.0)-0.5)-1.0)*0.65
   "kick":
    env=exp(-t*18.0)
    s=sin(TAU*(55.0*t+90.0*(1.0-exp(-t*30.0))/30.0))
   "snare":
    noise=lerpf(noise,randf_range(-1.0,1.0),0.6)
    env=exp(-t*28.0)
    s=noise*0.8+sin(TAU*190.0*t)*0.2
   "hat":
    noise=randf_range(-1.0,1.0)-noise*0.6
    env=exp(-t*90.0)
    s=noise*0.5
  phase+=freq/RATE
  # Wrap tails past the end so the loop point is seamless.
  out[(begin+i)%length]+=s*env*gain

func write_wav(samples: PackedFloat32Array,path: String) -> void:
 var data := PackedByteArray()
 data.resize(samples.size()*2)
 for i in samples.size(): data.encode_s16(i*2,int(clampf(samples[i],-1.0,1.0)*32767.0))
 var stream := AudioStreamWAV.new()
 stream.format=AudioStreamWAV.FORMAT_16_BITS
 stream.mix_rate=RATE
 stream.stereo=false
 stream.data=data
 stream.save_to_wav(path)
