"""Original Shotgun Kid SFX. Standard-library synthesis, no external samples."""
import math, random, struct, wave
from pathlib import Path
RATE=44100
OUT=Path(__file__).resolve().parents[1]/'assets/audio'
OUT.mkdir(parents=True,exist_ok=True)
random.seed(3817)
def noise(n, cutoff):
    alpha=1-math.exp(-2*math.pi*cutoff/RATE)
    last=0; data=[]
    for _ in range(n):
        last+=alpha*(random.uniform(-1,1)-last);data.append(last)
    return data
def create(name,duration,kind):
    n=int(duration*RATE); grit=noise(n,4200);low=noise(n,300); data=[]
    phase=0.0
    for i in range(n):
        t=i/RATE
        if kind=='step':
            v=.6*grit[i]*math.exp(-t*65)+.25*math.sin(2*math.pi*145*t)*math.exp(-t*80)
        elif kind=='jump':
            freq=180+700*min(t/.10,1);phase+=2*math.pi*freq/RATE
            v=.3*math.sin(phase)*math.exp(-t*25)+.25*grit[i]*math.exp(-t*55)
        elif kind=='shot':
            phase+=2*math.pi*(60+120*math.exp(-t*35))/RATE
            v=.58*grit[i]*math.exp(-t*45)+.7*low[i]*math.exp(-t*19)+.45*math.sin(phase)*math.exp(-t*23)
            if t>.075: v+=.09*math.sin(2*math.pi*1350*(t-.075))*math.exp(-(t-.075)*65)
        elif kind=='empty':
            v=.6*grit[i]*math.exp(-t*180)+.25*math.sin(2*math.pi*1100*t)*math.exp(-t*160)
        elif kind=='reload':
            v=0
            for at in [.0,.09]:
                u=t-at
                if u>=0:v+=.45*grit[i]*math.exp(-u*95)+.25*math.sin(2*math.pi*740*u)*math.exp(-u*115)
        elif kind=='boom':
            phase+=2*math.pi*(42+85*math.exp(-t*10))/RATE
            v=.42*grit[i]*math.exp(-t*17)+.95*low[i]*math.exp(-t*8)+.47*math.sin(phase)*math.exp(-t*8)
            if t>.09:v+=.10*math.sin(2*math.pi*660*t)*math.exp(-(t-.09)*18)
        elif kind=='land':
            v=.4*grit[i]*math.exp(-t*55)+.65*low[i]*math.exp(-t*32)+.3*math.sin(2*math.pi*85*t)*math.exp(-t*40)
        elif kind in ['ready','checkpoint','clear']:
            notes={'ready':[660,990], 'checkpoint':[523.25,659.25,783.99], 'clear':[523.25,659.25,783.99,1046.5]}[kind]
            v=0
            for j,freq in enumerate(notes):
                u=t-j*(.06 if kind=='ready' else .09)
                if u>=0:v+=(math.sin(2*math.pi*freq*u)+.2*math.sin(2*math.pi*freq*2*u))*math.exp(-u*11)*min(1,u*500)*.25
        elif kind=='respawn':
            phase+=2*math.pi*(450-300*min(t/.17,1))/RATE
            v=.3*math.sin(phase)*math.exp(-t*11)+.1*grit[i]*math.exp(-t*20)
        else:
            v=.3*math.sin(2*math.pi*650*t)*math.exp(-t*75)
        fade=min(1,i/90,(n-1-i)/300)
        data.append(math.tanh(v*1.3)*max(0,fade))
    peak=max(abs(v) for v in data)
    data=[v/peak*.78 for v in data]
    with wave.open(str(OUT/(name+'.wav')),'wb') as w:
        w.setnchannels(1);w.setsampwidth(2);w.setframerate(RATE)
        w.writeframes(b''.join(struct.pack('<h',round(v*32767)) for v in data))
    rms=math.sqrt(sum(v*v for v in data)/len(data))
    print(f'{name}: {duration:.2f}s, peak -2.2 dBFS, RMS {20*math.log10(rms):.1f} dBFS')
for spec in [('step',.08,'step'),('jump',.15,'jump'),('shot',.25,'shot'),('empty',.065,'empty'),('reload',.24,'reload'),('mine_blast',.55,'boom'),('land',.16,'land'),('mine_ready',.28,'ready'),('checkpoint',.48,'checkpoint'),('clear',.75,'clear'),('respawn',.3,'respawn'),('ui',.075,'ui')]:create(*spec)
