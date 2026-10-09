"""Decode the firmware screen command; preserve 400x240 hardware pixels."""
from pathlib import Path
import sys
from PIL import Image

source=Path(sys.argv[1]);target=Path(sys.argv[2]);data=source.read_bytes()
marker=b'~screen:\n'
assert marker in data, 'No firmware framebuffer marker'
payload=data.split(marker,1)[1]
# Native frame rows are 52 bytes, with two alignment bytes ignored (SDK C docs).
# Some firmware exports strip the alignment bytes and send 50-byte rows.
stride=52 if len(payload)>=52*240 else 50
assert len(payload)>=stride*240, f'Incomplete framebuffer: {len(payload)} bytes'
pixels=b''.join(payload[y*stride:y*stride+50] for y in range(240))
Image.frombytes('1',(400,240),pixels).save(target)
print(f'Decoded hardware screen: {target}, stride {stride}, native 400x240')
