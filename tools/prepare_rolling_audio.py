"""Prepare the vendored CC0 marble recording (requires numpy/scipy/soundfile)."""
from pathlib import Path
import numpy as np
import soundfile as sf
from scipy.signal import butter, sosfiltfilt, resample_poly

ROOT = Path(__file__).resolve().parents[1]
data, rate = sf.read(ROOT / 'assets/audio-source/marble-roll.mp3')
# A sustained opening roll, avoiding the initial release and later quiet gaps.
data = data[round(.5 * rate):round(4.6 * rate)].mean(axis=1)
# Remove rumble and soften hiss; retain the recorded contact transients.
data = sosfiltfilt(butter(2, [180, 6500], btype='bandpass', fs=rate, output='sos'), data)
data = resample_poly(data, 1, 2)
rate //= 2
# Overlap the ends so the loop boundary follows the original waveform.
n = round(.1 * rate)
t = np.linspace(0, 1, n, endpoint=False)
join = data[-n:] * (1-t) + data[:n] * t
data = np.concatenate((join, data[n:-n]))
data *= .65 / np.max(np.abs(data))
target = ROOT / 'source/audio/roll.wav'
sf.write(target, data, rate, subtype='PCM_16')
assert np.isfinite(data).all() and np.max(np.abs(data)) < .95
print(f'{target}: {len(data)/rate:.2f}s, mono {rate}Hz PCM16, peak={np.max(np.abs(data)):.3f}, seam={abs(data[-1]-data[0]):.6f}')
