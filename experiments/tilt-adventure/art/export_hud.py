"""Deterministic production export of the generated six-emblem sheet."""
from pathlib import Path
from PIL import Image, ImageChops

root = Path(__file__).resolve().parent.parent
sheet = Image.open(root / 'art/hud-emblems-v0.10.10-original.png').convert('L')
names = ['flag', 'tilt', 'jump', 'speed', 'clock', 'falls']
preview = Image.new('1', (6 * 24, 24), 1)
for i, name in enumerate(names):
    col, row = i % 3, i // 3
    cell = sheet.crop((col*512, row*512, (col+1)*512, (row+1)*512))
    mask = cell.point(lambda p: 255 if p < 110 else 0)
    cell = cell.crop(mask.getbbox())
    cell.thumbnail((16, 16), Image.Resampling.LANCZOS)
    cell = cell.point(lambda p: 255 if p >= 160 else 0).convert('1')
    icon = Image.new('1', (18, 18), 1)
    icon.paste(cell, ((18-cell.width)//2, (18-cell.height)//2))
    icon.save(root / f'source/hud-{name}.png')
    preview.paste(icon, (i*24+3, 3))
preview.resize((864,144),Image.Resampling.NEAREST).save(root/'art/hud-emblems-v0.10.10-preview.png')
