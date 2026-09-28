"""Production packing of the generated sprite into its ground-space pixel bounds."""
from pathlib import Path
from PIL import Image

root=Path(__file__).resolve().parent.parent
original=Image.open(root/'art/bumper-ring-v0.10.12-original.png').convert('RGBA')
alpha=original.getchannel('A').point(lambda x:255 if x>=128 else 0)
box=alpha.getbbox()
assert box
im=original.crop(box).resize((36,25),Image.Resampling.LANCZOS)
alpha=im.getchannel('A').point(lambda x:255 if x>=128 else 0)
ink=im.convert('L').point(lambda x:255 if x>=155 else 0).convert('RGBA')
ink.putalpha(alpha)
out=Image.new('RGBA',(48,36),(0,0,0,0));out.paste(ink,(6,9))
out.save(root/'source/machine-ring.png')
out.resize((384,288),Image.Resampling.NEAREST).save(root/'art/bumper-ring-v0.10.12-preview.png')
print('Packed generated ring: 36x25 art, 48x36 canvas, ground anchor 24,24')
