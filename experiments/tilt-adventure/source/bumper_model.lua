-- One ground-space model for the low radial bumper, its artwork and collision.
BumperModel={radius=14,height=10,ballRadius=9,anchorX=24,anchorY=24}
function BumperModel.radiusAt(m) return m.radius or BumperModel.radius end
function BumperModel.contactRadius(m,z)
 local h=m.sideHeight or BumperModel.height
 if z>=h or z+18<=0 then return nil end
 -- A sphere raised above the side wall has a smaller horizontal cross-section.
 local dy=math.max(0,z+BumperModel.ballRadius-h,-z-BumperModel.ballRadius)
 return BumperModel.radiusAt(m)+math.sqrt(math.max(0,81-dy*dy))
end
