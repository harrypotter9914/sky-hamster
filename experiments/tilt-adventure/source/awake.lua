-- USB power keeps the game available for development, including a full battery.
-- This policy applies to title, loading and play; battery-only use retains auto-lock.
Awake={nextCheck=0}
function Awake.update(force)
 if not playdate.getPowerStatus or not playdate.setAutoLockDisabled then return end
 local now=playdate.getCurrentTimeMilliseconds()
 if not force and now<Awake.nextCheck then return end
 Awake.nextCheck=now+1000
 local power=playdate.getPowerStatus()
 if not power then return end
 local usb=power.USB==true
 if Awake.usb~=usb then
  playdate.setAutoLockDisabled(usb);Awake.usb=usb
  print(usb and 'POWER: USB connected; auto-lock disabled' or 'POWER: USB disconnected; auto-lock restored')
 end
end
Awake.update(true)
