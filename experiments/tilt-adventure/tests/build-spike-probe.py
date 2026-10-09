"""Add continuous full-finale travel and warm control repeats to a perf build.

Run build-perf.ps1 -Travel -Routes 53 first. Changes only the diagnostic copy.
"""
from pathlib import Path
import subprocess
here=Path(__file__).resolve().parent
repo=here.parents[2]
qa=repo/'builds/tilt-perf-source'
path=qa/'main.lua';code=path.read_text(encoding='utf-8-sig')
a=code.index('local function planAll()');b=code.index('\nlocal samples,costs',a)
plan='''local function planAll()
 local c=Courses[53];Curriculum.ensure(c)
 specs={
  {route=53,kind='stream',frames=math.ceil((c.goal[1]-c.start[1])/8)*2,name='continuous-full-finale'},
  {route=53,kind='pad',index=1,frames=240,name='bridge-after-continuous-travel'},
  {route=53,kind='pad',index=1,frames=240,name='bridge-warm-repeat'}
 }
 stages={53,53,53};results.mode='continuous camera and repeated live bridge control; instrumented diagnostic'
 Bench.profile=true
 print('BENCH PLAN courses=1 scenes=3')
end'''
code=code[:a]+plan+code[b:]
# Wrappers are installed before planAll, so enable profiling on import too.
code=code.replace("local profile={}\nif Bench.profile", "local profile={}\nBench.profile=true\nif Bench.profile")
code=code.replace("profile[label]=(profile[label] or 0)+now()-t;return a,b,c,d,e",
                  "local ms=now()-t;profile[label]=(profile[label] or 0)+ms;if ms>100 then print('SPIKE',label,ms) end;return a,b,c,d,e")
path.write_text(code,encoding='utf-8')
sdk=Path('C:/Users/12063/Documents/PlaydateSDK')
subprocess.run([str(sdk/'bin/pdc.exe'),'-sdkpath',str(sdk),str(qa),str(repo/'builds/tilt-perf/sky-hamster-tilt.pdx')],check=True)
print('Built isolated continuous camera / bridge follow-up probe')
