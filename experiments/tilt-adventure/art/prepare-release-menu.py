"""Export generated masters as fixed-size one-bit Playdate menu sprites.

This converter only crops, sizes and quantizes the generated artwork; it does
not redraw it. Device poses keep a common canvas, with the crank on the right.
"""
from pathlib import Path
from PIL import Image, ImageChops, ImageDraw

root=Path(__file__).resolve().parent
masters=root/'menu-v0.12.8'
out=root.parent/'source/menu-art'
out.mkdir(exist_ok=True)

def bounds(image):
    if image.mode=='RGBA' and image.getextrema()[3][0]<255:
        return image.getchannel('A').getbbox()
    return ImageChops.invert(image.convert('L')).point(lambda v:255 if v>96 else 0).getbbox()

def export(image,name,size,transparent=False,threshold=160):
    image=image.convert('RGBA')
    image=image.crop(bounds(image))
    image.thumbnail(size,Image.Resampling.LANCZOS)
    canvas=Image.new('RGBA',size,(255,255,255,0 if transparent else 255))
    canvas.alpha_composite(image,((size[0]-image.width)//2,(size[1]-image.height)//2))
    alpha=canvas.getchannel('A').point(lambda v:255 if v>=128 else 0)
    mono=canvas.convert('L').point(lambda v:255 if v>=threshold else 0).convert('RGBA')
    if transparent: mono.putalpha(alpha)
    if transparent and image.getextrema()[3][0]==255:
        # Remove only white pixels connected to the outside, retaining the
        # white glass and hamster enclosed by the generated black silhouette.
        for corner in [(0,0),(size[0]-1,0),(0,size[1]-1),(size[0]-1,size[1]-1)]:
            if mono.getpixel(corner)==(255,255,255,255):
                ImageDraw.floodfill(mono,corner,(255,255,255,0))
    mono.save(out/(name+'.png'))

sheet=Image.open(masters/'steering-frames.png')
# The selected generated atlas has four poses in row 1 and five in row 2.
regions=[(0,0,384,330),(384,0,768,330),(768,0,1152,330),(1152,0,1536,330)]
edges=[0,330,630,930,1230,1536]
regions += [(edges[i],330,edges[i+1],665) for i in range(5)]
for i,box in enumerate(regions,1): export(sheet.crop(box),f'device-{i}',(50,54))
for i in range(3): export(sheet.crop((i*512,665,(i+1)*512,1024)),f'ball-{i+1}',(24,24),True,220)
card=Image.open(masters/'card.png').convert('RGB')
card=card.crop(bounds(card))
for name,size in [('card',(180,140))]:
    card.resize(size,Image.Resampling.LANCZOS).convert('L').point(lambda v:255 if v>=160 else 0).convert('1').save(out/(name+'.png'))
export(Image.open(masters/'start-button.png'),'start-card',(360,51))
export(Image.open(masters/'lock.png'),'lock',(20,25),True)
export(Image.open(masters/'road.png'),'road',(90,45),True)
print('Exported 16 generated menu sprites with fixed runtime dimensions.')
