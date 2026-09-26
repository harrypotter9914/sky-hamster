"""Original, deterministic mechanical effects. Does not alter existing game audio."""
from pathlib import Path
import math, random, struct, wave

RATE = 22050
ROOT = Path(__file__).resolve().parents[1] / 'experiments/tilt-adventure/source/audio/machines'
ROOT.mkdir(parents=True, exist_ok=True)
rng = random.Random(104)

def save(name, samples, loop=False):
    # Remove DC and leave headroom. Runtime mixer applies distance/voice limits.
    mean = sum(samples) / len(samples)
    samples = [x - mean for x in samples]
    peak = max(map(abs, samples)) or 1
    samples = [x * .64 / peak for x in samples]
    if not loop:
        for i in range(min(100, len(samples))):
            samples[i] *= i / 100
            samples[-1-i] *= i / 100
    with wave.open(str(ROOT / (name + '.wav')), 'wb') as out:
        out.setparams((1, 2, RATE, 0, 'NONE', 'not compressed'))
        out.writeframes(b''.join(struct.pack('<h', round(v * 32767)) for v in samples))
    print(f'{name}: {len(samples)/RATE:.3f}s')

def impact(name, duration, freq, noise=.1, sweep=0, repeats=1):
    data=[];phase=0;filtered=0
    for i in range(round(duration*RATE)):
        t=i/RATE;u=t/duration
        phase += 2*math.pi*(freq+sweep*(1-u)**2)/RATE
        filtered=.68*filtered+.32*rng.uniform(-1,1)
        env=(1-u)**2*math.exp(-3*(u*repeats % 1))
        tone=math.sin(phase)+.23*math.sin(phase*2.71)
        data.append(env*((1-noise)*tone+noise*filtered*3))
    save(name,data)

impact('connect',.13,760,.14,220,2)
impact('release',.14,490,.20,-160,2)
impact('crank',.07,1250,.50,-350)
impact('stop',.12,420,.45,120)
impact('spring',.38,390,.04,750,3)
impact('cannon',.34,105,.75,130)
impact('gate_open',.23,360,.66,240,3)
impact('gate_close',.22,210,.68,200,2)
impact('trap_open',.19,650,.50,-300,2)
impact('trap_close',.14,280,.60,150)
impact('warning',.09,1550,.06,150)
impact('switch',.11,940,.50,240,2)
impact('jet_on',.17,700,.94,400)
impact('jet_off',.12,480,.90,-120)
impact('magnet_contact',.20,610,.02,190,2)
impact('belt_contact',.12,580,.58,120,3)
impact('ui_move',.045,900,.02,120)
impact('ui_confirm',.10,640,.02,330,2)
impact('ui_back',.09,500,.02,-180)
impact('ui_toggle',.075,1100,.20,-120)
impact('ui_unlock',.30,900,.01,420,3)
impact('ui_ready',.16,720,.01,260,2)

# Integer harmonics over a one-second period produce seamless loop boundaries.
# Air is a periodic filtered-noise spectrum; mechanisms use restrained harmonics
# and contact modulation rather than loud musical tones.
for name,base,rate,air in [('fan',210,9,.88),('ferry',180,12,.24),('rotor',320,8,.30),
                           ('belt',260,14,.44),('jet',520,5,.97),('magnet',330,3,.08),
                           ('sweeper',240,2,.70),('lift',250,6,.20),('slider',390,16,.32),
                           ('bridge',440,7,.28),('winch',580,11,.35),
                           ('cannon_aim',710,4,.42),('fan_aim',880,10,.22)]:
    partials=[(rng.randint(250,2400),rng.random()*math.tau,rng.uniform(.4,1)) for _ in range(28)]
    data=[]
    for i in range(RATE):
        t=i/RATE
        hiss=sum(a*math.sin(math.tau*f*t+p) for f,p,a in partials)/7
        motor=math.sin(math.tau*base*t)+.22*math.sin(math.tau*base*3*t)
        contact=(.72+.28*math.cos(math.tau*rate*t))
        data.append(((1-air)*motor+air*hiss)*contact)
    save(name,data,loop=True)
