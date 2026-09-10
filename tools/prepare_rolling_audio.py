"""Synthesize glass rolling microcontacts without recordings or noise grains."""
from pathlib import Path
import math, random, struct, wave
ROOT = Path(__file__).resolve().parents[1]
RATE = 22050
DURATION = 4
rng = random.Random(53066)
data = [0.0] * (RATE * DURATION)
# Damped inharmonic modes: no drop transient, noise bed, bass or long bell ring.
time = 0.0
while time < DURATION:
    gain = rng.uniform(.045, .075)
    pitch = rng.uniform(.98, 1.02)
    for i in range(round(.012 * RATE)):
        t = i / RATE
        attack = 1 - math.exp(-t / .0008)
        contact = 0.0
        for frequency, weight, decay in ((1700, 1, .0012), (2830, .38, .0008), (4210, .12, .0005)):
            contact += weight * math.sin(2 * math.pi * frequency * pitch * t) * math.exp(-t / decay)
        data[(round(time * RATE) + i) % len(data)] += gain * attack * contact
    time += rng.uniform(.070, .110)
# Wrap event tails for a continuous loop, normalize below collision loudness.
scale = .20 / max(abs(x) for x in data)
data = [x * scale for x in data]
assert all(math.isfinite(x) and abs(x) < .95 for x in data)
target = ROOT / 'source/audio/roll.wav'
with wave.open(str(target), 'wb') as output:
    output.setparams((1, 2, RATE, 0, 'NONE', 'not compressed'))
    output.writeframes(b''.join(struct.pack('<h', round(x * 32767)) for x in data))
print(f'{target}: {DURATION}s mono PCM16 {RATE}Hz peak={max(abs(x) for x in data):.3f}')
