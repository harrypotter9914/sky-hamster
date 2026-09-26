Audio={enabled=false,effects=true,musicEnabled=true,cooldown=0,chargeStep=0}
local A=Audio
function A.init(enabled)
 A.enabled=enabled
 if not enabled then return end
 A.players={}
 for _,name in ipairs({'jump','fall','wall','land','menu','checkpoint','win','charge','roll','music'}) do
  local player,err=playdate.sound.sampleplayer.new('audio/'..name)
  assert(player,'Audio '..name..': '..tostring(err));A.players[name]=player
 end
 A.players.music:setVolume(0.16);A.players.music:play(0)
end
function A.play(name,volume)
 if not A.enabled or Build.classroom or not A.effects then return end
 local player=A.players[name];player:stop();player:setVolume(volume or 0.6);player:play(1)
end
function A.quiet()
 if not A.enabled then return end
 A.players.roll:stop()
end
function A.toggleEffects()
 A.effects=not A.effects
 if not A.effects then for name,p in pairs(A.players) do if name~='music' then p:stop() end end end
end
function A.toggleMusic()
 A.musicEnabled=not A.musicEnabled
 if A.musicEnabled then A.players.music:play(0) else A.players.music:stop() end
end
function A.update(dt,rolling,speed,charge)
 if not A.enabled or Build.classroom then return end
 A.cooldown=math.max(0,A.cooldown-dt)
 local player=A.players.roll
 if rolling and speed>5 and A.effects then
  player:setRate(math.min(1.65,0.55+speed/180));player:setVolume(math.min(0.50,0.04+speed/420))
  if not player:isPlaying() then player:play(0) end
 else player:stop() end
 local step=math.floor(charge*4)
 if step>A.chargeStep then A.play('charge',0.4) end
 A.chargeStep=step
end
function A.impact(speed)
 if speed>15 and A.cooldown<=0 then A.play('wall',math.min(0.75,0.25+speed/220));A.cooldown=0.18 end
end
function A.pause()
 if not A.enabled then return end
 A.musicWasPlaying=A.players.music:isPlaying()
 for name,p in pairs(A.players) do if name=='music' then p:setPaused(true) else p:stop() end end
end
function A.resume()
 if not A.enabled then return end
 if A.musicWasPlaying and A.musicEnabled then A.players.music:setPaused(false) end
end
