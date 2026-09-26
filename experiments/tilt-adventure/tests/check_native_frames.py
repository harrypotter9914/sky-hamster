"""Compare SDK-rendered frames against the unmodified 0.4.0 pixel baseline."""
import hashlib
import json
import sys
from pathlib import Path
from PIL import Image

baseline = json.loads((Path(__file__).parent / 'fixtures/v040-frame-hashes.json').read_text())
folder = Path(sys.argv[1])
different = []
for name, expected in baseline['frames'].items():
    image = Image.open(folder / name).convert('RGB')
    if image.size != (400, 240) or hashlib.sha256(image.tobytes()).hexdigest() != expected:
        different.append(name)
assert not different, f'Native visual changes: {different}'
print(f"PASS: {len(baseline['frames'])} native gameplay frames are pixel-identical to {baseline['reference']}")
