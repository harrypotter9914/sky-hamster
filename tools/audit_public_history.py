"""Inspect reachable Git blobs without printing matched credential values."""
from pathlib import Path
import subprocess, re, json, collections, zipfile, io
B=Path(__file__).resolve().parents[1]
rules={
 'private-key':rb'-----BEGIN (?:RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----',
 'github-token':rb'\b(?:gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{40,})\b',
 'openai-key':rb'\bsk-(?:proj-)?[A-Za-z0-9_-]{30,}\b',
 'aws-access':rb'\b(?:AKIA|ASIA)[A-Z0-9]{16}\b',
 'credential-url':rb'https?://[^\s/:<>"\']+:[^\s/@<>"\']{5,}@',
 'assigned-secret':rb'(?i)(?:api[_-]?key|access[_-]?token|client[_-]?secret|password)\s*[=:]\s*["\'][A-Za-z0-9_./+\-=]{20,}["\']',
 'session-cookie':rb'(?i)(?:sessionid|session_token|auth_token|csrf_token)\s*[=:]\s*["\'][A-Za-z0-9_./+\-=]{24,}["\']',
 'device-identifier':rb'(?i)(?:serialnumber|serial_number|device_serial|serial number)\s*[=:]\s*["\']?[A-Za-z0-9_-]{6,}',
}
objects=subprocess.check_output(['git','rev-list','--objects','--all'],cwd=B).splitlines()
p=subprocess.Popen(['git','cat-file','--batch'],cwd=B,stdin=subprocess.PIPE,stdout=subprocess.PIPE)
hits=[];total=0;bytes_total=0;archives=[]
for item in objects:
 sha,_,path=item.partition(b' ');p.stdin.write(sha+b'\n');p.stdin.flush();head=p.stdout.readline().split()
 if len(head)<3:continue
 typ=head[1];size=int(head[2]);data=p.stdout.read(size);p.stdout.read(1)
 if typ!=b'blob':continue
 total+=1;bytes_total+=size;name=path.decode('utf8','replace')
 if name.endswith('.zip'):
  try:
   z=zipfile.ZipFile(io.BytesIO(data));archives.append({'path':name,'members':len(z.namelist()),'suspicious':[n for n in z.namelist() if re.search(r'(?i)(\.env|credential|\.pem$|\.key$|\.git/|\.exe$)',n)]})
  except zipfile.BadZipFile:archives.append({'path':name,'error':'invalid zip'})
 if b'\x00' in data[:8192]:continue
 for rule,pat in rules.items():
  for m in re.finditer(pat,data):hits.append({'object':sha.decode(),'path':name,'rule':rule,'line':data[:m.start()].count(b'\n')+1})
p.stdin.close();p.wait()
report={'reachableCommits':int(subprocess.check_output(['git','rev-list','--all','--count'],cwd=B)),'uniqueBlobs':total,'bytesInspected':bytes_total,'findings':hits,'zipAudit':archives,'scope':'All local reachable refs; no secret values printed. Pattern scanning does not prove the absence of every possible secret.'}
out=B.parent/'sky-hamster-private-audit';out.mkdir(exist_ok=True);(out/'history-scan.json').write_text(json.dumps(report,indent=2),encoding='utf8')
print(json.dumps({'commits':report['reachableCommits'],'blobs':total,'bytes':bytes_total,'findings':hits,'archives':len(archives)},indent=2))
