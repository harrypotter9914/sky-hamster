"""Export generated clouds as transparent one-bit native sprites; no runtime scaling."""
from pathlib import Path
from PIL import Image

root = Path(__file__).resolve().parents[1]
art = root / 'art/sky-v0.12.9'
dest = root / 'source/sky-art'
dest.mkdir(exist_ok=True)
atlas = Image.open(art / 'cloud-atlas-master.png').convert('RGBA')
bayer = ((0,8,2,10),(12,4,14,6),(3,11,1,9),(15,7,13,5))
sizes = (112,124,108)
for i,width in enumerate(sizes):
    top = round(atlas.height*i/3)
    bottom = round(atlas.height*(i+1)/3)
    crop = atlas.crop((0,top,atlas.width,bottom))
    bounds = crop.getchannel('A').point(lambda a:255 if a>=128 else 0).getbbox()
    if not bounds: raise ValueError(f'Missing cloud row {i+1}')
    crop = crop.crop(bounds)
    height = round(crop.height*width/crop.width)
    small = crop.resize((width,height),Image.Resampling.LANCZOS)
    out = Image.new('RGBA',small.size,(255,255,255,0))
    for y in range(height):
        for x in range(width):
            r,g,b,a = small.getpixel((x,y))
            if a<128: continue
            # Bake restrained distant contrast into the one-bit pixels once.
            darkness = (1-(r*.299+g*.587+b*.114)/255)*.68
            value = 0 if darkness>(bayer[y%4][x%4]+.5)/16 else 255
            out.putpixel((x,y),(value,value,value,255))
    out.save(dest/f'cloud-{i+1}.png')
    print(f'cloud-{i+1}: {width}x{height}, one-bit RGBA')
