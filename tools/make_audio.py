"""Deterministic synthesized PCM assets; no external recordings or samples."""
from pathlib import Path
import math
import random
import struct
import wave

RATE=22050
ROOT=Path(__file__).resolve().parents[1]/'source'/'audio'
ROOT.mkdir(exist_ok=True)
rng=random.Random(530)
def write(name, values):
    peak=max(abs(x) for x in values)
    assert peak<0.95, (name,peak)
    with wave.open(str(ROOT/(name+'.wav')),'wb') as w:
        w.setparams((1,2,RATE,0,'NONE','not compressed'))
        w.writeframes(b''.join(struct.pack('<h',round(x*32767)) for x in values))
    print(f'{name}: {len(values)/RATE:.2f}s, peak {peak:.3f}')
def chirp(length, start, end, noise=0, gain=0.45):
    out=[];phase=0
    for i in range(round(length*RATE)):
        t=i/RATE;u=t/length;phase+=2*math.pi*(start+(end-start)*u)/RATE
        envelope=min(1,t/0.006)*(1-u)**1.5
        out.append(gain*envelope*((1-noise)*math.sin(phase)+noise*rng.uniform(-1,1)))
    return out
write('jump',chirp(.22,240,780))
write('fall',chirp(.55,520,75,.08,.42))
write('wall',chirp(.09,190,65,.45,.5))
write('land',chirp(.12,140,65,.15,.44))
write('menu',chirp(.045,640,820,0,.28))
def melody(length, notes):
    data=[0.0]*round(length*RATE)
    for when,midi,duration,gain in notes:
        frequency=440*2**((midi-69)/12)
        for i in range(round(duration*RATE)):
            t=i/RATE;index=round(when*RATE)+i
            if index>=len(data): break
            env=min(1,t/.015)*max(0,1-t/duration)**2
            tone=(math.sin(2*math.pi*frequency*t)+.16*math.sin(4*math.pi*frequency*t))/1.16
            data[index]+=gain*env*tone
    return data
write('checkpoint',melody(.4,[(0,72,.18,.38),(.12,79,.28,.38)]))
write('win',melody(.9,[(0,69,.3,.36),(.15,72,.3,.36),(.3,76,.3,.36),(.45,81,.45,.34)]))
write('charge',chirp(.055,360,430,0,.23))
# Aperiodic, unpitched micro-contacts: no bass oscillator or metronomic pulse.
roll_rng=random.Random(53063)
roll=[0.0]*(RATE*3)
time=0.0
while time<3:
    duration=roll_rng.uniform(.005,.014)
    gain=roll_rng.uniform(.12,.32)
    low=0.0;band=0.0
    for i in range(round(duration*RATE)):
        t=i/RATE
        noise=roll_rng.uniform(-1,1)
        low+=.13*(noise-low)
        band+=.65*((noise-low)-band)
        envelope=min(1,t/.0005)*math.exp(-t/(duration*.22))*(1-t/duration)
        roll[(round(time*RATE)+i)%len(roll)]+=gain*band*envelope
    time+=roll_rng.uniform(.004,.009) if roll_rng.random()<.23 else roll_rng.uniform(.016,.040)
# Match a useful peak without restoring a low-frequency drone.
scale=.26/max(abs(x) for x in roll)
roll=[x*scale for x in roll]
write('roll',roll)
notes=[]
for bar,root in enumerate([57,53,60,55]):
    for beat in (0,2): notes.append((bar*3+beat*.75,root,1.2,.13))
    for beat,interval in ((0,12),(1.5,19),(2.5,16)):
        notes.append((bar*3+beat*.75,root+interval,.9 if beat<2 else .9,.12))
write('music',melody(12,notes))
