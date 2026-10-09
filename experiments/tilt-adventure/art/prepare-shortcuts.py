"""Export generated shortcut atlas at fixed, readable one-bit runtime sizes."""
from pathlib import Path
from PIL import Image, ImageChops

root=Path(__file__).resolve().parent
sheet=Image.open(root/'tutorial-v0.12.10/shortcuts-original.png').convert('RGB')
out=root.parent/'source/tutorial-tools';out.mkdir(exist_ok=True)
w,h=sheet.size
for i,name in enumerate(['map','help','goal','recenter']):
    x,y=(i%2)*w//2,(i//2)*h//2
    cell=sheet.crop((x,y,x+w//2,y+h//2))
    bounds=ImageChops.invert(cell.convert('L')).point(lambda v:255 if v>120 else 0).getbbox()
    assert bounds, name
    cell=cell.crop(bounds);cell.thumbnail((156,88),Image.Resampling.LANCZOS)
    canvas=Image.new('RGB',(160,94),'white')
    canvas.paste(cell,((160-cell.width)//2,(94-cell.height)//2))
    canvas.convert('L').point(lambda v:255 if v>=165 else 0).convert('1').save(out/(name+'.png'))
print('Exported four generated 160x94 tutorial illustrations, aspect ratio retained.')
